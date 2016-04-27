# this is a developer helper script to install firmware on a remote host running in CFE mode

function usage {
	echo "usage: $0 cfe_upgrade <host> <file>"
}

function cfe_upgrade {
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
	echo "CFE upgrade host: $1 with file $IMAGE"
	[ "$2" ] && [ -e "$2" ] &&  curl -i -F filedata=@$2  http://$1/upload.cgi && echo "upgrade done!"
}

register_command "cfe_upgrade" "<host> <file>  Install firmware on remote host in CFE mode"

function cfe_upgrade_latest {
	if [ -z "$1" ] ; then
		echo "usage: $0 cfe_upgrade_latest <host>"
		echo "Error: host required"
		exit 1
	fi
	{ cd `dirname $0`
		IMAGE=`ls -Art bin/*/*.y | tail -n1`
		[ "$IMAGE" ] && [ -e "$IMAGE" ] && ./iop cfe_upgrade $1 $IMAGE
	}
}

register_command "cfe_upgrade_latest" "<host>  Install latest firmware on remote host in CFE mode"
