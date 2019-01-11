# this is a developer helper script to install firmware on a remote host with SSH

function upd_usage {
    echo "usage: $0 iopupgrade -t <host> -f <file> [opts] "
    echo ""
    echo "   Default host is 192.168.1.1"
    echo "   Default firmware file is the newest one found"
    echo "   Default is to not keep configuration"
    echo "opts:"
    echo ""
    echo "	-i	Interactive use, Allows to select firmware file"
    echo "	-n	Do not do the final reboot of the target board"
    echo "	-c	Keep configuration"
    echo "	-x	Force install even if firmware is not for this board"
    echo "	-b	Force install of bootloader regardless of version installed"
}

function set_config_string {
    eval `grep $1 .config`
}

function upd_ask_ok {
    echo "Will Continue with the following settings"
    echo "-----------------------------------------"
    printf "%20s: %s\n"  "Firmare file" "$upd_fw_base"
    printf "%20s: %s\n"  "Host ip" "$upd_host"
    printf "%20s: " "Reboot";               if [ "$upd_noreboot"   == "0" ] ;then printf "Yes\n" ;else printf "No\n";fi
    printf "%20s: " "Keep config";          if [ "$upd_keepconf"   == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi
    printf "%20s: " "Force bootloader";     if [ "$upd_forceboot"  == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi
    printf "%20s: " "Force image upgrade";  if [ "$upd_forceimage" == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi
    echo "-----------------------------------------"

    echo -n "Continue? [Y/n]:"
    read answer

    case $answer in
	n|N)
	    return 1;;
	y|Y|*)
	    return 0;;
    esac
}

function ssh_upgrade {
    upd_noreboot=0
    upd_forceboot=0
    upd_keepconf=0
    upd_forceimage=0
    upd_fw_base=""
    upd_fw=""
    upd_host="192.168.1.1"

    while getopts "f:hnxt:i" opt; do
	case $opt in
	    n)
		upd_noreboot=1
		;;
	    x)
		upd_forceimage=1
		;;
	    b)
		upd_forceboot=1
		;;
	    c)
		upd_keepconf=1
		upd_keepconf=0 # not yet supported
		;;
	    v)
		verbose=$OPTARG
		;;
	    f)
		upd_fw=$OPTARG
		;;
	    t)
		upd_host=$OPTARG
		;;
	    i)
		echo "not supported"
		return
		;;
	    h)
		upd_usage
		exit 1
		;;
	    \?)
		echo "Invalid option: -$OPTARG" >&2
		exit 1
		;;
	esac
    done

    if [ -n "$upd_fw" ]
    then
	upd_fw_base=$(basename $upd_fw);
    else
	set_config_string CONFIG_TARGET_BOARD
	firmwares=$(cd bin/targets/$CONFIG_TARGET_BOARD/generic/; ls -t *[0-9].y[3])

	for upd_fw_base in $firmwares
	do
	    #echo "firmware $upd_fw"
	    break
	done
	upd_fw="bin/targets/$CONFIG_TARGET_BOARD/generic/$upd_fw_base"
    fi

    if ! upd_ask_ok
    then
	echo "Aborting"
	exit 1
    fi

    if [ ! -f $upd_fw ]
    then
	echo "firmware file $firmware do not exist"
	exit 1
    fi
    file_size_kb=`du -k "$upd_fw" | cut -f1`

    
    cat $upd_fw | pv -s ${file_size_kb}k   | ssh root@192.168.1.1 iopu
    exit 0
}

register_command "ssh_upgrade" "-h <host> -f <file> [opts]  Install firmware on remote host with SSH"


