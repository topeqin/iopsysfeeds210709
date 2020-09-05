#!/bin/sh
. /lib/functions.sh

IP_RULE=""
BR_RULE=""
is_bcm968=0

#function to handle a queue section
handle_queue() {
	qid="$1" #queue section ID

	config_get is_enable "$qid" "enable"

	#no need to configure disabled queues
	if [ $is_enable == '0' ]; then
		return
	fi

	config_get ifname "$qid" "ifname"
	#if ifname is empty that is good enough to break
	if [ -z "$ifname" ];then
		return
	fi

	local q_no=$(cat /tmp/qos/queue_stats/$ifname/q_idx)
	#lower the value, lower the priority of queue on this chip
	config_get order "$qid" "precedence"

	config_get sc_alg "$qid" "scheduling"
	config_get wgt "$qid" "weight"
	config_get rate "$qid" "rate"
	config_get bs "$qid" "burst_size"
	config_get qsize "$qid" "queue_size" 1024

	salg=1

	case "$sc_alg" in
		"SP") salg=1
		;;
		"WRR") salg=2
		;;
		"WDRR") salg=3
		;;
		"WFQ") salg=4
		;;
	esac

	# Call tmctl which is a broadcomm command to configure queues on a port.
	tmctl setqcfg --devtype 0 --if $ifname --qid $q_no --priority $order --qsize $qsize --weight $wgt --schedmode $salg --shapingrate $rate --burstsize $bs

	# In BCM968 chips, the counters for queues are read, on other model, its read and reset. So, to maintain counter
	# value and uniform behaviour, we are storing counter value for each queue in files
	local d_name="/tmp/qos/queue_stats/${ifname}/q_${q_no}"
	mkdir $d_name
	local f_name="$d_name/txPackets"
	touch $f_name
	echo 0 > $f_name
	f_name="$d_name/txBytes"
	touch $f_name
	echo 0 > $f_name
	f_name="$d_name/droppedPackets"
	touch $f_name
	echo 0 > $f_name
	f_name="$d_name/droppedBytes"
	touch $f_name
	echo 0 > $f_name

	q_no=$((q_no + 1))
	echo $q_no > /tmp/qos/queue_stats/$ifname/q_idx
}

#function to handle a shaper section
handle_shaper() {
	sid="$1" #queue section ID

	config_get is_enable "$sid" "enable"
	# no need to configure disabled queues
	if [ $is_enable == '0' ]; then
		return
	fi


	config_get ifname "$sid" "ifname"
	# if ifname is empty that is good enough to break
	if [ -z "$ifname" ];then
		return
	fi

	config_get rate "$sid" "rate"
	config_get bs "$sid" "burst_size"
	tmctl setportshaper --devtype 0 --if $ifname --shapingrate $rate --burstsize $bs
}

setup_qos() {
	ebtables -t broute -N qos
	ret=$?
	if [ $ret -eq 0 ]; then
		ebtables -t broute -I BROUTING -j qos
	else
		ebtables -t broute -D BROUTING -j qos
		ebtables -t broute -I BROUTING -j qos
	fi

	iptables -t mangle -N qos_forward
	ret=$?
	[ $ret -eq 0 ] && iptables -t mangle -I FORWARD -j qos_forward

	iptables -t mangle -N qos_prerouting
	ret=$?
	[ $ret -eq 0 ] && iptables -t mangle -I PREROUTING -j qos_prerouting

	iptables -t mangle -N qos_output
	ret=$?
	[ $ret -eq 0 ] && iptables -t mangle -I OUTPUT -j qos_output

	ip6tables -t mangle -N qos_forward
	ret=$?
	[ $ret -eq 0 ] && ip6tables -t mangle -I FORWARD -j qos_forward

	ip6tables -t mangle -N qos_prerouting
	ret=$?
	[ $ret -eq 0 ] && ip6tables -t mangle -I PREROUTING -j qos_prerouting

	ip6tables -t mangle -N qos_output
	ret=$?
	[ $ret -eq 0 ] && ip6tables -t mangle -I OUTPUT -j qos_output
}

