#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

include /lib/network

CONFFILE=/var/mcpd.conf
PROG_EXE=/usr/sbin/mcpd

# Parameters available in snooping configuration
igmp_s_enable=0
igmp_s_version=2
igmp_s_query_interval=125
igmp_s_q_resp_interval=100
igmp_s_last_mem_q_int=10
igmp_s_fast_leave=1
igmp_s_robustness=2
igmp_s_mode=0
igmp_s_iface=""
igmp_s_exceptions=""

mld_s_enable=0
mld_s_version=2
mld_s_robustness=2
mld_s_mode=0
mld_s_iface=""
mld_s_exceptions=""

# Global params
max_groups=25
max_msf=10
max_members=25
mldv1_unsolicited_report_interval=10
mldv2_unsolicited_report_interval=1

# Parameters available in proxy configuration
igmp_p_enable=0
igmp_p_version=2
igmp_query_interval=125
igmp_q_resp_interval=100
igmp_last_mem_q_int=10
igmp_fast_leave=1
igmp_p_robustness=2
igmp_p_mode=0
igmp_p_up_interfaces=""
igmp_p_down_interfaces=""
igmp_p_exceptions=""

mld_p_enable=0
mld_p_version=1
mld_query_interval=125
mld_q_resp_interval=100
mld_last_mem_q_int=10
mld_fast_leave=1
mld_p_robustness=2
mld_p_mode=0
mld_p_up_interfaces=""
mld_p_down_interfaces=""
mld_p_exceptions=""

# Standard parameters need by BCM's multicast daemon
l_2_l_mcast=0
allow_brdevice=0

proxdevs=""
ethwan="$(db -q get hw.board.ethernetWanPort)"

read_snooping() {
	local config="$1"
	local sec_enable
	local proto

	config_get sec_enable "$config" enable 0
	config_get proto "$config" proto

	if [ "$sec_enable" == "0" ]; then
		return
	fi

	if [ "$proto" == "igmp" ]; then
		igmp_s_enable=$sec_enable
		config_get igmp_s_version "$config" version 2
		config_get igmp_s_query_interval "$config" query_interval 125
		config_get igmp_s_q_resp_interval "$config" query_response_interval 100
		config_get igmp_s_last_mem_q_int "$config" last_member_query_interval 10
		config_get igmp_s_fast_leave "$config" fast_leave 1
		config_get igmp_s_robustness "$config" robustness 2
		config_get igmp_s_mode "$config" snooping_mode 0
		config_get igmp_s_iface "$config" interface
		config_get igmp_s_exceptions "$config" filter
		config_get l_2_l_mcast "$config" lan_to_lan
		return
	fi

	if [ "$proto" == "mld" ]; then
		mld_s_enable=$sec_enable
		config_get mld_s_version "$config" version 2
		config_get mld_s_query_interval "$config" query_interval 125
		config_get mld_s_q_resp_interval "$config" query_response_interval 100
		config_get mld_s_last_mem_q_int "$config" last_member_query_interval 10
		config_get mld_s_fast_leave "$config" fast_leave 1
		config_get mld_s_robustness "$config" robustness 2
		config_get mld_s_mode "$config" snooping_mode 0
		config_get mld_s_iface "$config" interface
		config_get mld_s_exceptions "$config" filter
		config_get l_2_l_mcast "$config" lan_to_lan
		return
	fi
}

read_proxy() {
	local config="$1"
	local sec_enable
	local proto

	config_get sec_enable "$config" enable 0
	config_get proto "$config" proto

	if [ "$sec_enable" == "0" ]; then
		return
	fi

	if [ "$proto" == "igmp" ]; then
		igmp_p_enable=$sec_enable
		config_get igmp_p_version "$config" version 2
		config_get igmp_query_interval "$config" query_interval 125
		config_get igmp_q_resp_interval "$config" query_response_interval 100
		config_get igmp_last_mem_q_int "$config" last_member_query_interval 10
		config_get igmp_fast_leave "$config" fast_leave 1
		config_get igmp_p_robustness "$config" robustness 2
		config_get igmp_p_mode "$config" snooping_mode 0
		config_get igmp_p_up_interfaces "$config" upstream_interface
		config_get igmp_p_down_interfaces "$config" downstream_interface
		config_get igmp_p_exceptions "$config" filter
		config_get l_2_l_mcast "$config" lan_to_lan
		return
	fi

	if [ "$proto" == "mld" ]; then
		mld_p_enable=$sec_enable
		config_get mld_p_version "$config" version 2
		config_get mld_query_interval "$config" query_interval 125
		config_get mld_q_resp_interval "$config" query_response_interval 100
		config_get mld_last_mem_q_int "$config" last_member_query_interval 10
		config_get mld_fast_leave "$config" fast_leave 1
		config_get mld_p_robustness "$config" robustness 2
		config_get mld_p_mode "$config" snooping_mode 0
		config_get mld_p_up_interfaces "$config" upstream_interface
		config_get mld_p_down_interfaces "$config" downstream_interface
		config_get mld_p_exceptions "$config" filter
		config_get l_2_l_mcast "$config" lan_to_lan
		return
	fi
}

