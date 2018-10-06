#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

NMTMPDIR=/var/netmodes
OLD_MODE_FILE=/var/netmodes/old_mode
SWITCHMODELOCK="/tmp/switching_mode"
MODEDIR=$(uci -q get netmode.setup.dir)
MTK=0

opkg list-installed | grep -q kmod-mt.*mtk && MTK=1

[ -n "$MODEDIR" ] || MODEDIR="/etc/netmodes"

toggle_firewall() {
	local section=$1
	local disable=$2
	config_get name "$1" name
	if [ "$name" == "wan" ]; then
		uci -q set firewall.settings.disabled=$disable
		if [ "$disable" == "1" ]; then
			uci -q set firewall.$section.input="ACCEPT"
		else
			uci -q set firewall.$section.input="REJECT"
		fi
		uci -q commit firewall
	fi
}

disable_firewall() {
	config_load firewall
	config_foreach toggle_firewall zone $1
	/etc/init.d/firewall reload
}

is_known_macaddr()
{
	macaddr=$1

	echo $macaddr | grep -i -e "^00:22:07" \
				-e "^02:22:07" \
				-e "^44:D4:37" \
				-e "^00:0C:07" \
				-e "^02:0C:07" \
				-e "^06:0C:07" \
				-e "^00:0C:43" \
				-e "^02:0C:43" \
				-e "^06:0C:43" \
	&& return
	false
}

get_wifi_wet_interface() {
	local ifname=""
	handle_interface() {
		[ -n "$ifname" ] && return
		config_get mode "$1" mode
		if [ "$mode" == "sta" -o "$mode" == "wet" ]; then
			config_get ifname "$1" ifname
		fi
	}
	config_load wireless
	config_foreach handle_interface wifi-iface
	echo "$ifname"
}

get_wifi_iface_cfgstr() {
	get_cfgno() {
		config_get ifname "$1" ifname
		[ "$ifname" == "$2" ] && echo "wireless.$1"
	}
	config_load wireless
	config_foreach get_cfgno wifi-iface $1
}

correct_uplink() {
	local IFACE="$1"
	local WANDEV="$(db -q get hw.board.ethernetWanPort)"
	local WETIF="$(get_wifi_wet_interface)"
	local link wetcfg wetnet wetmac

	[ $MTK -eq 1 ] || WANDEV="$WANDEV.1"

	[ -n "$IFACE" -a "$IFACE" != "$WANDEV" -a "$IFACE" != "$WETIF" ] && return

	link=$(cat /sys/class/net/${WANDEV:0:4}/operstate)
	[ $MTK -eq 1 ] && link=$(swconfig dev switch0 port 0 get link | awk '{print$2}' | cut -d':' -f2)

	if [ ! -f /tmp/netmodes/uplink-macaddr-corrected ]; then
		wetcfg="$(get_wifi_iface_cfgstr $WETIF)"
		wetnet="$(uci -q get $wetcfg.network)"
		wetmac="$(ifconfig $WETIF | grep HWaddr | awk '{print$NF}')"
		if [ -d /sys/class/net/br-$wetnet ]; then
			ifconfig br-$wetnet hw ether $wetmac
			#touch -f /tmp/netmodes/uplink-macaddr-corrected
		fi
	fi

	if [ "$link" == "up" ]; then
		ubus call network.device set_state "{\"name\":\"$WETIF\", \"defer\":true}"
		ubus call network.device set_state "{\"name\":\"$WANDEV\", \"defer\":false}"
	else
		ubus call network.device set_state "{\"name\":\"$WETIF\", \"defer\":false}"
		ubus call network.device set_state "{\"name\":\"$WANDEV\", \"defer\":true}"
		ubus call led.internet  set '{"state" : "notice"}'
	fi
}