flush_chains() {
	echo "ebtables -t broute -F qos" > /tmp/qos/classify.ebtables

	echo "iptables -t mangle -F qos_forward" > /tmp/qos/classify.iptables
	echo "iptables -t mangle -F qos_prerouting" >> /tmp/qos/classify.iptables
	echo "iptables -t mangle -F qos_output" >> /tmp/qos/classify.iptables

	echo "ip6tables -t mangle -F qos_forward" > /tmp/qos/classify.ip6tables
	echo "ip6tables -t mangle -F qos_prerouting" >> /tmp/qos/classify.ip6tables
	echo "ip6tables -t mangle -F qos_output" >> /tmp/qos/classify.ip6tables
}

init_broute_rule() {
	BR_RULE=""
}

broute_filter_on_src_if() {
	BR_RULE="$BR_RULE --in-if $1"
}

broute_filter_on_src_mac() {
	BR_RULE="$BR_RULE --src $1"
}

broute_filter_on_dst_mac() {
	BR_RULE="$BR_RULE --dst $1"
}

broute_filter_on_pcp() {
	BR_RULE="$BR_RULE --skbvlan-prio $1"
}

broute_filter_on_ether_type() {
	BR_RULE="$BR_RULE --proto $1"
}

broute_filter_on_vid() {
	BR_RULE="$BR_RULE --skbvlan-id $1"
}

broute_rule_set_traffic_class() {
	BR_RULE="$BR_RULE -j mark --mark-or 0x$1 --mark-target ACCEPT"
}

broute_append_rule() {
	echo "ebtables -t broute -A qos $BR_RULE" >> /tmp/qos/classify.ebtables
}

handle_ebtables_rules() {
	sid=$1
	local is_l2_rule=0

	init_broute_rule

	config_get src_if "$sid" "ifname"
	config_get src_mac "$sid" "src_mac"
	config_get dst_mac "$sid" "dst_mac"
	config_get pcp_check "$sid" "pcp_check"
	config_get eth_type "$sid" "ethertype"
	config_get vid "$sid" "vid_check"
	config_get traffic_class "$sid" "traffic_class"

	if [ -n "$src_if" ]; then
		for interf in $(db -q get hw.board.ethernetPortOrder); do
			if [ "$src_if" == "$interf" ]; then
				src_if="$src_if+"
				broute_filter_on_src_if $src_if
				is_l2_rule=1
			fi
		done
	fi

	if [ -n "$src_mac" ]; then
		broute_filter_on_src_mac $src_mac
		is_l2_rule=1
	fi

	if [ -n "$dst_mac" ]; then
		broute_filter_on_dst_mac $dst_mac
		is_l2_rule=1
	fi

	if [ -n "$pcp_check" ]; then
		broute_filter_on_pcp $pcp_check
		is_l2_rule=1
	fi

	if [ -n "$eth_type" ]; then
		broute_filter_on_ether_type $eth_type
		is_l2_rule=1
	fi

	if [ -n "$vid" ]; then
		broute_filter_on_vid $vid
		is_l2_rule=1
	fi

	if [ $is_l2_rule -eq 0 ]; then
		return
	fi

	[ -n "$traffic_class" ] && broute_rule_set_traffic_class $traffic_class

	[ -n "$BR_RULE" ] && broute_append_rule
}

init_iptables_rule() {
	IP_RULE=""
}

iptables_filter_intf() {
	IP_RULE="$IP_RULE -i $1"
}

iptables_filter_proto() {
	IP_RULE="$IP_RULE -p $1"
}

iptables_filter_ip_src() {
	IP_RULE="$IP_RULE -s $1"
}

iptables_filter_ip_dest() {
	IP_RULE="$IP_RULE -d $1"
}

iptables_filter_port_dest() {
	IP_RULE="$IP_RULE --dport $1"
}

iptables_filter_port_src() {
	IP_RULE="$IP_RULE --sport $1"
}

iptables_filter_port_dest_range() {
	IP_RULE="$IP_RULE --dport $1:$2"
}

iptables_filter_port_src_range() {
	IP_RULE="$IP_RULE --sport $1:$2"
}

iptables_filter_dscp_filter() {
	IP_RULE="$IP_RULE -m dscp --dscp $1"
}

iptables_filter_ip_len_min() {
	IP_RULE="$IP_RULE -m length --length $1"
}

iptables_filter_ip_len_max() {
	IP_RULE="$IP_RULE:$1"
}

iptables_set_dscp_mark() {
	IP_RULE="$IP_RULE -j DSCP --set-dscp $1"
}

iptables_set_traffic_class() {
	IP_RULE="$IP_RULE -j MARK --set-xmark 0x$1/0x$1"
}

