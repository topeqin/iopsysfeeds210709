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
    echo "	-s	Use sysupgade. old upgrade method, needed for old releases that do not have iopu"
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
    printf "%20s: " "Use sysupgrade";       if [ "$upd_sysupgrade" == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi
    echo "-----------------------------------------"

    if [ "$upd_sysupgrade" == "0" ]
       then
	   if [ "$upd_keepconf"   == "1" ] ;then echo "keeping config is just a fantasy it's not yet implemented, try sysupgrade";fi
    fi

    echo -n "Continue? [Y/n/q]:"
    read answer

    case $answer in
	n|N)
	    return 1;;
	q|Q)
	    exit 1;;
	y|Y|*)
	    return 0;;
    esac
}

function upd_select_file {

    dialog --keep-tite --title "To select file use TAB/ARROW to hilight then press SPACEBAR -> RETURN" \
	   --fselect "bin/targets/$CONFIG_TARGET_BOARD/generic/" \
	   $((lines -10)) $((cols -5)) \
	   2> $tempfile

    new_file=$(cat $tempfile)
    if [ -n "$new_file" ]
    then
	upd_fw="$new_file"
	upd_fw_base=$(basename $upd_fw);
    fi
}

function upd_select_target {

    dialog --keep-tite --title "Input the name/ip number of target board" \
	   --inputbox "Name/IP" \
	   $((lines -10)) $((cols -5)) \
	   "$upd_host" \
	   2> $tempfile

    new_file=$(cat $tempfile)
    if [ -n "$new_file" ]
    then
	upd_host="$new_file"
    fi
}


function upd_select_reboot {
    dialog --keep-tite --radiolist "Should the board reboot after download finished" \
	   $((lines -5)) $((cols -5)) $((lines -5 -5)) \
	   "Reboot" "Restart board after done"       `if [ "$upd_noreboot" == "0" ] ;then echo "ON" ;else echo "OFF";fi` \
	   "No reboot" "Continue running old system" `if [ "$upd_noreboot" == "1" ] ;then echo "ON" ;else echo "OFF";fi` \
	   2> $tempfile

    res=$(cat $tempfile)
    case $res in
	"No reboot")
	    upd_noreboot=1
	;;
	"Reboot")
	    upd_noreboot=0
	    ;;
    esac
}

function upd_select_config {
    dialog --keep-tite --radiolist "Should the configuration be keept" \
	   $((lines -5)) $((cols -5)) $((lines -5 -5)) \
	   "Keep" "Keep the config from old system"      `if [ "$upd_keepconf" == "1" ] ;then echo "ON" ;else echo "OFF";fi` \
	   "Default" "Use default config for new system" `if [ "$upd_keepconf" == "0" ] ;then echo "ON" ;else echo "OFF";fi` \
	   2> $tempfile

    res=$(cat $tempfile)
    case $res in
	"Keep")
	    upd_keepconf=1
	    ;;
	"Default")
	    upd_keepconf=0
	    ;;
    esac
}

function upd_select_forceboot {
    dialog --keep-tite --radiolist "Should the boot loader be updated reagardless of version installed" \
	   $((lines -5)) $((cols -5)) $((lines -5 -5)) \
	   "Force" "Alwasy update boot loader"                `if [ "$upd_forceboot" == "1" ] ;then echo "ON" ;else echo "OFF";fi` \
	   "Version check" "Only upgrade if version is newer" `if [ "$upd_forceboot" == "0" ] ;then echo "ON" ;else echo "OFF";fi` \
	   2> $tempfile

    res=$(cat $tempfile)
    case $res in
	"Force")
	    upd_forceboot=1
	    ;;
	"Version check")
	    upd_forceboot=0
	    ;;
    esac
}

function upd_select_forceimage {
    dialog --keep-tite --radiolist "Should the image be stored in flash even if sanity checks would reject it" \
	   $((lines -5)) $((cols -5)) $((lines -5 -5)) \
	   "Force" "Dissable sanity check and force use of image (dangerous)" `if [ "$upd_forceimage" == "1" ] ;then echo "ON" ;else echo "OFF";fi` \
	   "Only compatible" "Normal checks apply"                            `if [ "$upd_forceimage" == "0" ] ;then echo "ON" ;else echo "OFF";fi` \
	   2> $tempfile

    res=$(cat $tempfile)
    case $res in
	"Force")
	    upd_forceimage=1
	    ;;
	"Only compatible")
	    upd_forceimage=0
	    ;;
    esac
}

