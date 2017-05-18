#!/bin/sh

. /usr/share/libubox/jshn.sh
. /lib/network/ebtables.sh

removeall_vlandevices()
{
	local vif
	local i

	for i in `ls /proc/sys/net/ipv4/conf`; do
		case "$i" in
			[eap][t][mh][0-9].v1)
			;;
			[eap][t][mh][0-9].1)
			;;
			[eap][t][mh][0-9].[v0-9]*)
				vlanctl --if-delete $i
			;;
		esac
	done
}

removevlan()
{
	vlanctl --if-delete $1
}

ifvlanexits()
{
	local vif=$1
	local i

	for i in `ls /proc/sys/net/ipv4/conf`; do
		if [ "$i" == "$vif" ]; then
			return 1
		fi
	done
	return 0
}

ifbaseexists()
{
	local if=$1

	if [ -d /sys/class/net/$if ]; then
		ifcarrier="/sys/class/net/$if/carrier"
		if [ -f $ifcarrier ] && [ "$(cat $ifcarrier)" == "1" ]; then
			return 1
		else
			json_load "$(devstatus "$if")"
			json_get_var link link
			if [ "$link" == "1" ]; then
				return 1
			fi
		fi
	fi
	return 0
}

check_mac_address()
{
	local baseifname="$1"
	local vlan="$2"
	local basemac
	local mac=$(ifconfig -a | grep "^${baseifname}.${vlan} " | awk '{print $NF}')
	local mac_in_use=$(ifconfig -a | grep "$mac" | grep -v "^${baseifname}.${vlan}[ ]")
	if [ "$mac_in_use" ]; then
		basemac=$(ifconfig -a | grep "^$baseifname " | awk '{print $NF}')
		ifconfig ${baseifname}.${vlan} hw ether $basemac
	fi
}

addbrcmvlan()
{
	local baseifname=$1
	local vlan8021p=$2
	local vlan8021q=$3
	local bridge=$4
	local ifname=$5

	bridge="${bridge:-0}"

	ifbaseexists $baseifname
	ret=$?
	if [ "$ret" -eq 1 ]; then
		ifvlanexits "$ifname"
		ret=$?
		echo "first ret=$ret"
		if [ "$ret" -eq 0 ]; then
			ifconfig $baseifname up
			echo "vlanctl --if-create $ifname" > /dev/console

			local unmanaged=0
			local nets net typ proto
			nets=$(get_network_of "$ifname")
			for net in $nets; do
				typ=$(uci -q get network."$net".type)
				proto=$(uci -q get network."$net".proto)
				proto="${proto:-none}"
				if [ "$typ" == "bridge" ]; then
					bridge=1
					if [ "$proto" == "none" ]; then
						unmanaged=1
						break
					fi
				fi
			done

			echo '1' > /proc/sys/net/ipv6/conf/$baseifname/disable_ipv6
			ifconfig $baseifname up

			if [ "$bridge" -eq 1 ]; then
				if [ "$unmanaged" == "1" ]; then
					vlanctl --if-create $baseifname $vlan8021q
				else
					vlanctl --dhcp-bridged --if-create $baseifname $vlan8021q
					check_mac_address $baseifname $vlan8021q
				fi
			else
				vlanctl --routed --if-create $baseifname $vlan8021q
				check_mac_address $baseifname $vlan8021q
			fi

			if [ "$bridge" -eq 1 ]; then
				vlanctl --if $baseifname --set-if-mode-rg
				vlanctl --if $baseifname --tx --tags 0 --default-miss-drop
				vlanctl --if $baseifname --tx --tags 1 --default-miss-drop
				vlanctl --if $baseifname --tx --tags 2 --default-miss-drop
				# tags 0 tx
				vlanctl --if $baseifname --tx --tags 0 --filter-txif $ifname --push-tag --set-vid $vlan8021q 0 --set-pbits $vlan8021p 0 --rule-insert-before -1
				# tags 1 tx
				vlanctl --if $baseifname --tx --tags 1 --filter-txif $ifname --push-tag --set-vid $vlan8021q 0 --set-pbits $vlan8021p 0 --rule-insert-before -1
				# tags 2 tx
				vlanctl --if $baseifname --tx --tags 2 --filter-txif $ifname --push-tag --set-vid $vlan8021q 0 --set-pbits $vlan8021p 0 --rule-insert-before -1
				# tags 1 rx
				vlanctl --if $baseifname --rx --tags 1 --filter-vid $vlan8021q 0 --pop-tag --set-rxif $ifname --rule-insert-before -1
				# tags 2 rx
				vlanctl --if $baseifname --rx --tags 2 --filter-vid $vlan8021q 0 --pop-tag --set-rxif $ifname --rule-insert-before -1
			else
				vlanctl --if $baseifname --set-if-mode-rg
				vlanctl --if $baseifname --tx --tags 0 --default-miss-drop
				vlanctl --if $baseifname --tx --tags 1 --default-miss-drop
				vlanctl --if $baseifname --tx --tags 2 --default-miss-drop
				# tags 0 tx
				vlanctl --if $baseifname --tx --tags 0 --filter-txif $ifname --push-tag --set-vid $vlan8021q 0 --set-pbits $vlan8021p 0 --rule-insert-before -1
				# tags 0 rx
				vlanctl --if $baseifname --rx --tags 0 --set-rxif $ifname --filter-vlan-dev-mac-addr 0 --drop-frame --rule-insert-before -1
				# tags 1 rx
				vlanctl --if $baseifname --rx --tags 1 --set-rxif $ifname --filter-vlan-dev-mac-addr 0 --drop-frame --rule-insert-before -1
				# tags 2 rx
				vlanctl --if $baseifname --rx --tags 2 --set-rxif $ifname --filter-vlan-dev-mac-addr 0 --drop-frame --rule-insert-before -1
				# tags 1 rx
				vlanctl --if $baseifname --rx --tags 1 --filter-vlan-dev-mac-addr 1 --filter-vid $vlan8021q 0 --pop-tag --set-rxif $ifname --rule-insert-before -1
				# tags 2 rx
				vlanctl --if $baseifname --rx --tags 2 --filter-vlan-dev-mac-addr 1 --filter-vid $vlan8021q 0 --pop-tag --set-rxif $ifname --rule-insert-before -1
			fi
			ifconfig $ifname up
			ifconfig $ifname multicast
		fi
	fi
}

