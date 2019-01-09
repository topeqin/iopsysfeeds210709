#if mode wet in wireless config has SSID Key, save them
#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

parse_wet_cfg()
{
	local interface=$1
	local mode key encryption ssid connect_bssid

	config_get mode $interface mode
	[ "$mode" = "wet" ] || return

	config_get ssid $interface ssid
	config_get key $interface key
	config_get encryption $interface encryption
	config_get connect_bssid $interface connect_bssid

	[ -n "$key" ] || return
	[ -n "$encryption" ] || return

	json_init
	json_add_string "ssid" "$ssid"
	json_add_string "key" "$key"
	json_add_string "encryption" "$encryption"
	json_add_string "connect_bssid" "$connect_bssid"

	echo "`json_dump`" > /tmp/netmodecfg
}

save_wet_cfg()
{
	config_load wireless
	config_foreach parse_wet_cfg "wifi-iface"
}

