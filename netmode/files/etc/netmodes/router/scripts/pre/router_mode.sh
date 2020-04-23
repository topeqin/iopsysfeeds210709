#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

WANPORTS=""
LANPORTS=""

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

		config_get mode $cfg mode "ap"

		if [ "$mode" == "ap" ]; then
			uci -q set wireless.$cfg.network="lan"
		fi
	}

	config_load wireless
	config_foreach add_wdev "wifi-iface"

	uci -q commit wireless
}

add_xtm_devs() {
	local section device vlan

	for section in $(uci show dsl | grep "=.*tm-device" | cut -d'=' -f1); do
		device="$(uci -q get $section.device)"

		if [ -n "$device" ]; then
			vlan="$(get_vlan $device)"
			[ -n "$vlan" ] && device="$vlan"

			if [ -n "$device" ]; then
				WANPORTS="$WANPORTS $device"
			fi
		fi
	done
}

add_eth_ports() {

	add_port()
	{
		local cfg=$1
		local uplink ifname vlan

		config_get ifname $cfg ifname
		config_get_bool uplink $cfg uplink 0
	
		vlan="$(get_vlan $ifname)"
		[ -n "$vlan" ] && ifname="$vlan"

		if [ $uplink -eq 1 ]; then
			WANPORTS="$WANPORTS $ifname"
		else
			LANPORTS="$LANPORTS $ifname"
		fi
	}

	config_load ports
	config_foreach add_port "ethport"
}

add_xtm_devs
add_eth_ports
add_wifi_devs

WANPORTS="$(echo $WANPORTS | sed -e 's/[[:space:]]*$//')"
LANPORTS="$(echo $LANPORTS | sed -e 's/[[:space:]]*$//')"

uci -q set network.wan.type="anywan"
uci -q set network.wan.ifname="$WANPORTS"
uci -q set network.wan6.ifname="@wan"
uci -q set network.lan.type="bridge"
uci -q set network.lan.ifname="$LANPORTS"

ubus call uci commit '{"config":"network"}'

