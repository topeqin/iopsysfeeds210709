#!/bin/bash

function genconfig {
	export CLEAN=0
	export IMPORT=1
	export SRCTREEOVERR=0
	export FILEDIR="files/"
	export THEMEDIR="themes"
	CURRENT_CONFIG_FILE=".current_config_file"
	export CONFIGPATH="package/feeds/iopsys/iop/configs"
	CUSTPATH="customerconfigs"
	export CUSTCONF="customerconfigs/customers"
	export VERBOSE=0
	export DEVELOPER=0
	LOCAL_MIRROR="http://mirror.inteno.se/mirror"

	target="bogus"
	masterconfig=1

	# Takes a board name and returns the target name in global var $target
	set_target() {
	    local profile=$1

	    local iopsys_brcm63xx_mips=$(cd target/linux/iopsys-brcm63xx-mips; ./genconfig)
	    local iopsys_brcm63xx_arm=$(cd target/linux/iopsys-brcm63xx-arm; ./genconfig)
	    local iopsys_ramips=$(cd target/linux/iopsys-ramips; ./genconfig)
	    local intel_mips=$(cd target/linux/intel_mips; ./genconfig)

	    if [ "$profile" == "LIST" ]
	    then
		for list in iopsys_brcm63xx_mips iopsys_brcm63xx_arm iopsys_ramips intel_mips
		do
		    echo "$list based boards:"
		    for b in ${!list}
		    do
			echo -e "\t$b"
		    done
		done
		return
	    fi

	    local targets

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

	    for p in $intel_mips; do
		if [ $p == $profile ]; then
		    target="intel_mips"
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
		mediatekAllowed=0
		wifilifeAllowed=0

		allowedRepos="$(ssh -o ConnectTimeout=5 git@private.inteno.se 2>/dev/null | grep -w 'R\|W' | awk '{print$NF}')"
		for repo in $allowedRepos; do
			case $repo in
			bcmkernel) bcmAllowed=1 ;;
			ice-client) iceAllowed=1 ;;
			endptcfg) endptAllowed=1 ;;
			natalie-dect*) natalieAllowed=1 ;;
			linux) mediatekAllowed=1 ;;
			wifilife) wifilifeAllowed=1 ;;
			esac
		done
	}

	v() {
		[ "$VERBOSE" -ge 1 ] && echo "$@"
	}

	usage() {
		echo
		echo 1>&2 "Usage: $0 [ OPTIONS ] < Board_Type > [ Customer [customer2 ]...]"
		echo
		echo -e "  -c|--clean\tRemove all files under ./files and import from config "
		echo -e "  -v|--verbose\tVerbose"
		echo -e "  -n|--no-update\tDo NOT! Update customer config before applying"
		echo -e "  -p|--profile\tSet profile (if exists) default juci"
		echo -e "  -s|--override\tEnable 'Package source tree override'"
		echo -e "  -h|--help\tShow this message"
		echo -e "  -l|--list [customer]\tList all Customers or all boards for one customer"
		echo -e "  -a|--list-all\tList all Customers and their board types"
		echo -e "  -b|--boards\tList all board types"		
		echo
		echo "Example ./iop genconfig vg50 TELIA"
		echo "(if no customerconfig is chosen the Inteno Config will be used)"
		echo
		exit 0
	}

	list_customers()
	{
		local ALL="$1"
		local CUSTOMER="$2"
		if [ "$CUSTOMER" -a -d "$CUSTCONF/$CUSTOMER" ]; then
			local boards="$(ls -1 "$CUSTCONF/$CUSTOMER" | grep -v common | grep -v juci-theme)"
			if [ "$boards" ]; then
				echo "$CUSTOMER has following boards:"
				for board in $boards; do
					echo -e "\t$board"
				done
			else
				echo "No boards found for $CUSTOMER"
			fi
		elif [ "$CUSTOMER" ]; then
			echo "No customer called $CUSTOMER"
			exit 1
		elif [ -d $CUSTCONF ]; then
			local customers="$(ls -1 $CUSTCONF)"
			if [ "$customers" -a "$ALL" == 1 ]; then
				for customer in $customers; do
					echo $customer
					local boards="$(ls -1 $CUSTCONF/$customer | grep -v common | grep -v juci-theme)"
					if [ "$boards" ]; then
						for board in $boards; do
							echo -e "\t$board"
						done
					else
						echo "has no boards"
					fi
				done
			elif [ "$customers" ]; then
				echo -e "$customers"
			else
				echo "no customers found"
			fi
		else
			echo "No $CUSTCONF folder found"
		fi
		exit 0
	}


	generate_config()
	{
	DIFFFILE="$1"
	MASTERFILE="$2"
	while read p; do
		v "$p"
		sed -r -i "$p" $MASTERFILE
	done < $DIFFFILE
	}

	setup_dirs()
	{
		if ssh -o ConnectTimeout=5 git@private.inteno.se 2>/dev/null  | grep -qw ${CUSTREPO:22}; then
			if [ ! -d "$CUSTPATH" ]; then
				git clone "$CUSTREPO" "$CUSTPATH"
			elif [ $IMPORT -eq 1 ]; then
				cd $CUSTPATH
				v "git pull"
				git pull
				cd - >/dev/null #go back
			fi
		else
			echo "You do not have access to $CUSTREPO"
		fi

		if [ ! -d "$FILEDIR" ]; then
			mkdir -p $FILEDIR
		elif [ -d "$FILEDIR" -a $CLEAN -eq 1 ]; then
			v "rm -rf $FILEDIR*"
			rm -rf $FILEDIR*
		fi

		if [ ! -d "$THEMEDIR" ]; then
			mkdir -p $THEMEDIR
		elif [ -d "$THEMEDIR" -a $CLEAN -eq 1 ]; then
			v "rm -rf $THEMEDIR/*"
			rm -rf $THEMEDIR/*
		fi
	}

	create_and_copy_files()
	{
		local BOARDTYPE=$1
		shift
		local CUSTOMERS=$@

		# Validate seleced board and customers
		set_target $BOARDTYPE
		if [ $target == "bogus" ]; then
			echo "Hardware profile does not exist"
			exit 1
		elif [ -n "$CUSTOMERS" ]; then
			for CUSTOMER in $CUSTOMERS; do
				if [ ! -d "$CUSTCONF/$CUSTOMER/" ]; then
					echo "Customer profile for '$CUSTOMER' does not exist"
					exit 1
				elif [ ! -d "$CUSTCONF/$CUSTOMER/$BOARDTYPE/" ]; then
					echo "'$BOARDTYPE' board profile does not exist for customer '$CUSTOMER'"
					if [ -f "$CUSTCONF/$CUSTOMER/common/common.diff" ]; then
						echo "Common profile configuration will be used"
					else
						exit 1
					fi
				fi
			done
		fi

		# Generate base config
		# Used only for iopsys targets, not openwrt targets
		rm -f .config
		if [ $masterconfig -eq 1 ]; then
			v "Config $BOARDTYPE selected"
			v "cp $CONFIGPATH/config .config"
			cp $CONFIGPATH/config .config
		fi

		# Add target (soc/board specific )
		if [ -f $CONFIGPATH/target/config ]; then
		    cat $CONFIGPATH/target/config >> .config
		fi
		if [ -f $CONFIGPATH/target/$target/config ]; then
		    cat $CONFIGPATH/target/$target/config >> .config
		fi
		if [ -f $CONFIGPATH/target/$target/$BOARDTYPE/config ]; then
		    cat $CONFIGPATH/target/$target/$BOARDTYPE/config >> .config
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

		#special handling for intel_mips which use TARGET_DEVICES
		if [ "$target" = "intel_mips" ]; then
			subtarget="xrx500"
			echo "CONFIG_TARGET_${target}=y" >> .config
			echo "CONFIG_TARGET_${target}_${subtarget}=y" >> .config
			echo "CONFIG_TARGET_MULTI_PROFILE=y" >> .config
			echo "CONFIG_TARGET_PER_DEVICE_ROOTFS=y" >> .config
			device=$(echo $BOARDTYPE | tr a-z A-Z)
			echo "CONFIG_TARGET_DEVICE_${target}_${subtarget}_DEVICE_${device}=y" >> .config
		else
			echo "CONFIG_TARGET_${target}=y" >> .config
			echo "CONFIG_TARGET_${target}_${BOARDTYPE}=y" >> .config
		fi

		echo "$CUSTOMERS $BOARDTYPE" > $CURRENT_CONFIG_FILE

		# Add customerconfig diff if a customer is selected
		if [ -n "$CUSTOMERS" ]; then
			for CUSTOMER in $CUSTOMERS; do
				if [ -d "$CUSTCONF/$CUSTOMER/common/fs" ]; then
					v "cp -ar $CUSTCONF/$CUSTOMER/common/fs/* $FILEDIR"
					cp -ar $CUSTCONF/$CUSTOMER/common/fs/* $FILEDIR
				fi
				if [ -d "$CUSTCONF/$CUSTOMER/$BOARDTYPE/fs" ]; then
					v "cp -ar $CUSTCONF/$CUSTOMER/$BOARDTYPE/fs/* $FILEDIR"
					cp -ar $CUSTCONF/$CUSTOMER/$BOARDTYPE/fs/* $FILEDIR
				fi
				if [ -d "$CUSTCONF/$CUSTOMER/juci-theme" ]; then
					customer="$(echo $CUSTOMER | tr 'A-Z' 'a-z')"
					v "cp -ar $CUSTCONF/$CUSTOMER/juci-theme $THEMEDIR/juci-theme-$customer"
					cp -ar $CUSTCONF/$CUSTOMER/juci-theme $THEMEDIR/juci-theme-$customer
				fi
				if [ -e "$CUSTCONF/$CUSTOMER/common/common.diff" ]; then
					v "Apply $CUSTCONF/$CUSTOMER/common/common.diff"
					cat $CUSTCONF/$CUSTOMER/common/common.diff >> .config
				fi
				if [ -e "$CUSTCONF/$CUSTOMER/$BOARDTYPE/$BOARDTYPE.diff" ]; then
					v "Apply $CUSTCONF/$CUSTOMER/$BOARDTYPE/$BOARDTYPE.diff"
					cat $CUSTCONF/$CUSTOMER/$BOARDTYPE/$BOARDTYPE.diff >> .config
				fi
			done
		fi

		# Set target version
		local GIT_TAG=$(git describe --abbrev=0 --tags)
		echo "CONFIG_TARGET_VERSION=\"${GIT_TAG}\"" >> .config

		# Enable Pckage source tree override if selected
		[ $SRCTREEOVERR -eq 1 ] && echo CONFIG_SRC_TREE_OVERRIDE=y >> .config

		# developer mode selected ?
		echo "CONFIG_DEVEL=y" >>.config
		if [ $DEVELOPER -eq 1 ]; then
			# rewrite url to clone with ssh instead of http
			echo "CONFIG_GITMIRROR_REWRITE=y" >>.config
			[ $bcmAllowed -eq 0 ] && echo "CONFIG_BCM_OPEN=y" >> .config
			[ $iceAllowed -eq 0 ] && echo "CONFIG_ICE_OPEN=y" >> .config
			[ $endptAllowed -eq 0 ] && echo "CONFIG_ENDPT_OPEN=y" >> .config
			[ $natalieAllowed -eq 0 ] && echo "CONFIG_NATALIE_OPEN=y" >> .config
			[ $mediatekAllowed -eq 0 ] && echo "CONFIG_MEDIATEK_OPEN=y" >> .config
			[ $wifilifeAllowed -eq 0 ] && echo "CONFIG_WIFILIFE_OPEN=y" >> .config
		else
			echo "CONFIG_GITMIRROR_REWRITE=n" >>.config
			echo "CONFIG_BCM_OPEN=y" >> .config
			echo "CONFIG_ICE_OPEN=y" >> .config
			echo "CONFIG_ENDPT_OPEN=y" >> .config
			echo "CONFIG_NATALIE_OPEN=y" >> .config
			echo "CONFIG_MEDIATEK_OPEN=y" >> .config
			echo "CONFIG_WIFILIFE_OPEN=y" >> .config
		fi

		# Force regeneration of themes
		touch package/feeds/juci/juci/Makefile

		# Force regeneration of kernel Makefile
		# Needed to disable kmods for iopsys-brcm targets
		touch package/kernel/linux/Makefile

		# we need to signal to bradcom SDK that we have changed the board id
		# currently boardparms.c and boardparms_voice.c is the only place that is depending on inteno boardid name
		# so just touch that file.
		[ -d ./build_dir ] && find build_dir/ -name "boardparms*c" -print0 2>/dev/null | xargs -0 touch 2>/dev/null
				
		# Set default values based on selected parameters
		v "$(make defconfig 2>&1)"

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
		v "$(make package/base-files/clean 2>&1)"
	}

	####### main #####
	if [ ! -e tmp/.iop_bootstrap ]; then
		echo "You have not installed feeds. Running genconfig in this state would create a non functional configuration."
		echo "Run: iop feeds_update"
		exit 0
	fi

	if [ $# -eq 0 ]; then
		echo Current profile:
		cat $CURRENT_CONFIG_FILE
		echo "Try ./iop genconfig -h' to get instructions if you want to change current config"
		exit 0
	else
		while [ -n "$1" ]; do
			case "$1" in

			-c|--clean) export CLEAN=1;;
			-n|--no-update) export IMPORT=0;;
			-v|--verbose) export VERBOSE="$(($VERBOSE + 1))";;
			-p|--profile) export PROFILE="$2"; shift;;
			-r|--repo) export CUSTREPO="$2"; shift;;
			-s|--override) export SRCTREEOVERR=1;;
			-h|--help) usage;;
			-l|--list) list_customers 0 $2;;
			-a|--list-all)list_customers 1;;
			-b|--boards)set_target LIST;exit 0;;
			-*)
				echo "Invalid option: $1 "
				echo "Try -h or --help for more information."
				exit 1
				;;
			*) break;;
			esac
			shift;
		done

		CUSTREPO="${CUSTREPO:-git@private.inteno.se:customerconfigs}"

		setup_dirs
		create_and_copy_files "$@"
	fi
}

register_command "genconfig" "Generate configuration for board and customer"