function upd_select_sysupgrade {
    dialog --keep-tite --radiolist "Use the old way to upgrade a board" \
	   $((lines -5)) $((cols -5)) $((lines -5 -5)) \
	   "iopu" "Use the iop upgrade methode"          `if [ "$upd_sysupgrade" == "0" ] ;then echo "ON" ;else echo "OFF";fi` \
	   "sysupgrade" "Use the old sysupgrade methode" `if [ "$upd_sysupgrade" == "1" ] ;then echo "ON" ;else echo "OFF";fi` \
	   2> $tempfile

    res=$(cat $tempfile)
    case $res in
	"iopu")
	    upd_sysupgrade=0
	    ;;
	"sysupgrade")
	    upd_sysupgrade=1
	    ;;
    esac
}

function upd_select {

    dialog --keep-tite --ok-label "Select" --cancel-label "Done" --menu "Select Item to change" \
	   $((lines -5)) $((cols -5)) $((lines -5 -5)) \
	   "Firmare file" "$upd_fw_base"\
	   "Host ip" "$upd_host" \
	   "Reboot"               `if [ "$upd_noreboot"   == "0" ] ;then printf "Yes\n" ;else printf "No\n";fi` \
	   "Keep config"          `if [ "$upd_keepconf"   == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi` \
	   "Force bootloader"     `if [ "$upd_forceboot"  == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi` \
	   "Force image upgrade"  `if [ "$upd_forceimage" == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi` \
	   "sysupgrade"           `if [ "$upd_sysupgrade" == "1" ] ;then printf "Yes\n" ;else printf "No\n";fi` \
	   2> $tempfile


    case $(cat $tempfile) in
	"Firmare file")
	    upd_select_file
	    ;;
	"Host ip")
	    upd_select_target
	    ;;
	"Reboot")
	    upd_select_reboot
	    ;;
	"Keep config")
	    upd_select_config
	    ;;
	"Force bootloader")
	    upd_select_forceboot
	    ;;
	"Force image upgrade")
	    upd_select_forceimage
	    ;;
	"sysupgrade")
	    upd_select_sysupgrade
	    ;;
	*)
	    return
	;;
    esac
    upd_select
}
function upd_select_start {
    lines=$(tput lines)
    cols=$(tput cols)
    tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
    trap "rm -f $tempfile" 0 1 2 5 15
    upd_select

}

function ssh_upgrade {
    upd_noreboot=0
    upd_forceboot=0
    upd_keepconf=0
    upd_forceimage=0
    upd_fw_base=""
    upd_fw=""
    upd_host="192.168.1.1"
    upd_sysupgrade=1
    do_dialog=0

    while getopts "f:hnxt:iscb" opt; do
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
		do_dialog=1
		;;
	    s)
		upd_sysupgrade=1
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

	# if target uses pkgtb
	if [ -z "$firmwares"]
	then
	    # pkgtb files can not be streamed so copy over the file witch scp
	    use_scp=1
	    firmwares=$(cd bin/targets/$CONFIG_TARGET_BOARD/generic/; ls -t last.pkgtb)
	fi

	for upd_fw_base in $firmwares
	do
	    #echo "firmware $upd_fw"
	    break
	done
	upd_fw="bin/targets/$CONFIG_TARGET_BOARD/generic/$upd_fw_base"
    fi

    [ $do_dialog -eq 1 ] && upd_select_start

    if ! upd_ask_ok
    then
	upd_select_start
	if ! upd_ask_ok
	then
	    exit 1
	fi
    fi

    if [ ! -f $upd_fw ]
    then
	echo "firmware file $firmware do not exist"
	exit 1
    fi

    if [ $upd_sysupgrade -eq 0 ]
    then
	extra_args=""
	[ $upd_noreboot   -eq 1 ] && extra_args="$extra_args -n"
	[ $upd_forceimage -eq 1 ] && extra_args="$extra_args -x"
	[ $upd_forceboot  -eq 1 ] && extra_args="$extra_args -b"

	file_size_kb=`du -k "$upd_fw" | cut -f1`
	if [ "$use_scp" == "1" ]
	then
	    scp $upd_fw root@$upd_host:/tmp/ &&
		ssh -o ConnectTimeout=60 root@$upd_host "iopu $extra_arg -f /tmp/$upd_fw_base"
	else
	    cat $upd_fw | pv -s ${file_size_kb}k | ssh root@$upd_host "iopu $extra_args"
	fi
    else
	scp $upd_fw root@$upd_host:/tmp/ &&
	    ssh -o ConnectTimeout=60 root@$upd_host "sysupgrade -v $3 /tmp/$upd_fw_base" &&
	    echo "sysupgrade done!"
    fi
}

register_command "ssh_upgrade" "-h <host> -f <file> [opts]  Install firmware on remote host with SSH"


