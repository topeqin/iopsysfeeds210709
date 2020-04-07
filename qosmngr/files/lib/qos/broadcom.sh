#!/bin/sh
. /lib/functions.sh

#function to handle a queue section
handle_queue() {
		qid="$1" #queue section ID
		cmd=$2 #additional parameter
                local ifname
		local tc
		local sc_alg
		local wgt
		local rate
		local bs
		config_get ifname "$qid" "ifname"

		# if ifname is empty that is good enough to break
		if [ -z "$ifname" ];then
			break
		fi

		# lower the value, lower the priority of queue on this chip
		config_get order "$qid" "precedence"

		# on this chip, 8 queues per port exist so values larger than this
		# cannot be supported
		if [ $order -gt 7 ]; then
			continue
		fi

		config_get tc "$qid" "traffic_class"
		config_get sc_alg "$qid" "scheduling"
		config_get wgt "$qid" "weight"
		config_get rate "$qid" "rate"
		config_get bs "$qid" "burst_size"

		salg=1

#		if [ $sc_alg == 'WRR' ]; then
#			salg=2
#		fi
		
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
			# Now the mapping of p bit to a queue happens
			IFS=,
			for word in $tc; do
				tmctl setpbittoq --devtype 0 --if $ifname --pbit $word --qid $order
			done
		fi
}	

#function to handle a shaper section
handle_shaper() {
	local sid
	local ifname
	local rate
	local bs
	sid="$1" #queue section ID
	config_get ifname "$sid" "ifname"
	# if ifname is empty that is good enough to break
	if [ -z "$ifname" ];then
		break
	fi
	config_get rate "$sid" "rate"
	config_get bs "$sid" "burst_size"
	tmctl setportshaper --devtype 0 --if $ifname --shapingrate $rate --burstsize $bs
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
}
