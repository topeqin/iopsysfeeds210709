# this is a developer helper script to install firmware on a remote host with SSH

function usagee {
    echo "usage: $0 iopupgrade -h <host> -f <file> "
    echo ""
    echo "   Default host is 192.168.1.1"
}

function set_config_string {
    eval `grep $1 .config`
}

function ssh_upgrade {

    set_config_string CONFIG_TARGET_BOARD
    firmwares=$(cd bin/targets/$CONFIG_TARGET_BOARD/generic/; ls -t *[0-9].y[3])
    echo "--------------"
    for latest in $firmwares
    do
	#echo "firmware $latest"
	break
    done
    echo "latest firmware is $latest"
    firmware="bin/targets/$CONFIG_TARGET_BOARD/generic/$latest"
    if [ ! -f $firmware ]
    then
	echo "firmware file $firmware do not exist"
	exit 1
    fi
    file_size_kb=`du -k "$firmware" | cut -f1`

    cat $firmware | pv -s ${file_size_kb}k   | ssh root@192.168.1.1 iopu
    exit 0
    echo "--------------"
    
	if [ -z "$1" ] ; then
		usagee
		echo "Error: host required"
		exit 1
	fi
	if [ -z "$2" ] ; then
		usagee
		echo "Error: firmware filename required"
		exit 1
	fi
	if [ ! -e $2 ] ; then
		usagee
		echo "Error: firmware file does not exist"
		exit 1
	fi
	IMAGE=`basename $2`
	echo "sysupgrade host: $1 with file $IMAGE"
	[ "$2" ] && [ -e "$2" ] && scp $2 root@$1:/tmp/ && ssh -o ConnectTimeout=60 root@$1 "sysupgrade -v $3 /tmp/$IMAGE" && echo "sysupgrade done!"
}

register_command "ssh_upgrade" "-h <host> <file> [opts]  Install firmware on remote host with SSH"