update_last_mac_group()
{
	local ifname=$1
	local last_mac_group=$2

	local full_mac modified_mac dev_mac

	full_mac="$(ifconfig $ifname | awk '{print $NF; exit}')"

	[ "${full_mac}" == "" ] && return

	modified_mac="${full_mac:0:15}${last_mac_group}"

	devs="wl0 wl1 bcmsw"

	for dev in $devs; do
		dev_mac="$(ifconfig $dev | awk '{print $NF; exit}')"
		if [ "$dev_mac" == "$modified_mac" ]; then
			return
		fi
	done

	ifconfig $ifname hw ether "${modified_mac}"
}


brcm_virtual_interface_rules()
{
	local baseifname=$1
	local ifname=$2
	local bridge=$3
	local last_mac_group=$4

	bridge="${bridge:-0}"

	local unmanaged=0
	local nets net typ proto
	nets=$(get_network_of "$ifname")
	for net in $nets; do
		typ=$(uci -q get network."$net".type)
		proto=$(uci -q get network."$net".proto)
		proto="${proto:-none}"

		if [ "$typ" == "bridge" ]; then
			bridge=1
			if [ "$proto" == "none" ]; then
				unmanaged=1
				break
			fi
		fi
	done

	echo '1' > /proc/sys/net/ipv6/conf/$baseifname/disable_ipv6
	ifconfig $baseifname up

	if [ "$bridge" -eq 1 ]; then
		if [ "$unmanaged" == "1" ]; then
			vlanctl --if-create-name $baseifname $ifname
		else
			vlanctl --dhcp-bridged --if-create-name $baseifname $ifname
		fi
	else
		vlanctl --routed --if-create-name  $baseifname $ifname
	fi

	[ "$bridge" -eq 1 ] && create_ebtables_bridge_rules

	#set default RG mode
	vlanctl --if $baseifname --set-if-mode-rg
	#Set Default Droprules
	vlanctl --if $baseifname --tx --tags 0 --default-miss-drop
	vlanctl --if $baseifname --tx --tags 1 --default-miss-drop
	vlanctl --if $baseifname --tx --tags 2 --default-miss-drop
	vlanctl --if $baseifname --tx --tags 0 --filter-txif $ifname --rule-insert-before -1

	if [ "$bridge" -eq 1 ]; then
		# tags 1 tx
		vlanctl --if $baseifname --tx --tags 1 --filter-txif $ifname --rule-insert-before -1
		# tags 2 tx
		vlanctl --if $baseifname --tx --tags 2 --filter-txif $ifname --rule-insert-before -1
		# tags 0 rx
		vlanctl --if $baseifname --rx --tags 0 --set-rxif $ifname --rule-insert-last
		# tags 1 rx
		vlanctl --if $baseifname --rx --tags 1 --set-rxif $ifname --rule-insert-last
		# tags 2 rx
		vlanctl --if $baseifname --rx --tags 2 --set-rxif $ifname --rule-insert-last
	else
		# tags 1 rx
		vlanctl --if $baseifname --rx --tags 1 --set-rxif $ifname --filter-vlan-dev-mac-addr 0 --drop-frame --rule-insert-before -1
		# tags 2 rx
		vlanctl --if $baseifname --rx --tags 2 --set-rxif $ifname --filter-vlan-dev-mac-addr 0 --drop-frame --rule-insert-before -1
		# tags 0 rx
		vlanctl --if $baseifname --rx --tags 0 --set-rxif $ifname --filter-vlan-dev-mac-addr 1 --rule-insert-before -1
	fi

	if [ "$last_mac_group" != "" ]; then
		update_last_mac_group $ifname $last_mac_group
	fi

	ifconfig $ifname up
	ifconfig $ifname multicast
}

