#!/bin/sh

. /lib/functions.sh
. /usr/share/libubox/jshn.sh

include /lib/network

CONFFILE=/var/mcpd.conf
PROG_EXE=/usr/sbin/mcpd

# Parameters available in snooping configuration
s_enable=0
s_version=2
s_robustness=2
s_interface=""
s_exceptions=""

# Parameters available in proxy configuration
p_enable=0
p_version=2
query_interval=125
q_resp_interval=100
last_mem_q_int=10
max_groups=25
max_msf=10
max_members=25
fast_leave=1
p_robustness=2
p_up_interfaces=""
p_down_interfaces=""
p_exceptions=""

# Standard parameters need by BCM's multicast daemon
l_2_l_mcast=0
bcm_mcast_p=1
allow_brdevice=0

proxdevs=""
ethwan="$(db -q get hw.board.ethernetWanPort)"

read_snooping() {
	local config="$1"
	config_get s_enable "$config" enable 0

	if [ "$s_enable" == "0" ]; then
		return
	fi

	config_get s_version "$config" version 2
	config_get s_robustness "$config" robustness 2
	config_get s_interface "$config" interface
	config_get s_exceptions "$config" filter
}

read_proxy() {
	local config="$1"
	config_get p_enable "$config" enable 0

	if [ "$p_enable" == "0" ]; then
		return
	fi

	config_get p_version "$config" version 2
	config_get query_interval "$config" query_interval
	config_get q_resp_interval "$config" query_response_interval
	config_get last_mem_q_int "$config" last_member_query_interval
	config_get fast_leave "$config" fast_leave 1
	config_get p_robustness "$config" robustness 2
	config_get p_up_interfaces "$config" upstream_interface
	config_get p_down_interfaces "$config" downstream_interface
	config_get p_exceptions "$config" filter
}

config_igmps_common_params() {
	echo "igmp-default-version $1" >> $CONFFILE
	echo "igmp-robustness-value $2" >> $CONFFILE
	echo "igmp-max-groups $max_groups" >> $CONFFILE 
	echo "igmp-max-sources $max_msf" >> $CONFFILE
	echo "igmp-max-members $max_members" >> $CONFFILE
	echo "igmp-snooping-enable $3" >> $CONFFILE
}

config_igmp_querier_params() {
	echo "igmp-query-interval $query_interval" >> $CONFFILE
	echo "igmp-query-response-interval $q_resp_interval" >> $CONFFILE
	echo "igmp-last-member-query-interval $last_mem_q_int" >> $CONFFILE
}

config_snooping_on_bridge() {
	echo "igmp-snooping-interfaces $1" >> $CONFFILE

	for snpif in $1; do
		case "$snpif" in
			br-*)
				# set snooping mode on the bridge
				bcmmcastctl mode -i $snpif -p $bcm_mcast_p -m $2
				# set L2L snooping mode on the bridge
				bcmmcastctl l2l -i $snpif -p $bcm_mcast_p -e $l_2_l_mcast # set L2L snooping mode on the bridge
			;;
		esac
	done
}

handle_bridged_proxy_interface() {
	bridged=1
	if [ $p_enable -eq 1 -a $allow_brdevice -eq 1 ]
	then
		proxdevs="$proxdevs $1"
		echo "upstream-interface $1" >>$CONFFILE
	else
		json_load "$(devstatus $1)"
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

config_igmp_proxy_interface() {
	local itr

	for proxif in $1; do
		case "$proxif" in
			br-*)
				handle_bridged_proxy_interface $proxif
			;;
			*)
				proxdevs="$proxdevs $proxif"
			;;
		esac
	done

	if [ $p_enable -eq 1 ]; then
		echo "igmp-proxy-interfaces $proxdevs" >> $CONFFILE
	fi

	[ -n "$proxdevs" ] && echo "igmp-mcast-interfaces $proxdevs" >> $CONFFILE
}

configure_mcpd_snooping() {
	# Configure snooping related params
	config_igmps_common_params $s_version $s_robustness $s_enable
	echo "igmp-proxy-enable 0" >> $CONFFILE

	# BCM's mcpd always acts as queries, so configure some default values to prevent flooding
	# of queries towards the clients or early leaves even in pure snooping with what will be
	# default values for these params
	config_igmp_querier_params 

	config_igmp_proxy_interface $s_interface

	# set snooping mode on the bridge
	config_snooping_on_bridge $s_interface $s_enable

	[ -n "$s_exceptions" ] && echo "igmp-mcast-snoop-exceptions $s_exceptions" >> $CONFFILE
}

configure_mcpd_proxy() {
	local s_mode=2

	# Configure snooping related params
	config_igmps_common_params $p_version $p_robustness $s_mode
	echo "igmp-proxy-enable $p_enable" >> $CONFFILE
	echo "igmp-fast-leave $fast_leave" >> $CONFFILE

	config_igmp_querier_params

	config_igmp_proxy_interface $p_up_interfaces

	config_snooping_on_bridge $p_down_interfaces $s_mode

	[ -n "$p_exceptions" ] && echo "igmp-mcast-snoop-exceptions $p_exceptions" >> $CONFFILE
}

configure_mcpd() {
	for br in $(brctl show | grep 'br-' | awk '{print$1}' | tr '\n' ' '); do
		bcmmcastctl mode -i $br -p $bcm_mcast_p -m 0 # disable snooping on all bridges
		bcmmcastctl l2l -i $br -p $bcm_mcast_p -e 0 # disable L2L snooping on all bridges
	done

	# BCM's mcpd does not allow configuration of proxy and L2 snooping simultaneously, hence
	# here, if proxy is to be configured then the configuration params of snooping are ignored.
	if [ "$p_enable" == "1" ]; then
		configure_mcpd_proxy
	elif [ "$s_enable" == "1" ]; then
		configure_mcpd_snooping
	fi
}

read_igmp_snooping_params() {
	config_load mcast
	config_foreach read_snooping snooping
}

read_igmp_proxy_params() {
	config_load mcast
	config_foreach read_proxy proxy
}

config_global_igmp_params() {
	local qrv
	local force_version

	config_load mcast
	config_get max_msf igmp max_msf 10
	config_get max_groups igmp max_membership 25
	config_get qrv igmp qrv 2
	config_get force_version igmp force_version 0

	# mcpd internally writes max_groups and max_msf, no need to modify
	# here directly
	echo $qrv > /proc/sys/net/ipv4/igmp_qrv
	echo $force_version > /proc/sys/net/ipv4/conf/all/force_igmp_version

}

configure_mcast_igmp() {
	rm -f $CONFFILE
	touch $CONFFILE

	config_global_igmp_params

	read_igmp_snooping_params
	read_igmp_proxy_params

	configure_mcpd
}
