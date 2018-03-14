# this is a developer helper script to install firmware on a remote host with SSH

function usage {
	echo "usage: $0 ssh_sysupgrade <host> <file> [opts]"
}

function ssh_sysupgrade {
	if [ -z "$1" ] ; then
		usage
		echo "Error: host required"
		exit 1
	fi
	if [ -z "$2" ] ; then
		usage
		echo "Error: firmware filename required"
		exit 1
	fi
	if [ ! -e $2 ] ; then
		usage
		echo "Error: firmware file does not exist"
		exit 1
	fi
	IMAGE=`basename $2`
	echo "sysupgrade host: $1 with file $IMAGE"
	[ "$2" ] && [ -e "$2" ] && scp $2 root@$1:/tmp/ && ssh -o ConnectTimeout=60 root@$1 "sysupgrade $3 /tmp/$IMAGE" && echo "sysupgrade done!"
}

register_command "ssh_sysupgrade" "<host> <file> [opts]  Install firmware on remote host with SSH"

function ssh_sysupgrade_latest {
	if [ -z "$1" ] ; then
		echo "usage: $0 ssh_sysupgrade_latest <host> [opts]"
		echo "Error: host required"
		exit 1
	fi
	{ cd `dirname $0`
		IMAGE=`ls -Art bin/*/*/*/*.y[23] | tail -n1`
		[ "$IMAGE" ] && [ -e "$IMAGE" ] && ./iop ssh_sysupgrade $1 $IMAGE $2
	}
}

register_command "ssh_sysupgrade_latest" "<host> [opts]  Install latest ubifs firmware on remote host with SSH"

function ssh_sysupgrade_latest_w {
	if [ -z "$1" ] ; then
		echo "usage: $0 ssh_sysupgrade_latest_w <host> [opts]"
		echo "Error: host required"
		exit 1
	fi
	{ cd `dirname $0`
		IMAGE=`ls -Art bin/*/*.w | tail -n1`
		[ "$IMAGE" ] && [ -e "$IMAGE" ] && ./iop ssh_sysupgrade $1 $IMAGE $2
	}
}

register_command "ssh_sysupgrade_latest_w" "<host> [opts]  Install latest jffs2 firmware on remote host with SSH"
