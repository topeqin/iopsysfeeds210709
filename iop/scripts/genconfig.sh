#!/bin/bash

function genconfig {
	export CLEAN=0
	export IMPORT=1
	export SRCTREEOVERR=0
	export FILEDIR="files/"
	export THEMEDIR="themes"
	CURRENT_CONFIG_FILE=".current_config_file"
	export CONFIGPATH="package/feeds/feed_inteno_packages/iop/configs"
	CUSTPATH="customerconfigs"
	CUSTREPO="git@private.inteno.se:customerconfigs"
	export CUSTCONF="customerconfigs/customers"
	export VERBOSE=0
	export DEVELOPER=0
	LOCAL_MIRROR="http://mirror.inteno.se/mirror"

	iopsys_brcm63xx_mips="cg300 cg301 dg150 dg150v2 dg150alv2 dg200 dg200al dg301 dg301al eg300 vg50 vox25"
	iopsys_brcm63xx_arm="dg400 eg400"
	iopsys_ramips="ex400"
	ramips="mt7621"
	target="bogus"
	masterconfig=1

	set_target()
	{
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

		allowedRepos="$(ssh -o ConnectTimeout=5 git@private.inteno.se 2>/dev/null | grep -w 'R\|W' | awk '{print$NF}')"
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
		echo 1>&2 "Usage: $0 [ OPTIONS ] < Board_Type > [ Customer ]"
		echo
		echo -e "  -c|--clean\tRemove all files under ./files and import from config "
		echo -e "  -v|--verbose\tVerbose"
		echo -e "  -n|--no-update\tDo NOT! Update customer config before applying"
		echo -e "  -p|--profile\tSet profile (if exists) default juci"
		echo -e "  -s|--override\tEnable 'Package source tree override'"
		echo -e "  -h|--help\tShow this message"
		echo -e "  -l|--list [customer]\tList all Customers or all boards for one customer"
		echo -e "  -a|--list-all\tList all Customers and their board types"
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
			local boards="$(ls -1 "$CUSTCONF/$CUSTOMER" | grep -v common)"
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
			if [ "$customers" -a "$1" == 1 ]; then
				for customer in $customers; do
					echo $customer
					local boards="$(ls -1 $CUSTCONF/$customer | grep -v common)"
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


	use_local_mirror()
	{
		if wget -T 3 -t 2 -O /dev/null $LOCAL_MIRROR >/dev/null 2>/dev/null; then
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
		v "$p"
		sed -r -i "$p" $MASTERFILE
	done < $DIFFFILE
	}

	setup_dirs()
	{
		if [ $DEVELOPER -eq 1 ]; then
			if [ ! -d "$CUSTPATH" ]; then
			git clone "$CUSTREPO" "$CUSTPATH"
			elif [ $IMPORT -eq 1 ]; then
			cd $CUSTPATH
			v "git pull"
			git pull
			cd - >/dev/null #go back
			fi
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
		local CUSTOMER=$2

		# Validate seleced board and customer
		set_target $BOARDTYPE
		if [ $target == "bogus" ]; then
			echo "Hardware profile does not exist"
			exit 1
		elif [ -n "$CUSTOMER" -a ! -d "$CUSTCONF/$CUSTOMER/$BOARDTYPE/" ]; then
			echo "Customer profile does not exist"
			exit 1
		fi

		# Generate base config
		# Used only for iopsys targets, not openwrt targets
		rm -f .config
		if [ $masterconfig -eq 1 ]; then
			v "Config $BOARDTYPE selected"
			v "cp $CONFIGPATH/config .config"
			cp $CONFIGPATH/config .config
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

		echo "$CUSTOMER $BOARDTYPE" > $CURRENT_CONFIG_FILE

		# Add customerconfig diff if a customer is selected
		if [ -n "$CUSTOMER" ]; then
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
		fi

		# Set target version
		local GIT_TAG=$(git describe --abbrev=0 --tags)
		echo "CONFIG_TARGET_VERSION=\"${GIT_TAG}\"" >> .config

		# Enable Pckage source tree override if selected
		[ $SRCTREEOVERR -eq 1 ] && echo CONFIG_SRC_TREE_OVERRIDE=y >> .config

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
			-s|--override) export SRCTREEOVERR=1;;
			-h|--help) usage;;
			-l|--list) list_customers 0 $2;;
			-a|--list-all)list_customers 1;;
			-*)
				echo "Invalid option: $1 "
				echo "Try -h or --help for more information."
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
