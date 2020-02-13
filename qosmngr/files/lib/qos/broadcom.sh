#!/bin/sh

for intf in $(db get hw.board.ethernetPortOrder); do
	i=0
	for i in 0 1 2 3 4 5 6 7; do
		tmctl delqcfg --devtype 0 --if $intf --qid $i
	done
done

for cmd in q pbit; do
	i=0
	while :
	do
		qid="q$i"
		ifname=$(uci -q get qos.$qid.ifname)

		# if ifname is empty that is good enough to break
		if [ -z "$ifname" ];then
			break
		fi

		# it makes sense to read rest on the params only if port is present,
		# which kind of indicates whether the config section is available
		# or not

		# lower the value, lower the priority of queue on this chip
		order=$(uci -q get qos.$qid.precedence)

		# on this chip, 8 queues per port exist so values larger than this
		# cannot be supported
		if [ $order -gt 7 ]; then
			continue
		fi

		tc=$(uci -q get qos.$qid.traffic_class)
		sc_alg=$(uci -q get qos.$qid.scheduling)
		wgt=$(uci -q get qos.$qid.weight)
		rate=$(uci -q get qos.$qid.rate)
		bs=$(uci -q get qos.$qid.burst_size)

		salg=1
		if [ $sc_alg == 'WRR' ]; then
			salg=2
		fi

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
	
		# Read the next configuration
		i=$((i + 1))
	done
done

i=0
while :
do
	sid="s$i"
	ifname=$(uci -q  get qos.$sid.ifname)

	# if ifname is empty that is good enough to break
	if [ -z "$ifname" ];then
		break
	fi
	rate=$(uci -q get qos.$sid.rate)
	bs=$(uci -q get qos.$sid.burst_size)
	tmctl setportshaper --devtype 0 --if $ifname --shapingrate $rate --burstsize $bs
done