config_snooping_common_params() {
	local protocol="$1"
	echo "${protocol}-default-version $2" >> $CONFFILE
	echo "${protocol}-robustness-value $3" >> $CONFFILE
	echo "${protocol}-max-groups $max_groups" >> $CONFFILE 
	echo "${protocol}-max-sources $max_msf" >> $CONFFILE
	echo "${protocol}-max-members $max_members" >> $CONFFILE
	echo "${protocol}-snooping-enable $4" >> $CONFFILE
}

config_mcast_querier_params() {
	local protocol="$1"
	local query_interval=$2
	local q_resp_interval=$3
	local last_mem_q_int=$4

	echo "${protocol}-query-interval $query_interval" >> $CONFFILE
	echo "${protocol}-query-response-interval $q_resp_interval" >> $CONFFILE
	echo "${protocol}-last-member-query-interval $last_mem_q_int" >> $CONFFILE
}

config_snooping_on_bridge() {
	local protocol="$1"
	local bcm_mcast_p=1
	echo "${protocol}-snooping-interfaces $2" >> $CONFFILE

	[ "$protocol" == "mld" ] && bcm_mcast_p=2

	for snpif in $2; do
		case "$snpif" in
			br-*)
				# set snooping mode on the bridge
				bcmmcastctl mode -i $snpif -p $bcm_mcast_p -m $3
				# set L2L snooping mode on the bridge
				bcmmcastctl l2l -i $snpif -p $bcm_mcast_p -e $l_2_l_mcast # set L2L snooping mode on the bridge
			;;
		esac
	done
}

handle_bridged_proxy_interface() {
	local p2="$1"
	local p_enable=0

	if [ "$p2" == "igmp" ]; then
		p_enable=$igmp_p_enable
	else
		p_enable=$mld_p_enable
	fi

	if [ $p_enable -eq 1 -a $allow_brdevice -eq 1 ]
	then
		proxdevs="$proxdevs $2"
		echo "upstream-interface $2" >>$CONFFILE
	else
		json_load "$(devstatus $2)"
		itr=1
		json_select bridge-members
		while json_get_var dev $itr; do
			case "$dev" in
				*.*)
					port="$(echo "$dev" | cut -d'.' -f 1)"
					if [ $port == $ethwan ]; then
						ifconfig $dev | grep RUNNING >/dev/null && proxdevs="$proxdevs $dev" && break
					fi
					;;
			esac
			itr=$(($itr + 1))
		done
		json_select ..
	fi
}

config_mcast_proxy_interface() {
	local itr
	local p1="$1"
	local p_enable

	if [ "$p1" == "igmp" ]; then
		p_enable=$igmp_p_enable
	else
		p_enable=$mld_p_enable
	fi

	for proxif in $2; do
		case "$proxif" in
			br-*)
				handle_bridged_proxy_interface $p1 $proxif
			;;
			*)
				ifconfig $proxif | grep RUNNING >/dev/null && proxdevs="$proxdevs $proxif"
			;;
		esac
	done

	if [ $p_enable -eq 1 ]; then
		echo "${p1}-proxy-interfaces $proxdevs" >> $CONFFILE
	fi

	[ -n "$proxdevs" ] && echo "${p1}-mcast-interfaces $proxdevs" >> $CONFFILE
}