append_rule_to_mangle_table() {
	if [ $2 == 4 ]; then
		echo "iptables -t mangle -A $1 $IP_RULE"  >> /tmp/qos/classify.iptables
	elif [ $2 == 6 ]; then
		echo "ip6tables -t mangle -A $1 $IP_RULE" >> /tmp/qos/classify.ip6tables
	elif [ $2 == 1 ]; then
		echo "iptables -t mangle -A $1 $IP_RULE"  >> /tmp/qos/classify.iptables
		echo "ip6tables -t mangle -A $1 $IP_RULE" >> /tmp/qos/classify.ip6tables
	fi
}

handle_iptables_rules() {
	cid=$1
	local ip_version=0
	local is_l3_rule=0

	init_iptables_rule
	config_get proto "$cid" "proto"
	config_get traffic_class "$sid" "traffic_class"
	config_get dscp_mark "$cid" "dscp_mark"
	config_get dscp_filter "$cid" "dscp_filter"
	config_get dest_port "$cid" "dest_port"
	config_get dest_port_range "$cid" "dest_port_range"
	config_get src_port "$cid" "src_port"
	config_get src_port_range "$cid" "src_port_range"
	config_get dest_ip "$cid" "dest_ip"
	config_get src_ip "$cid" "src_ip"
	config_get ip_len_min "$cid" "ip_len_min"
	config_get ip_len_max "$cid" "ip_len_max"
	config_get ifname "$cid" "ifname"

	#check version of ip
	case $src_ip$dest_ip in
		*.*)
			ip_version=4
			;;
		*:*)
			ip_version=6
			;;
		*)
			ip_version=1 #ip address not used
	esac

	#filter interface
	if [ -n "$ifname" ]; then
		if [ "$ifname" != "lo" ]; then
			iptables_filter_intf $ifname
		fi
	fi

	# filter proto
	if [ -n "$proto" ]; then
		iptables_filter_proto $proto
		is_l3_rule=1
	fi

	#filter src. ip
	if [ -n "$src_ip" ]; then
		iptables_filter_ip_src $src_ip
		is_l3_rule=1
	fi

	#filter dest. ip
	if [ -n "$dest_ip" ]; then
		iptables_filter_ip_dest $dest_ip
		is_l3_rule=1
	fi

	#filter dest. port
	if [ -n "$dest_port" -a -z "$dest_port_range" ]; then
		iptables_filter_port_dest $dest_port
		is_l3_rule=1
	fi

	#filter src. port
	if [ -n "$src_port" -a -z "$src_port_range" ]; then
		iptables_filter_port_src $src_port
		is_l3_rule=1
	fi

	#filter dest. port range
	if [ -n "$dest_port" -a -n "$dest_port_range" ]; then
		iptables_filter_port_dest_range $dest_port $dest_port_range
		is_l3_rule=1
	fi

	#filter src. port range
	if [ -n "$src_port" -a -n "$src_port_range" ]; then
		iptables_filter_port_src_range $src_port $src_port_range
		is_l3_rule=1
	fi

	#filter dscp
	if [ -n "$dscp_filter" ]; then
		iptables_filter_dscp_filter $dscp_filter
		is_l3_rule=1
	fi

	#filter min. IP packet len.
	if [ -n "$ip_len_min" ]; then
		iptables_filter_ip_len_min $ip_len_min
		is_l3_rule=1
	fi

	#filter max. IP packet len.
	if [ -n "$ip_len_max" ]; then
		iptables_filter_ip_len_max $ip_len_max
		is_l3_rule=1
	fi

	if [ $is_l3_rule -eq 0 ]; then
		return
	fi

	#set dscp mark
	[ -n "$dscp_mark" ] && iptables_set_dscp_mark $dscp_mark

	#set packet queue mark
	[ -n "$traffic_class" ] && iptables_set_traffic_class  $traffic_class

	#write iptables rule for dscp marking
	[ -n "$IP_RULE" -a -n "$dscp_mark" ] && append_rule_to_mangle_table "qos_forward" $ip_version

	if [ -n "$IP_RULE" -a -n "$traffic_class" ]; then
		if [ "$ifname" == "lo" ]; then
			#write iptables rule for putting WAN directed internal packets in different queue
			append_rule_to_mangle_table "qos_output" $ip_version
		else
			#write iptables rule for putting WAN directed LAN packets in different queue
			append_rule_to_mangle_table "qos_prerouting" $ip_version
		fi
	fi
}

