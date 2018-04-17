#!/bin/sh

# functions that take dhcp options received on the wan interface
# and relay/repeat them for specific clients

#config dhcp_option_relay
#	option enable 1
#	list dhcp_option 43
#	list from_interface wan
#	option vendorclass '*SDX*'

# where:
# dhcp_option_relay is the name of the section parsed by this script
# enable/enabled - option, enable the uci section [default on]
# dhcp_option/dhcp_options - list of dhcp options (0-255) to be relayed/repeated
# overwrite - if same dhcp_option already exists in /etc/config/dhcp, overwrite it with this option [default off]
# from_interface - list of interfaces (e.g. wan) to get the dhcp options from


. /lib/functions.sh

interface=""
opt224=""
opt225=""
opt226=""
opt43=""
opt128=""
opt66=""
opt67=""
opt132=""
opt133=""
newsectionid="0"

function parse_the_json()
{
	local the_json="$@"
	
	json_load "$the_json"
	json_get_var interface interface
	json_get_var opt224 privopt224
	json_get_var opt225 privopt225
	json_get_var opt226 privopt226
	json_get_var opt43 vendorspecinf # option 43
	json_get_var opt128 httpurl128
	json_get_var opt66 tftp # option 66
	json_get_var opt67 bootfile #option 67
	json_get_var opt132 vlanid # option 132
	json_get_var opt133 vlanpriority # option 133
}

function add_section_dhcp_vendorclass()
{
	local dhcp_option=$1
	local dhcp_option_value=$2
	local vendorclass=$3
	local new=
	newsectionid=$((newsectionid+1))

	#echo "add_section_dchp_vendorclass $dhcp_option ${dhcp_option_value} $vendorclass"
	new=$(uci add dhcp vendorclass)
	uci set dhcp.$new.vendorclass="$vendorclass"
	uci set dhcp.$new.networkid="dhcp_option_relay_$newsectionid"
	uci add_list dhcp.$new.dhcp_option=$dhcp_option,\"${dhcp_option_value}\"

	uci commit dhcp
}

function dhcp_option_relay()
{
	local section="$1"
	local enable="" enabled=""
	local dhcp_option="" dhcp_option_value=""
	local vendorclass=""
	#local overwrite=""
	local from_interface

	#echo "section: $section"

	# parse only enabled sections
	config_get_bool enabled $section enabled 1
	config_get_bool enable  $section enable  1
	#echo "enabled: $enabled"
	#echo "enable : $enable"
	if [ "$enable" == "0" -o "$enabled" == "0" ] ; then
		#echo "section $section is not enabled"
		return
	fi
	# todo: for disabled sections: run only the removal of the dhcp options

	# option overwrite 1
	#config_get_bool overwrite $section overwrite 0
	config_get vendorclass $section vendorclass
	if [ ${#vendorclass} -le 1 ]; then
		#echo "vendorclass must not be empty"
		return
	fi

	# list to_interface lan
	# to_interface - list of interfaces (e.g. lan, guest) to advertise the dhcp options to
	#foreach_to_interface() {
	#	local to_interface=$1
	#	echo ""
	#	echo "  from_interface $from_interface"
	#	echo "  dhcp_option $dhcp_option"
	#	echo "  dhcp_option_value $dhcp_option_value"
	#	echo "  overwrite $overwrite"
	#	echo "  to_interface $to_interface"
	#
	#	if [ ! $(uci -q get dhcp.$to_interface) ] ; then
	#		echo "to_interface $to_interface does not exist in dhcp uci config"
	#		return
	#	fi
	#
	#}


	foreach_dhcp_option() {
		dhcp_option=$1

		echo "dhcp_option: $dhcp_option"
		case $dhcp_option in
		43) dhcp_option_value=$opt43 ;;
		66) dhcp_option_value=$opt66 ;;
		67) dhcp_option_value=$opt67 ;;
		128) dhcp_option_value=$opt128 ;;
		132) dhcp_option_value=$opt132 ;;
		133) dhcp_option_value=$opt133 ;;
		224) dhcp_option_value=$opt224 ;;
		225) dhcp_option_value=$opt225 ;;
		226) dhcp_option_value=$opt226 ;;
		*) dhcp_option_value="unsupported" ;;
		esac

		if [ "${dhcp_option_value}" == "unsupported" ] ; then
			echo "dhcp_option $dhcp_option is unsupported"
			return
		fi
		if [ "${dhcp_option_value}" == "" ] ; then
			echo "dhcp_option $dhcp_option is empty"
			return
		fi

		#echo "dhcp_option: $dhcp_option dhcp_option_value: ${dhcp_option_value}"

		#config_list_foreach $section to_interface foreach_to_interface

		add_section_dhcp_vendorclass $dhcp_option ${dhcp_option_value} $vendorclass
	}

	foreach_from_interface() {
		from_interface="$1"
		#echo "from_interface: $from_interface"
		if [ "$from_interface" != "$interface" ]; then
			return
		fi

		dhcp_option=""
		config_list_foreach $section dhcp_option foreach_dhcp_option
		#config_list_foreach $section dhcp_options foreach_dhcp_option
	}

	from_interface=""
	config_list_foreach $section from_interface foreach_from_interface
}


# in uci dhcp config:
# remove all the vendorclass sections
# that have previosly been configured by this script.
# all are identified by "option networkid dhcp_option_relay_*"
function dhcp_option_relay_clear_prev()
{
	local to_remove=""

	foreach_vendorclass() {
		local section="$1"
		local networkid
		config_get networkid $section networkid

		case "$networkid"
		in dhcp_option_relay*)
			to_remove="$to_remove $section"
			;;
		esac
	}

	config_load dhcp
	config_foreach foreach_vendorclass vendorclass

	local sect
	for sect in $to_remove ; do
		uci_remove dhcp $sect
	done
	uci_commit dhcp
}


# the main function
function dhcp_option_relay_parse()
{
	local the_json="$@"
	parse_the_json "$the_json"

	dhcp_option_relay_clear_prev

	newsectionid="0"

	config_load provisioning
	config_foreach dhcp_option_relay dhcp_option_relay
	#config_foreach dhcp_option_relay dhcp_options_relay
	#config_foreach dhcp_option_relay dhcpoption_relay
	#config_foreach dhcp_option_relay dhcpoptions_relay
	#config_foreach dhcp_option_relay dhcp_optionrelay
	#config_foreach dhcp_option_relay dhcp_optionsrelay
	#config_foreach dhcp_option_relay dhcpoptionrelay
	#config_foreach dhcp_option_relay dhcpoptionsrelay
}

#dhcp_option_relay_parse
