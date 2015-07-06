#!/bin/sh
INCLUDE_ONLY=1

. /lib/functions.sh
. ../netifd-proto.sh
init_proto "$@"

proto_4g_init_config() {
	proto_config_add_string "modem"
	proto_config_add_string "service"
	proto_config_add_string "comdev"
	proto_config_add_string "ipaddr"
	proto_config_add_string "netmask"
	proto_config_add_string "hostname"
	proto_config_add_string "clientid"
	proto_config_add_string "vendorid"
	proto_config_add_boolean "broadcast"
	proto_config_add_string "reqopts"
	proto_config_add_string "apn"
	proto_config_add_string "username"
	proto_config_add_string "password"
	proto_config_add_boolean "lte_apn_use"
	proto_config_add_string "lte_apn"
	proto_config_add_string "lte_username"
	proto_config_add_string "lte_password"
	proto_config_add_string "pincode"
	proto_config_add_string "technology"
	proto_config_add_string "auto"
}

proto_4g_setup() {
	local config="$1"
	local iface="$2"

        local ipaddr hostname clientid vendorid broadcast reqopts iface6rd sendopts delegate zone6rd zone
        json_get_vars ipaddr hostname clientid vendorid broadcast reqopts iface6rd sendopts delegate zone6rd zone

        local opt dhcpopts
        for opt in $reqopts; do
                append dhcpopts "-O $opt"
        done

        for opt in $sendopts; do
                append dhcpopts "-x $opt"
        done

        [ "$broadcast" = 1 ] && broadcast="-B" || broadcast=
        [ -n "$clientid" ] && clientid="-x 0x3d:${clientid//:/}" || clientid="-C"
        [ -n "$iface6rd" ] && proto_export "IFACE6RD=$iface6rd"
        [ "$iface6rd" != 0 -a -f /lib/netifd/proto/6rd.sh ] && append dhcpopts "-O 212"
        [ -n "$zone6rd" ] && proto_export "ZONE6RD=$zone6rd"
        [ -n "$zone" ] && proto_export "ZONE=$zone"
        [ "$delegate" = "0" ] && proto_export "IFACE6RD_DELEGATE=0"

        json_get_var comdev comdev
        json_get_var apn apn
        json_get_var service service
        json_get_var pincode pincode


#	if [ -n "$modem" ]; then
#		service=$(echo $modem | cut -d':' -f1)
#		comdev=$(echo $modem | cut -d':' -f2)
#		iface=$(echo $modem | cut -d':' -f3)
#	fi
	
	case "$service" in
		ecm)
		;;
		eem)
		;;
		mbim)
			local mbimdev=/dev/$(basename $(ls /sys/class/net/${iface}/device/usb/cdc-wdm* -d))
			local comdev="${comdev:-$mbimdev}"
			[ -n "$pincode" ] && {
				if ! mbimcli -d $comdev --query-pin-state 2>&1 | grep -q "unlocked"; then
					set -o pipefail
					if ! mbimcli -d $comdev --enter-pin="${pincode}" 2>&1; then
						mbimcli -d $comdev --query-pin-state
						proto_notify_error "$config" PIN_FAILED
						proto_block_restart "$interface"
						return 1
					fi
				fi
			}
			APN="$apn" mbim-network $comdev start
		;;
		ncm)
			[ -n "$pincode" ] && echo $pincode | gcom -d $comdev
			USE_APN="$apn" gcom -d $comdev -s /etc/gcom/ncmconnection.gcom
		;;
		qmi)
			local qmidev=/dev/$(basename $(ls /sys/class/net/${iface}/device/usb/cdc-wdm* -d))
			local comdev="${comdev:-$qmidev}"
			[ -n "$pincode" ] && {
				if ! qmicli -d $comdev --dms-uim-get-pin-status 2>&1 | grep -q "enabled-verified\|disabled" >/dev/null; then
					set -o pipefail
					if ! qmicli -d $comdev --dms-uim-verify-pin="PIN,${pincode}" 2>&1; then
						qmicli -d $comdev --dms-uim-get-pin-status
						proto_notify_error "$config" PIN_FAILED
						proto_block_restart "$interface"
						return 1
					fi
				fi
			}
			APN="$apn" qmi-network $comdev start
		;;		
	esac
	
	proto_export "INTERFACE=$config"
	proto_run_command "$config" udhcpc -R \
		-p /var/run/udhcpc-$iface.pid \
		-s /lib/netifd/dhcp.script \
		-f -t 0 -i "$iface" \
		${ipaddr:+-r $ipaddr} \
		${hostname:+-H $hostname} \
		${vendorid:+-V $vendorid} \
		$clientid $broadcast $dhcpopts
}

proto_4g_teardown() {
	local interface="$1"
	local iface="$2"
	local modem service comdev

        config_load network
        config_get service $interface service
        config_get comdev $interface comdev

#	config_get modem $interface modem
#	if [ -n "$modem" ]; then
#		service=$(echo $modem | cut -d':' -f1)
#		comdev=$(echo $modem | cut -d':' -f2)
#		iface=$(echo $modem | cut -d':' -f3)
#	fi
	
	case "$service" in
		ecm)
		;;
		eem)
		;;
		mbim)
			local mbimdev=/dev/$(basename $(ls /sys/class/net/${iface}/device/usb/cdc-wdm* -d))
			local comdev="${comdev:-$mbimdev}"
			mbim-network $comdev stop
		;;
		ncm)
			USE_DISCONNECT=1 gcom -d $comdev -s /etc/gcom/ncmconnection.gcom
		;;
		qmi)
			local qmidev=/dev/$(basename $(ls /sys/class/net/${iface}/device/usb/cdc-wdm* -d))
			local comdev="${comdev:-$qmidev}"
			qmi-network $comdev stop
		;;		
	esac
	proto_kill_command "$interface"
}

add_protocol 4g