#function to handle a classify section
handle_classify() {
	cid="$1" #classify section ID

	config_get is_enable "$cid" "enable"
	# no need to configure disabled classify rules
	if [ $is_enable == '0' ]; then
		return
	fi

	handle_ebtables_rules $cid
	handle_iptables_rules $cid
}

configure_shaper() {
	# Delete existing shaper
	for intf in $(db get hw.board.ethernetPortOrder); do
		tmctl setportshaper --devtype 0 --if $intf --shapingrate 0 --burstsize -1
	done
	# Load UCI file
	config_load qos
	# Processing shaper section(s)
	config_foreach handle_shaper shaper
}

configure_classify() {
	#processing classify section
	# First remove old files
	rm -f /tmp/qos/classify.ebtables
	rm -f /tmp/qos/classify.iptables
	rm -f /tmp/qos/classify.ip6tables

	#create files that will contain the rules if not present already
	mkdir -p /tmp/qos/
	touch /tmp/qos/classify.iptables
	touch /tmp/qos/classify.ip6tables
	touch /tmp/qos/classify.ebtables

	#add flush chain rules
	flush_chains

	# Load UCI file
	config_load qos
	config_foreach handle_classify classify

	sh /tmp/qos/classify.ebtables
	sh /tmp/qos/classify.iptables
	sh /tmp/qos/classify.ip6tables
	# broadcom recommends that each time traffic class is set,
	# the flows should be flushed for the new mapping to take
	# effect, it then makes sense to make it a part of the
	# qosmngr package itself.
	fcctl flush
}

configure_queue() {
	# Delete queues
	rm -rf /tmp/qos/queue_stats

	for intf in $(db get hw.board.ethernetPortOrder); do
		mkdir -p /tmp/qos/queue_stats/$intf
		touch /tmp/qos/queue_stats/$intf/q_idx
		echo 0 > /tmp/qos/queue_stats/$intf/q_idx
		i=0
		for i in 0 1 2 3 4 5 6 7; do
			tmctl delqcfg --devtype 0 --if $intf --qid $i &>/dev/null
		done
	done

	# Load UCI file
	config_load qos
	config_foreach handle_queue queue
}

configure_qos() {
	configure_queue
	configure_shaper
	configure_classify
}

reload_qos() {
	local service_name="$1"
	if [ -z "$service_name" ]; then
		configure_qos
	elif [ "$service_name" == "shaper" ]; then
		configure_shaper
	elif [ "$service_name" == "queue" ]; then
		configure_queue
	elif [ "$service_name" == "classify" ]; then
		configure_classify
	fi
}