switch_netmode() {
	local newmode="$1"

	[ -f /etc/config/netmode -a -d $MODEDIR ] || return

	[ -n "$newmode" ] && uci -q set netmode.setup.curmode="$newmode"

	local curmode conf old_mode

	# NETMODE CONFIG #
	config_load netmode
	config_get curmode setup curmode
	uci -q set netmode.setup.repeaterready="0"

	# set default JUCI page to overview
	uci -q set juci.juci.homepage="overview"
	uci commit juci

	if [ "$curmode" == "repeater" ]; then
		if [ $MTK -eq 1 ]; then
			curmode="repeater_mtk_5g_up_dual_down"
		else
			curmode="repeater_brcm_2g_up_dual_down"
		fi
		uci set netmode.setup.curmode="$curmode"
	fi
	if [ "$curmode" == "routed" ]; then
		if [ $MTK -eq 1 ]; then
			curmode="routed_mtk"
		else
			curmode="routed_brcm"
		fi
		uci set netmode.setup.curmode="$curmode"
	fi
	uci commit netmode
	# end of NETMODE CONFIG #

	old_mode="$(cat $OLD_MODE_FILE 2>/dev/null)"

        # if curmode has not changed do not copy configs
        if [ "$curmode" == "$old_mode" ]; then
                /etc/init.d/environment reload
                return
        fi

        echo $curmode >$OLD_MODE_FILE

	[ -d "/etc/netmodes/$curmode" ] || return
	logger -s -p user.info -t $0 "[netmode] Copying /etc/netmodes/$curmode in /etc/config" >/dev/console
	cp /etc/netmodes/$curmode/* /etc/config/
	rm -f /etc/config/DETAILS
	sync

	local reboot=$(uci -q get netmode.$curmode.reboot)

	if [ "$reboot" != "0" ]; then
		reboot &
		exit
	fi

	/etc/init.d/environment reload
	case "$curmode" in
		repeater*)
			touch $SWITCHMODELOCK
			logger -s -p user.info -t $0 "Switching to $curmode mode" > /dev/console
			ubus call leds set  '{"state" : "allflash"}'
			[ -f /etc/init.d/omcproxy ] && /etc/init.d/omcproxy stop
			[ -f /etc/init.d/layer2 ] && /etc/init.d/layer2 reload
			ubus call network reload
			wifi reload nodat
			ubus call router.network reload
			rm -f /tmp/netmodes/uplink-macaddr-corrected
			correct_uplink
			ubus call leds set  '{"state" : "normal"}'
			rm -f $SWITCHMODELOCK
		;;
		*)
			[ -f /etc/init.d/layer2 ] && /etc/init.d/layer2 reload
			ubus call uci commit '{"config":"network"}'
		;;
	esac
}

wificontrol_takes_over() {
	local ret
	[ -f /sbin/wificontrol ] || return

	ubus call leds set  '{"state" : "allflash"}'

	if pidof wificontrol >/dev/null; then
		ret=0
		# let netmode-conf up to 20 seconds before switching mode
		for tm in 2 4 6 8; do
			if [ -f /tmp/wificontrol.txt ]; then
				ret=1
				break
			fi
			sleep $tm
		done
		# let netmode-conf take over
		[ $ret -eq 1 ] && return 0
	fi

	return 1
}

wait_for_netmode_handler() {
	for tm in 2 4 6 8; do
		if [ ! -f $SWITCHMODELOCK ]; then
			break
		fi
		sleep $tm
	done
}

netmode_get_ip_type() {
	[ -n "$(echo $1 | grep -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)')" ] && {
		logger -t "[netmode]" "netmode_get_ip_type: ip $1 is private"
		echo "private"
	} || {
		logger -t "[netmode]" "netmode_get_ip_type: ip $1 is public"
		echo "public"
	}
}

get_device_of() {
	local PORT_NAMES=$(db get hw.board.ethernetPortNames)
	local PORT_ORDER=$(db get hw.board.ethernetPortOrder)
        local cnt=1
        local idx=0

	local pnum=$(echo $PORT_NAMES | wc -w)

	if [ $pnum -le 2 ]; then
		PORT_NAMES=$(echo $PORT_NAMES | sed 's/LAN/LAN1/g')
	fi

	# get index of interface name
	for i in $PORT_NAMES; do
		if [ "$i" == "$1" ]; then
			idx=$cnt
		fi
		cnt=$((cnt+1))
	done

        # get port name from index
	cnt=1
	for i in $PORT_ORDER; do
		if [ "$cnt" == "$idx" ]; then
			echo $i
		fi
		cnt=$((cnt+1))
	done
}

populate_netmodes() {
	[ -f /etc/config/netmode -a -d $MODEDIR ] || return
	local curmode

	config_load netmode

	config_get curmode setup curmode

	mkdir -p $NMTMPDIR

	if [ "$curmode" == "routed" ]; then
		if [ $MTK -eq 1 ]; then
			curmode="routed_mtk"
		else
			curmode="routed_brcm"
		fi
	fi

	echo $curmode > $OLD_MODE_FILE

	delete_netmode() {
		uci delete netmode.$1
	}

	config_foreach delete_netmode netmode
	uci commit netmode

	wan=$(get_device_of WAN)
	lan1=$(get_device_of LAN1)
	lan2=$(get_device_of LAN2)
	lan3=$(get_device_of LAN3)
	lan4=$(get_device_of LAN4)
	lan5=$(get_device_of LAN5)

	for file in $(find $MODEDIR -type f); do
		conf="$(echo $file | cut -d'/' -f5)"
		if [ "$conf" == "layer2_interface_ethernet" ]; then
			grep -q "\$WAN" $file && sed -i "s/\$WAN/$wan/g" $file
		fi
		if [ "$conf" == "network" ]; then
			grep -q "\$WAN" $file && sed -i "s/\$WAN/$wan/g" $file
			grep -q "\$LAN1" $file && sed -i "s/\$LAN1/$lan1/g" $file
			grep -q "\$LAN2" $file && sed -i "s/\$LAN2/$lan2/g" $file
			grep -q "\$LAN3" $file && sed -i "s/\$LAN3/$lan3/g" $file
			grep -q "\$LAN4" $file && sed -i "s/\$LAN4/$lan4/g" $file

			ifname="$(uci -q get $file.wan.ifname | sed 's/[ \t]*$//')"
			uci -q set $file.wan.ifname="$ifname"
			uci -q commit $file
		fi
	done

	local hardware=$(db get hw.board.hardware)
	local keys lang desc exp exclude
	for mode in $(ls $MODEDIR); do

			case "$mode" in
				repeater*)
					wlctl -i wl1 ap >/dev/null 2>&1 || ifconfig rai0 2>/dev/null | grep -q rai0 || continue
				;;
			esac

			lang=""
			desc=""
			exp=""
			uci -q set netmode.$mode=netmode
			json_load "$(cat $MODEDIR/$mode/DETAILS)"

			if json_select excluded_boards; then
				exclude=0
				_i=1
				while json_get_var board $_i; do
					case "$hardware" in
						$board)
							uci -q delete netmode.$mode
							exclude=1
							break
						;;
					esac
					_i=$((_i+1))
				done
				json_select ..
				[ $exclude -eq 1 ] && continue
			fi

			if json_select acl; then
				_i=1
				while json_get_var user $_i; do
					uci add_list netmode.$mode._access_r="$user"
					_i=$((_i+1))
				done
				json_select ..
			fi

			json_select description
			json_get_keys keys
			for k in $keys; do
				json_get_keys lang $k
				lang=$(echo $lang | sed 's/^[ \t]*//;s/[ \t]*$//')
				json_select $k
				json_get_var desc $lang
				uci -q set netmode.$mode."desc_$lang"="$desc"
				[ "$lang" == "en" ] && uci -q set netmode.$mode."desc"="$desc"
				json_select ..
			done
			json_select ..

			json_select explanation
			json_get_keys keys
			for k in $keys; do
				json_get_keys lang $k
				lang=$(echo $lang | sed 's/^[ \t]*//;s/[ \t]*$//')
				json_select $k
				json_get_var exp $lang
				uci -q set netmode.$mode."exp_$lang"="$exp"
				[ "$lang" == "en" ] && uci -q set netmode.$mode."exp"="$exp"
				json_select ..
			done
			json_select ..

			json_get_var cred credentials
			uci -q set netmode.$mode.askcred="$cred"
			json_get_var ulb uplink_band
			uci -q set netmode.$mode.uplink_band="$ulb"
			json_get_var reboot reboot
			uci -q set netmode.$mode.reboot="$reboot"
	done

	config_get curmode setup curmode
	[ -d /etc/netmodes/$curmode ] || {
		[ $MTK -eq 1 ] && uci -q set netmode.setup.curmode="routed_mtk" || uci -q set netmode.setup.curmode="routed_brcm"
	}

	uci commit netmode
}

start_netmode_tools() {
	local curmode repeaterready

	killall -9 wificontrol >/dev/null 2>&1
	killall -9 netmode-discover >/dev/null 2>&1

	config_load netmode
	config_get_bool repeaterready setup repeaterready 0

	[ $repeaterready -eq 1 ] && {
		/sbin/netmode-discover &
		/sbin/wificontrol --repeater &
		return
	}

	config_get curmode setup curmode

	case "$curmode" in
		repeater*)
			/sbin/netmode-discover &
			/sbin/wificontrol --repeater &
		;;
	esac
}

stop_netmode_tools() {
	killall -9 netmode-discover >/dev/null 2>&1
	killall -9 wificontrol >/dev/null 2>&1
}