configure_mcpd_snooping() {
	local protocol="$1"
	local exceptions
	local filter_ip=""
	local fast_leave=0
	
	# Configure snooping related params
	if [ "$protocol" == "igmp" ]; then
		config_snooping_common_params $protocol $igmp_s_version $igmp_s_robustness $igmp_s_mode
		config_mcast_querier_params $protocol $igmp_s_query_interval $igmp_s_q_resp_interval $igmp_s_last_mem_q_int
		config_mcast_proxy_interface $protocol "$igmp_s_iface"
		config_snooping_on_bridge $protocol $igmp_s_iface $igmp_s_mode
		exceptions=$igmp_s_exceptions
		fast_leave=$igmp_s_fast_leave
	elif [ "$protocol" == "mld" ]; then
		config_snooping_common_params $protocol $mld_s_version $mld_s_robustness $mld_s_mode
		config_mcast_querier_params $protocol $mld_s_query_interval $mld_s_q_resp_interval $mld_s_last_mem_q_int
		config_mcast_proxy_interface $protocol "$mld_s_iface"
		config_snooping_on_bridge $protocol $mld_s_iface $mld_s_mode
		exceptions=$mld_s_exceptions
		fast_leave=$mld_s_fast_leave
	fi

	echo "${protocol}-proxy-enable 0" >> $CONFFILE
	echo "${protocol}-fast-leave $fast_leave" >> $CONFFILE

	if [ -n "$exceptions" ]; then
		IFS=" "
		for excp in $exceptions; do
			case $excp in
			*/*)
				tmp="$(ipcalc.sh $excp | grep IP | awk '{print substr($0,4)}')"
				tmp1="$(ipcalc.sh $excp | grep NETMASK | awk '{print substr($0,9)}')"
				filter_ip="$filter_ip $tmp/$tmp1"
				;;
			*)
				filter_ip="$filter_ip $excp"
				;;
			esac
		done
		echo "${protocol}-mcast-snoop-exceptions $filter_ip" >> $CONFFILE
	fi
}

configure_mcpd_proxy() {
	local protocol="$1"
	local fast_leave=0
	local exceptions=""

	# Configure snooping related params
	if [ "$protocol" == "igmp" ]; then
		config_snooping_common_params $protocol $igmp_p_version $igmp_p_robustness $igmp_p_mode
		config_mcast_querier_params $protocol $igmp_query_interval $igmp_q_resp_interval $igmp_last_mem_q_int
		config_mcast_proxy_interface $protocol "$igmp_p_up_interfaces"
		config_snooping_on_bridge $protocol $igmp_p_down_interfaces $igmp_p_mode
		fast_leave=$igmp_fast_leave
		exceptions=$igmp_p_exceptions
	elif [ "$protocol" == "mld" ]; then
		config_snooping_common_params $protocol $mld_p_version $mld_p_robustness $mld_p_mode
		config_mcast_querier_params $protocol $mld_query_interval $mld_q_resp_interval $mld_last_mem_q_int
		config_mcast_proxy_interface $protocol "$mld_p_up_interfaces"
		config_snooping_on_bridge $protocol $mld_p_down_interfaces $mld_p_mode
		fast_leave=$mld_fast_leave
		exceptions=$mld_p_exceptions
	fi

	# This function will only be hit in case proxy is enabled, so hard coding
	# proxy enable should not be a problem
	echo "${protocol}-proxy-enable 1" >> $CONFFILE
	echo "${protocol}-fast-leave $fast_leave" >> $CONFFILE

	if [ -n "$exceptions" ]; then
		IFS=" "
		for excp in $exceptions; do
			case $excp in
			*/*)
				tmp="$(ipcalc.sh $excp | grep IP | awk '{print substr($0,4)}')"
				tmp1="$(ipcalc.sh $excp | grep NETMASK | awk '{print substr($0,9)}')"
				filter_ip="$filter_ip $tmp/$tmp1"
				;;
			*)
				filter_ip="$filter_ip $excp"
				;;
			esac
		done
		echo "${protocol}-mcast-snoop-exceptions $filter_ip" >> $CONFFILE
	fi
}

disable_snooping() {
	local bcm_mcast_p=$1

	for br in $(brctl show | grep 'br-' | awk '{print$1}' | tr '\n' ' '); do
		bcmmcastctl mode -i $br -p $bcm_mcast_p -m 0 # disable snooping on all bridges
		bcmmcastctl l2l -i $br -p $bcm_mcast_p -e 0 # disable L2L snooping on all bridges
	done
}

configure_mcpd() {
	disable_snooping 1
	disable_snooping 2

	# BCM's mcpd does not allow configuration of proxy and L2 snooping simultaneously, hence
	# here, if proxy is to be configured then the configuration params of snooping are ignored.
	if [ "$igmp_p_enable" == "1" ]; then
		configure_mcpd_proxy igmp
	elif [ "$igmp_s_enable" == "1" ]; then
		configure_mcpd_snooping igmp
	fi

	proxdevs=""
	if [ "$mld_p_enable" == "1" ]; then
		configure_mcpd_proxy mld
	elif [ "$mld_s_enable" == "1" ]; then
		configure_mcpd_snooping mld
	fi
}

read_mcast_snooping_params() {
	config_load mcast
	config_foreach read_snooping snooping
}

read_mcast_proxy_params() {
	config_load mcast
	config_foreach read_proxy proxy
}