get_queue_stats() {
	local ifname
	local f_name
	local tmp_val
	local q_index=0
	local max_q_index=0

	json_init
	json_add_array "queues"

	if [ -n "$1" ]; then
		ifname=$1
		max_q_index=$(cat /tmp/qos/queue_stats/${ifname}/q_idx)
		while :
		do
			if [ $q_index -eq $max_q_index ]; then
				break
			fi
			stats="$(tmctl getqstats --devtype 0 --if $ifname --qid $q_index)"
			ret="$(echo $stats | awk '{print substr($0,0,5)}')"
			#check tmctl ERROR condition
			if [ $ret == 'ERROR' ]; then
				q_index=$((q_index + 1))
				continue
			fi
			json_add_object ""
			json_add_int "qid" "$q_index"
			json_add_string "iface" "$ifname"

			IFS=$'\n'
			for stat in $stats; do
				pname="$(echo $stat | awk '{print$1}')"
				if [ $pname == 'ret' ]; then
					continue
				fi

				val="$(echo $stat | awk '{print$2}')"

				# remove trailing : from the name
				pname="${pname::-1}"
				local f_name="/tmp/qos/queue_stats/${ifname}/q_${q_index}/${pname}"
				# In non BCM968* chips, read operation on queues is actually a read and reset,
				# so values need to be maintained to present cumulative value
				if [ $is_bcm968 -eq 0 ]; then
					tmp_val=$(cat $f_name)
					val=$((val + tmp_val))
				fi
				echo $val > $f_name

				# convert to iopsyswrt names
				case "$pname" in
					txPackets)
						json_add_int "tx_packets" "$val"
						;;
					txBytes)
						json_add_int "tx_bytes" "$val"
						;;
					droppedPackets)
						json_add_int "tx_dropped_packets" "$val"
						;;
					droppedBytes)
						json_add_int "tx_dropped_bytes" "$val"
						;;
				esac
			done
			json_close_object

			q_index=$((q_index + 1))
		done
	else
		for intf in $(db get hw.board.ethernetPortOrder); do
			ifname=$intf
			q_index=0
			max_q_index=$(cat /tmp/qos/queue_stats/${ifname}/q_idx)
			while :
			do
				if [ $q_index -eq $max_q_index ]; then
					break
				fi
				stats="$(tmctl getqstats --devtype 0 --if $ifname --qid $q_index)"
				ret="$(echo $stats | awk '{print substr($0,0,5)}')"
				#check tmctl ERROR condition
				if [ $ret == 'ERROR' ]; then
					q_index=$((q_index + 1))
					continue
				fi
				json_add_object ""
				json_add_int "qid" "$q_index"
				json_add_string "iface" "$ifname"

				IFS=$'\n'
				for stat in $stats; do
					pname="$(echo $stat | awk '{print$1}')"
					if [ $pname == 'ret' ]; then
						continue
					fi

					val="$(echo $stat | awk '{print$2}')"

					# remove trailing : from the name
					pname="${pname::-1}"
					local f_name="/tmp/qos/queue_stats/${ifname}/q_${q_index}/${pname}"
					# In non BCM968* chips, read operation on queues is actually a read and reset,
					# so values need to be maintained to present cumulative value
					if [ $is_bcm968 -eq 0 ]; then
						tmp_val=$(cat $f_name)
						val=$((val + tmp_val))
					fi
					echo $val > $f_name

					# convert to iopsyswrt names
					case "$pname" in
						txPackets)
							json_add_int "tx_packets" "$val"
							;;
						txBytes)
							json_add_int "tx_bytes" "$val"
							;;
						droppedPackets)
							json_add_int "tx_dropped_packets" "$val"
							;;
						droppedBytes)
							json_add_int "tx_dropped_bytes" "$val"
							;;
					esac
				done
				json_close_object

				q_index=$((q_index + 1))
			done
		done
	fi

	json_close_array
	json_dump
}

get_eth_q_stats() {
	json_init
	json_add_array "queues"

	ifname="$1"
	local tmp_val=0

	# if ifname is empty that is good enough to break
	if [ -z "$ifname" ];then
		return
	fi

	qid="$2"
	if [ -z "$qid" ];then
		return
	fi

	stats="$(tmctl getqstats --devtype 0 --if $ifname --qid $qid)"
	ret="$(echo $stats | awk '{print substr($0,0,5)}')"

	#check tmctl ERROR condition
	if [ $ret == 'ERROR' ]; then
		return
	fi

	json_add_object ""
	json_add_int "qid" "$qid"
	json_add_string "iface" "$ifname"

	IFS=$'\n'
	for stat in $stats; do
		pname="$(echo $stat | awk '{print$1}')"
		if [ $pname == 'ret' ]; then
			continue
		fi

		val="$(echo $stat | awk '{print$2}')"

		# remove trailing : from the name
		pname="${pname::-1}"
		local f_name="/tmp/qos/queue_stats/${ifname}/q_${qid}/${pname}"
		# In non BCM968* chips, read operation on queues is actually a read and reset,
		# so values need to be maintained to present cumulative value
		if [ $is_bcm968 -eq 0 ]; then
			tmp_val=$(cat $f_name)
			val=$((val + tmp_val))
		fi
		echo $val > $f_name

		# convert to iopsyswrt names
		case "$pname" in
			txPackets)
				json_add_int "tx_packets" "$val"
			;;
			txBytes)
				json_add_int "tx_bytes" "$val"
			;;
			droppedPackets)
				json_add_int "tx_dropped_packets" "$val"
			;;
			droppedBytes)
				json_add_int "tx_dropped_bytes" "$val"
			;;
		esac
	done

	json_close_object

	json_close_array
	json_dump
}

read_queue_stats() {
	itf="$1"
	q_idx="$2"
	local cpu_model="$(grep Hardware /proc/cpuinfo  | awk '{print$NF}')"
	case $cpu_model in
		BCM968*) is_bcm968=1 ;;
	esac

	if [ -n "$itf" -a -n "$q_idx" ]; then
		get_eth_q_stats $itf $q_idx
	else
		get_queue_stats $itf
	fi
}
