#!/bin/sh
. /lib/functions.sh

IP_RULE=""
BR_RULE=""

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

	#lower the value, lower the priority of queue on this chip
	config_get order "$qid" "precedence"

	config_get sc_alg "$qid" "scheduling"
	config_get wgt "$qid" "weight"
	config_get rate "$qid" "rate"
	config_get bs "$qid" "burst_size"

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
	tmctl setqcfg --devtype 0 --if $ifname --qid $order --priority $order --weight $wgt --schedmode $salg --shapingrate $rate --burstsize $bs
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

flush_chains() {
	echo "ebtables -t broute -F" > /tmp/qos/classify.ebtables
	echo "iptables -t mangle -F FORWARD" > /tmp/qos/classify.iptables
        echo "iptables -t mangle -F PREROUTING" >> /tmp/qos/classify.iptables
        echo "iptables -t mangle -F OUTPUT" >> /tmp/qos/classify.iptables
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
	echo "ebtables -t broute -A BROUTING $BR_RULE" >> /tmp/qos/classify.ebtables
}

handle_ebtables_rules() {
	sid=$1

	init_broute_rule

	config_get src_if "$sid" "ifname"
	if [ -n "$src_if" ]; then
		src_if="$src_if+"
		broute_filter_on_src_if $src_if
	fi

	config_get src_mac "$sid" "src_mac"
	[ -n "$src_mac" ] && broute_filter_on_src_mac $src_mac
	config_get dst_mac "$sid" "dst_mac"
	[ -n "$dst_mac" ] && broute_filter_on_dst_mac $dst_mac
	config_get pcp_check "$sid" "pcp_check"
	[ -n "$pcp_check" ] && broute_filter_on_pcp $pcp_check
	config_get eth_type "$sid" "ethertype"
	[ -n "$eth_type" ] && broute_filter_on_ether_type $eth_type
	config_get vid "$sid" "vid_check"
	[ -n "$vid" ] && broute_filter_on_vid $vid

	config_get traffic_class "$sid" "traffic_class"
	[ -n "$traffic_class" ] && broute_rule_set_traffic_class $traffic_class

	[ -n "$BR_RULE" ] && broute_append_rule
}

