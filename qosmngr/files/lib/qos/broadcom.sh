#!/bin/sh
. /lib/functions.sh

IP_RULE=""

#function to handle a queue section
handle_queue() {
	qid="$1" #queue section ID
	cmd=$2 #additional parameter
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

	config_get tc "$qid" "traffic_class"
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

	if [ $cmd == q ]; then
		# Call tmctl which is a broadcomm command to configure queues on a port.
		tmctl setqcfg --devtype 0 --if $ifname --qid $order --priority $order --weight $wgt --schedmode $salg --shapingrate $rate --burstsize $bs
			
	else
		if [ $sc_alg == 'WRR' ]; then
			return
		fi

		if [ -z "$tc" ]; then
			return
		fi

		# Now the mapping of p bit to a queue happens
		IFS=,
		for word in $tc; do
			tmctl setpbittoq --devtype 0 --if $ifname --pbit $word --qid $order
		done
	fi
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

#Below are the functions to construct iptables rules
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

iptables_set_dscp_mark() {
	IP_RULE="$IP_RULE -j DSCP --set-dscp $1"
}

mangle_append_rule(){
	echo "iptables -t mangle -A FORWARD $IP_RULE" >> /tmp/qos/classify.iptables
}

handle_iptables_rules() {
	cid=$1
	init_iptables_rule
	config_get proto "$cid" "proto"
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

	#set dscp mark
	[ -n "$dscp_mark" ] && iptables_set_dscp_mark $dscp_mark

	[ -n "$IP_RULE" ] && mangle_append_rule
}

#function to handle a classify section
handle_classify() {
	cid="$1" #classify section ID
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

	# Processing queue section(s)
	for cmd in q pbit; do
		config_foreach handle_queue queue $cmd
	done
	#processing classify section
	# Flush the broute table before processing classify section
	rm -f /tmp/qos/classify.iptables
	#create iptables script file if not present
	mkdir -p /tmp/qos/ && touch /tmp/qos/classify.iptables
	echo "iptables -t mangle -F FORWARD" > /tmp/qos/classify.iptables

	config_foreach handle_classify classify
	# For now qosmngr will execute the ebtables and iptables scripts
	# that it generates, this can later be integrated with the include
	# section of firewall uci bu execute for now
	sh /tmp/qos/classify.iptables
}
