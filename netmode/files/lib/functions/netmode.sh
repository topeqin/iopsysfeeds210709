#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

MODEDIR=$(uci -q get netmode.setup.dir)

[ -n "$MODEDIR" ] || MODEDIR="/etc/netmodes"

run_netmode_scripts() {
	local mode=$1
	local when=$2
	local script
	local path

	path=$(readlink -f /etc/netmodes/$mode/)
	[ "${path:0:14}" == "/etc/netmodes/" ] || exit

	if [ -d /etc/netmodes/$mode/scripts/$when ]; then
		logger -s -p user.info -t "netmode" "Executing $when netmode scripts" >/dev/console
		for script in $(ls /etc/netmodes/$mode/scripts/$when/); do
			sh /etc/netmodes/$mode/scripts/$when/$script
		done
	fi
}

switch_netmode() {
	[ -f /etc/config/netmode -a -d $MODEDIR ] || return

	config_load netmode

	local enabled
	config_get_bool enabled setup enabled '0'
	[ $enabled -eq 0 ] && return 

	local mode
	config_get mode setup mode

	[ -d "/etc/netmodes/$mode" ] || return

	logger -s -p user.info -t "netmode" "Switching to $mode Mode" >/dev/console

	run_netmode_scripts $mode "pre"

	local reboot=$(uci -q get netmode.$mode.reboot)

	if [ "$reboot" == "1" ]; then
		#run_netmode_scripts $mode "post"
		reboot &
		exit
	fi

	#run_netmode_scripts $mode "post"
}

populate_netmodes() {
	[ -f /etc/config/netmode -a -d $MODEDIR ] || return

	config_load netmode

	local enabled
	config_get_bool enabled setup enabled '0'
	[ $enabled -eq 0 ] && return 

	delete_netmode() {
		uci delete netmode.$1
	}

	config_foreach delete_netmode netmode
	uci commit netmode

	local hardware=$(db -q get hw.board.model_name)
	local keys lang desc exp exclude support
	for mode in $(ls $MODEDIR); do
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
			elif json_select supported_boards; then
				support=0
				_i=1
				while json_get_var board $_i; do
					case "$hardware" in
						$board)
							support=1
							break
						;;
					esac
					_i=$((_i+1))
				done
				json_select ..
				[ $support -eq 1 ] || {
					uci -q delete netmode.$mode
					continue
				}
			fi

			if json_select acl; then
				_i=1
				while json_get_var user $_i; do
					uci del_list netmode.$mode._access_r="$user"
					uci del_list netmode.$mode._access_w="$user"
					uci add_list netmode.$mode._access_r="$user"
					uci add_list netmode.$mode._access_w="$user"
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

	uci commit netmode
}