init_iptables_rule() {
	IP_RULE=""
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

iptables_filter_ip_mask() {
	IP_RULE="$IP_RULE$1"
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
        echo "iptables -t mangle -A $1 $IP_RULE" >> /tmp/qos/classify.iptables
}

handle_iptables_rules() {
	cid=$1

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
	config_get dest_mask "$cid" "dest_mask"
	config_get src_ip "$cid" "src_ip"
	config_get src_mask "$cid" "src_mask"
        config_get ip_len_min "$cid" "ip_len_min"
        config_get ip_len_max "$cid" "ip_len_max"
	config_get ifname "$cid" "ifname"

	# filter proto
	[ -n "$proto" ] && iptables_filter_proto $proto

	#filter src. ip
	[ -n "$src_ip" ] && iptables_filter_ip_src $src_ip

	#filter dest. ip
	[ -n "$dest_ip" ] && iptables_filter_ip_dest $dest_ip

	#filter src. ip mask
	[ -n "$src_mask" ] && iptables_filter_ip_mask $src_mask

	#filter dest. ip mask
	[ -n "$dest_mask" ] && iptables_filter_ip_mask $dest_mask

	#filter dest. port
	[ -n "$dest_port" -a -z "$dest_port_range" ] && iptables_filter_port_dest $dest_port

	#filter src. port
	[ -n "$src_port" -a -z "$src_port_range" ] && iptables_filter_port_src $src_port

	#filter dest. port range
	[ -n "$dest_port" -a -n "$dest_port_range" ] && iptables_filter_port_dest_range $dest_port $dest_port_range

	#filter src. port range
	[ -n "$src_port" -a -n "$src_port_range" ] && iptables_filter_port_src_range $src_port $src_port_range

	#filter dscp
	[ -n "$dscp_filter" ] && iptables_filter_dscp_filter $dscp_filter

	#filter min. IP packet len.
        [ -n "$ip_len_min" ] && iptables_filter_ip_len_min $ip_len_min

        #filter max. IP packet len.
        [ -n "$ip_len_max" ] && iptables_filter_ip_len_max $ip_len_max

	#set dscp mark
	[ -n "$dscp_mark" ] && iptables_set_dscp_mark $dscp_mark

	#set packet queue mark
        [ -n "$traffic_class" ] && iptables_set_traffic_class  $traffic_class

        #write iptables rule for dscp marking
        [ -n "$IP_RULE" -a -n "$dscp_mark" ] && append_rule_to_mangle_table "FORWARD"

	if [ -n "$IP_RULE" -a -n "$traffic_class" -a -n "$ifname" ]; then
		if [ ${ifname:0:2} == "lo" ]; then
			#write iptables rule for putting WAN directed internal packets in different queue
			append_rule_to_mangle_table "OUTPUT"
		else
			#write iptables rule for putting WAN directed LAN packets in different queue
			append_rule_to_mangle_table "PREROUTING"
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

configure_qos() {
	# Delete queues
	for intf in $(db get hw.board.ethernetPortOrder); do
		i=0
		for i in 0 1 2 3 4 5 6 7; do
			tmctl delqcfg --devtype 0 --if $intf --qid $i
		done
	done

	# Load UCI file
	config_load qos
	# Processing shaper section(s)
	config_foreach handle_shaper shaper

	config_foreach handle_queue queue

	#processing classify section
	# First remove old files
	rm -f /tmp/qos/classify.ebtables
	rm -f /tmp/qos/classify.iptables

	#create files that will contain the rules if not present already
	mkdir -p /tmp/qos/
	touch /tmp/qos/classify.iptables
	touch /tmp/qos/classify.ebtables

	#add flush chain rules
	flush_chains

	config_foreach handle_classify classify

	# For now qosmngr will execute the ebtables and iptables scripts
	# that it generates, this can later be integrated with the include
	# section of firewall uci bu execute for now
	sh /tmp/qos/classify.ebtables
	sh /tmp/qos/classify.iptables
}

get_queue_stats() {
	json_init
	json_add_array "queues"
	i=0
	while :
	do
		ifname=$(uci -q  get qos.@queue[$i].ifname)

		# if ifname is empty that is good enough to break
		if [ -z "$ifname" ];then
			break
		fi

		order=$(uci -q get qos.@queue[$i].precedence)
		stats="$(tmctl getqstats --devtype 0 --if $ifname --qid $order)"
		ret="$(echo $stats | awk '{print substr($0,0,5)}')"

		#check tmctl ERROR condition
		if [ $ret == 'ERROR' ]; then
			i=$((i + 1))
			continue
		fi
		json_add_object ""
		json_add_string "qid" "$order"
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

			# convert to iopsyswrt names
			case "$pname" in
				txPackets)
					json_add_string "tx_packets" "$val"
				;;
				txBytes)
					json_add_string "tx_bytes" "$val"
				;;
				droppedPackets)
					json_add_string "tx_dropped_packets" "$val"
				;;
				droppedBytes)
					json_add_string "tx_dropped_bytes" "$val"
				;;
			esac
		done

		json_close_object
		i=$((i + 1))
	done

	json_close_array
	json_dump
}

get_eth_q_stats() {
	json_init
	json_add_array "queues"

	ifname="$1"

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
	json_add_string "qid" "$qid"
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

		# convert to iopsyswrt names
		case "$pname" in
			txPackets)
				json_add_string "tx_packets" "$val"
			;;
			txBytes)
				json_add_string "tx_bytes" "$val"
			;;
			droppedPackets)
				json_add_string "tx_dropped_packets" "$val"
			;;
			droppedBytes)
				json_add_string "tx_dropped_bytes" "$val"
			;;
		esac
	done

	json_close_object

	json_close_array
	json_dump
}
