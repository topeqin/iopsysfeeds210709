#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

BRIDGEPORTS=""

get_vlan() {
	local device="$1"
	for section in $(uci show network | grep "=device" | cut -d '=' -f1); do
		if [ "$(uci -q get $section.ifname)" == "$device" ]; then
			uci -q get $section.name
			break
		fi
	done
}

add_wifi_devs()
{

	add_wdev()
	{
		local cfg=$1
#		local disabled

#		config_get_bool disabled $cfg disabled 0
#		config_get_bool ifname $cfg ifname
	
#		if [ $disabled -eq 0 -a -n "$ifname" ]; then
#			BRIDGEPORTS="$ifname"
#		fi

		uci -q set wireless.$cfg.network="wan"
	}

	config_load wireless
	config_foreach add_wdev "wifi-iface"

	uci -q commit wireless
}

add_xtm_devs() {
	local section device vlan

	for section in $(uci show dsl | grep "=.*tm-device" | cut -d'=' -f1); do
		if [ -n "$(uci -q get $section.device)" ]; then

			vlan="$(get_vlan $device)"
			[ -n "$vlan" ] && device="$vlan"
		
			if [ -n "$device" ]; then
				BRIDGEPORTS="$BRIDGEPORTS $device"
			fi

		fi
	done
}

add_eth_ports() {

	add_port()
	{
		local cfg=$1
		local ifname vlan

		config_get ifname $cfg ifname

		vlan="$(get_vlan $ifname)"
		[ -n "$vlan" ] && ifname="$vlan"
	
		if [ -n "$ifname" ]; then
			BRIDGEPORTS="$BRIDGEPORTS $ifname"
		fi
	}

	config_load ports
	config_foreach add_port "ethport"
}

add_xtm_devs
add_eth_ports
add_wifi_devs

BRIDGEPORTS="$(echo $BRIDGEPORTS | sed -e 's/[[:space:]]*$//')"

uci -q set network.wan.type="bridge"
uci -q set network.wan.ifname="$BRIDGEPORTS"
uci -q set network.wan6.ifname="@wan"
uci -q delete network.lan.ifname

ubus call uci commit '{"config":"network"}'

