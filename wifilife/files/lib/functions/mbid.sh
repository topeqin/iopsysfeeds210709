#!/bin/sh /etc/rc.common

. /usr/share/libubox/jshn.sh
. /lib/functions.sh

get_neighbors() {
	neighbors=""

	json_get_keys keys

	IFS=$' '
	for key in $keys; do
		json_select $key 2>/dev/null
		json_get_var bssid bssid
		neighbors="$neighbors $bssid"
		json_select ..
	done

	echo "$neighbors"
	json_select ..
}

mobid_cb() {
	local device mobility_domain

	config_get device $1 device
	[ "$device" != "$2" ] && return;

	config_get mobility_domain $1 mobility_domain
	echo "$mobility_domain"
}

_get_mobid() {
	vif=$1
	config_load wireless
	mobid="$(config_foreach mobid_cb wifi-iface $vif)"
	echo $mobid
}

match_neigh() {
	neighbor=$1
	assoclist=$2

	neighbor=$(echo "$neighbor" | awk '{print tolower($0)}')

	for mac in $assoclist; do
		[ ${mac:2} = ${neighbor:2} ] || continue
		echo $mac
		break
	done
}

repeated_macs() {
	octets=$1
	oct2=$2
	oct3=$3
	mac=$4
	macs=""
	oct456=${mac:9}

	[ -z "$octets" -o -z "$oct2" -o -z "$oct3" -o -z "$mac" -o -z "$oct456" ] && return

	IFS=$' '
	for oct1 in $octets; do
		macs="$oct1:$oct2:$oct3:$oct456 $macs"
	done

	echo "$macs"
}

# transform a mac address to all possibly repeated - recommended when parsing one or few MACs
mac_to_repeated() {
	mac=$1
	octets=""
	oct2=""
	oct3=""

	octets=$(get_octets)
	mobid=$(get_mobid)
	[ -z "$mobid" -o -z "$octets" ] && return

	oct2="$(echo $mobid | awk '{print $1}')"
	oct3="$(echo $mobid | awk '{print $2}')"

	echo "$(repeated_macs $octets $oct2 $oct3 $mac)"
}

# only get all first octets - use when parsing several MACS
get_octets() {
	octets=""
	assoclist=""
	neighbors=""

	assoc="$(ubus -t1 call wifix assoclist 2>/dev/null)"
	[ -z "$assoc" ] && return

	json_load "$assoc"
	json_select assoclist 2>/dev/null
	json_get_keys keys
	IFS=$' '
	for key in $keys; do
		json_select $key 2>/dev/null
		json_get_var macaddr macaddr
		assoclist="$macaddr $assoclist"
		json_select ..
	done

	list_neighbor="$(ubus -t1 call wifix list_neighbor 2>/dev/null)"
	[ -z "$list_neighbor" ] && return

	json_load "$list_neighbor"
	json_get_keys keys
	for key in $keys; do
		json_select $key 2>/dev/null
		neighbors="$(get_neighbors) $neighbors"
		json_select ..
	done

	for neighbor in $neighbors; do
		bssid=$(match_neigh $neighbor $assoclist)
		octet=$(echo $bssid | cut -c1-2)
		[ "$octets" != "${octets/$octet/}" ] && continue
		octets="$octet $octets"
	done

	echo "$octets"
}

# get only mobid - use when parsing several MACS
get_mobid() {
	mobid="500"

	radios="$(ubus -t1 call wifix radios 2>/dev/null)"
	[ -z "$radios" ] && return

	json_load "$radios"
	json_get_keys keys
	IFS=$' '
	for key in $keys; do
		val="$(_get_mobid $key)"
		[ -n "$val" ] && mobid=$val;
	done

	mobid=$(printf "%04x" $mobid)

	# if little endian
	if [ "$(echo -n I | hexdump -o | awk '{ print substr($2,6,1); exit}')" = "1" ]; then
		oct2=${mobid:2}
		oct3=${mobid%??}
	else
		oct2=${mobid%??}
		oct3=${mobid:2}
	fi

	echo "$oct2 $oct3"
}