config_global_params() {
	local igmp_qrv
	local igmp_force_version
	local mld_qrv
	local mld_force_version

	config_load mcast
	config_get max_msf igmp max_msf 10
	config_get max_groups igmp max_membership 25
	config_get igmp_qrv igmp qrv 2
	config_get igmp_force_version igmp force_version 0

	config_get mld_qrv mld qrv 2
	config_get mldv1_unsolicited_report_interval mld mldv1_unsolicited_report_interval 10
	config_get mldv2_unsolicited_report_interval mld mldv2_unsolicited_report_interval 1
	config_get mld_force_version mld force_version 0

	# mcpd internally writes max_groups and max_msf, no need to modify
	# here directly
	echo $igmp_qrv > /proc/sys/net/ipv4/igmp_qrv
	echo $igmp_force_version > /proc/sys/net/ipv4/conf/all/force_igmp_version

	echo $mld_qrv >  /proc/sys/net/ipv6/mld_qrv
	echo $mld_force_version > /proc/sys/net/ipv6/conf/all/force_mld_version
	echo $mldv1_unsolicited_report_interval > /proc/sys/net/ipv6/conf/all/mldv1_unsolicited_report_interval
	echo $mldv2_unsolicited_report_interval > /proc/sys/net/ipv6/conf/all/mldv2_unsolicited_report_interval
}

setup_mcast_mode() {
	# set the mode at chip to allow both tagged and untagged multicast forwarding
	bs /b/c iptv lookup_method=group_ip_src_ip
}

configure_mcast() {
	rm -f $CONFFILE
	touch $CONFFILE

	config_global_params

	read_mcast_snooping_params
	read_mcast_proxy_params

	configure_mcpd
}

read_mcast_stats() {
	cat /proc/net/igmp_snooping > /tmp/igmp_stats
	local mcast_addrs=""
	local ifaces=""

	while read line; do
	# reading each line
		case $line in
		br-*)
			found_iface=0
			snoop_iface="$(echo $line | awk -F ' ' '{ print $1 }')"
			if [ -z "$ifaces" ]; then
				ifaces="$snoop_iface"
				continue
			fi

			IFS=" "
			for ifx in $ifaces; do
				if [ $ifx == $snoop_iface ]; then
					found_iface=1
					break
				fi
			done

			if [ $found_iface -eq 0 ]; then
				ifaces="$ifaces $snoop_iface"
				continue
			fi
			;;
		esac
	done < /tmp/igmp_stats

	while read line; do
	# reading each line
		case $line in
		br-*)
			found_ip=0
			grp_ip="$(echo $line | awk -F ' ' '{ print $9 }')"
			if [ -z "$mcast_addrs" ]; then
				mcast_addrs="$grp_ip"
				continue
			fi

			IFS=" "
			for ip_addr in $mcast_addrs; do
				if [ $ip_addr == $grp_ip ]; then
					found_ip=1
					break
				fi
			done

			if [ $found_ip -eq 0 ]; then
				mcast_addrs="$mcast_addrs $grp_ip"
				continue
			fi
			;;
		esac
	done < /tmp/igmp_stats

	json_init
	json_add_array "snooping"
	json_add_object ""
	IFS=" "
	for intf in $ifaces; do
		while read line; do
		# reading each line
			case $line in
			br-*)
				snoop_iface="$(echo $line | awk -F ' ' '{ print $1 }')"
				if [ "$snoop_iface" != "$intf" ]; then
					continue
				fi
				json_add_string "interface" "$intf"
				json_add_array "groups"
				break
				;;
			esac
		done < /tmp/igmp_stats
		IFS=" "
		for gip_addr in $mcast_addrs; do
			grp_obj_added=0
			while read line; do
			# reading each line
				case $line in
				br-*)
					snoop_iface="$(echo $line | awk -F ' ' '{ print $1 }')"
					if [ "$snoop_iface" != "$intf" ]; then
						continue
					fi
					grp_ip="$(echo $line | awk -F ' ' '{ print $9 }')"
					if [ "$grp_ip" != "$gip_addr" ]; then
						continue
					fi
					if [ $grp_obj_added -eq 0 ]; then
						json_add_object ""
						gip="$(ipcalc.sh $gip_addr | grep IP | awk '{print substr($0,4)}')"
						json_add_string "groupaddr" "$gip"
						json_add_array "clients"
						grp_obj_added=1
					fi

					json_add_object ""
					host_ip="$(echo $line | awk -F ' ' '{ print $13 }')"
					h_ip="$(ipcalc.sh $host_ip | grep IP | awk '{print substr($0,4)}')"
					json_add_string "ipaddr" "$h_ip"
					src_port="$(echo $line | awk -F ' ' '{ print $2 }')"
					json_add_string "device" "$src_port"
					timeout="$(echo $line | awk -F ' ' '{ print $14 }')"
					json_add_int "timeout" "$timeout"
					json_close_object #close the associated device object
					;;
				esac
			done < /tmp/igmp_stats
			json_close_array #close the associated devices array
			json_close_object # close the groups object
		done # close the loop for group addresses
		json_close_array #close the groups array
	done # close the loop for interfaces
	json_close_object # close the snooping object
	json_close_array # close the snooping array
	json_dump

	rm -f /tmp/igmp_stats
}
