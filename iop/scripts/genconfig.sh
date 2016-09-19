#!/bin/bash

function genconfig {
    export CLEAN=0
    export IMPORT=0
    export SRCTREEOVERR=0
    export FILEDIR="files/"
    export CONFIGPATH="package/feeds/feed_inteno_packages/iop/configs"  
    export CUSTCONF="customerconfigs"
    export VERBOSE=0
    export DEVELOPER=0
    LOCAL_MIRROR="http://mirror.inteno.se/mirror"

    iopsys_brcm63xx_mips="cg300 cg301 dg150 dg150v2 dg150alv2 dg200 dg200al dg301 dg301al eg300 vg50 vox25"
    iopsys_brcm63xx_arm="dg400 eg400"
    iopsys_ramips="ex300"
    ramips="mt7621"
    target="bogus"
    masterconfig=1

    set_target() {

	local profile=$1

	for p in $iopsys_brcm63xx_mips; do
            if [ $p == $profile ]; then
		target="iopsys_brcm63xx_mips"
		return
            fi
	done

	for p in $iopsys_brcm63xx_arm; do
            if [ $p == $profile ]; then
		target="iopsys_brcm63xx_arm"
		return
            fi
	done

	for p in $iopsys_ramips; do
            if [ $p == $profile ]; then
		target="iopsys_ramips"
		masterconfig=0
		return
            fi
	done

	for p in $ramips; do
            if [ $p == $profile ]; then
		target="ramips"
		masterconfig=0
		return
            fi
	done

    }


    git remote -v | grep -q http || {
	DEVELOPER=1

	bcmAllowed=0
	iceAllowed=0
	endptAllowed=0
	natalieAllowed=0

	allowedRepos="$(ssh -o ConnectTimeout=5 git@private.inteno.se 2>/dev/null  | grep -w 'R\|W' | awk '{print$NF}')"
	for repo in $allowedRepos; do
	    case $repo in
		bcmkernel) bcmAllowed=1 ;;
		ice-client) iceAllowed=1 ;;
		endptcfg) endptAllowed=1 ;;
		natalie-dect*) natalieAllowed=1 ;;
	    esac
	done
    }

    v() {
	[ "$VERBOSE" -ge 1 ] && echo "$@"
    }

    usage() {
        echo
        echo 1>&2 "Usage: $0 [OPTIONS] BoardConfig Customerconfig"
        echo
	echo "  -c,  remove all files under ./files and import from config "
	echo "  -v,  verbose"
	echo "  -u, Update customer config before applying"  
	echo "	-p, set profile (if exists)"
	echo "	-t, use latest git tag and number of commits since as version for the build"
	echo "  -s, enable 'Package source tree override'"
	echo 
        echo "BoardConfig ex "
	ls -1 configs
	if [ -d "$CUSTCONF/$1" ]; then
            echo "Customerconfig ex"
	    ls  $CUSTCONF/*
	fi  
	echo
	echo "Example ./genconfig vg50 TELIA" 
        echo "(if no customerconfig is chosen the Inteno Config will be used)"
	echo 	
        exit 127
    }

    use_local_mirror()
    {
	if wget -T 3 -t 2 -O /dev/null $LOCAL_MIRROR >/dev/null 2>/dev/null
	then
	    echo "mirror [$LOCAL_MIRROR] exists. Using local mirror"
	    sed -i "s;CONFIG_LOCALMIRROR=.*;CONFIG_LOCALMIRROR=\"$LOCAL_MIRROR\";" .config
	else
	    echo "mirror [$LOCAL_MIRROR] does not exist. Not using local mirror"
	fi
    }

    generate_config()
    {
	DIFFFILE="$1"
	MASTERFILE="$2"
	while read p; do
	    v  "$p"
	    sed -r -i "$p" $MASTERFILE
	done < $DIFFFILE
    }

    setup_dirs()
    {
	if [ $DEVELOPER -eq 1 ]; then
	    if [ ! -d "$CUSTCONF" ]; then
		git  clone  git@private.inteno.se:customerconfigs
	    elif [ $IMPORT -eq 1 ]; then
		cd customerconfigs
		v "git pull"
		git pull
		cd ..
	    fi
	fi


	if [ ! -d "$FILEDIR" ]; then
	    mkdir $FILEDIR
	elif  [ -d "$FILEDIR" -a $CLEAN -eq 1 ]; then
	    v "rm -rf $FILEDIR*"	
	    rm -rf $FILEDIR*
	fi
    }


    create_and_copy_files()
    {
	local BOARDTYPE=$1
	local CUSTOMER=$2

	# Validate seleced board and customer
	set_target $BOARDTYPE
	if [ $target == "bogus" ]; then
	    echo "Hardware profile does not exist"
	    exit 1
	elif [ -n "$CUSTOMER" -a ! -d "$CUSTCONF/$BOARDTYPE/$CUSTOMER/" ]; then
	    echo "Customer profile does not exist"
	    exit 1
	fi

	# Generate base config 
	# Used only for iopsys targets, not openwrt targets
	rm -f .config
	if [ $masterconfig -eq 1 ]; then
	    v  "Config $BOARDTYPE selected"
	    v "cp  $CONFIGPATH/config  .config"
	    cp  $CONFIGPATH/config  .config
	fi

	# Apply profile diff to master config if selected
	if [ -n "$PROFILE" ]; then 
	    if [ -e "$CONFIGPATH/$PROFILE.diff" ]; then
		cat $CONFIGPATH/$PROFILE.diff >> .config
	    elif [ "$PROFILE" == "juci" ]; then
		v "Default profile (juci) is selected."
	    else
		echo "ERROR: profile $PROFILE does not exist!"
		exit 1
	    fi
	else 
	    v "No profile selected! Using default."
	fi
	
	# Set target and profile
	echo "CONFIG_TARGET_${target}=y" >> .config
	echo "CONFIG_TARGET_${target}_${BOARDTYPE}=y" >> .config

	echo "$BOARDTYPE $CUSTOMER" > .current_config_file

	# Add customerconfig diff if a customer is selected
	if [ -n "$CUSTOMER" ]; then
	    if [ -d "$CUSTCONF/$BOARDTYPE/$CUSTOMER/fs" ]; then
		v "cp -rLp $CUSTCONF/$BOARDTYPE/$CUSTOMER/fs/* $FILEDIR"
		cp -rLp $CUSTCONF/$BOARDTYPE/$CUSTOMER/fs/* $FILEDIR
	    fi
	    if [ -e "$CUSTCONF/$BOARDTYPE/$CUSTOMER/$BOARDTYPE.diff" ]; then
		v "Apply $CUSTCONF/$BOARDTYPE/$CUSTOMER/$BOARDTYPE.diff"
		cat $CUSTCONF/$BOARDTYPE/$CUSTOMER/$BOARDTYPE.diff >> .config
	    fi
	fi

	# Set target version
	local GIT_TAG=$(git describe --abbrev=0 --tags)
	echo "CONFIG_TARGET_VERSION=\"${GIT_TAG}\"" >> .config


	# Enable Pckage source tree override if selected
	[ $SRCTREEOVERR -eq 1 ] && \
            echo CONFIG_SRC_TREE_OVERRIDE=y >> .config


	# developer mode selected ?
	if [ $DEVELOPER -eq 1 ]; then
	    # rewrite url to clone with ssh instead of http
	    echo "CONFIG_DEVEL=y" >>.config
	    echo "CONFIG_GITMIRROR_REWRITE=y" >>.config
	    [ $bcmAllowed -eq 0 ] && echo "CONFIG_BCM_OPEN=y" >> .config
	    [ $iceAllowed -eq 0 ] && echo "CONFIG_ICE_OPEN=y" >> .config
	    [ $endptAllowed -eq 0 ] && echo "CONFIG_ENDPT_OPEN=y" >> .config
	    [ $natalieAllowed -eq 0 ] && echo "CONFIG_NATALIE_OPEN=y" >> .config
	else
	    echo "CONFIG_BCM_OPEN=y" >> .config
	    echo "CONFIG_ICE_OPEN=y" >> .config
	    echo "CONFIG_ENDPT_OPEN=y" >> .config
	    echo "CONFIG_NATALIE_OPEN=y" >> .config
	fi
	
	# Force regeneration of kernel Makefile
	# Needed to disable kmods for iopsys-brcm targets
	touch package/kernel/linux/Makefile
	
	# Set default values based on selected parameters
	make defconfig

	# Temporary fixup for juci/luci profile
	if [ "$PROFILE" == "luci" ]; then
	    sed -i '/CONFIG_DEFAULT_juci/d' .config
	    sed -i '/CONFIG_PACKAGE_juci/d' .config
	    sed -i '/CONFIG_PACKAGE_uhttpd/d' .config
	fi

	if [ $masterconfig -eq 1 ]; then
	    echo Set version to $(grep -w CONFIG_TARGET_VERSION .config | cut -d'=' -f2 | tr -d '"')
	fi

	# Clean base-file package to force rebuild when changing profile
	make package/base-files/clean


    }

    ####### main #####
    if [ ! -e tmp/.iop_bootstrap ]; then
	echo "You have not installed feeds. Running genconfig in this state would create a non functional configuration."
	echo "Run: iop feeds_update"
	exit 0
    fi

    if [ $# -eq 0 ]; then
	echo Current profile:
	cat .current_config_file
	echo "Try ./iop_get_config.sh -h' to get instructions if you want to change current config"
	exit 0
    else
	
	while [ -n "$1" ]; do 
	    case "$1" in

		-c) export CLEAN=1;;
		-u) export IMPORT=1;;
		-v) export VERBOSE="$(($VERBOSE + 1))";;
		-p) export PROFILE="$2"; shift;; 
		-t) export USE_TAG=1;; 
		-s) export SRCTREEOVERR=1;;
		-h) usage;;
		-*)
		    echo "Invalid option: $1 "
		    echo "Try  -h' for more information."
		    exit 1
		    ;;
		*) break;;
	    esac
	    shift;
	done
	setup_dirs
	create_and_copy_files "$1" "$2"

	if [ $masterconfig -eq 1 ]; then
	    use_local_mirror
	fi
    fi
}


register_command "genconfig" "Generate configuration for board and customer"
