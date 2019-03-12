#if wet in wireless config and SSID nad KEY was saved for it, apply to config
#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

parse_wet_json()
{
	local interface=$1
	local mode key encryption ssid connect_bssid

	config_get mode $interface mode
	[ "$mode" = "wet" ] || return

	json_load "$(cat /tmp/netmodecfg)" 2> /dev/null
	json_get_var ssid ssid
	json_get_var key key
	json_get_var encryption encryption
	json_get_var connect_bssid connect_bssid

	uci -q set wireless.$1.key="$key"
	uci -q set wireless.$1.encryption="$encryption"
	uci -q set wireless.$1.ssid="$ssid"
	uci -q set wireless.$1.connect_bssid="$connect_bssid"
	uci commit wireless
}

apply_wet_cfg()
{
	[ -f /tmp/netmodecfg ] || return

	config_load wireless
	config_foreach parse_wet_json "wifi-iface"

	rm /tmp/netmodecfg 2> /dev/null
}

apply_wet_cfg
