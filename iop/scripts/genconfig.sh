#!/bin/bash

function genconfig {
	export CLEAN=0
	export IMPORT=1
	export SRCTREEOVERR=0
	export FILEDIR="files/"
	export THEMEDIR="themes"
	CURRENT_CONFIG_FILE=".current_config_file"
	export CONFIGPATH="package/feeds/iopsys/iop"
	CUSTPATH="customerconfigs"
	export CUSTCONF="customerconfigs/customers"
	export VERBOSE=0
	export DEVELOPER=0
	target="bogus"
	target_config_path=""
	brcm63xx_mips="target/linux/iopsys-brcm63xx-mips"
	brcm63xx_arm="target/linux/iopsys-brcm63xx-arm"
	ramips="target/linux/iopsys-ramips"
	intel_mips="target/linux/intel_mips"
	x86="target/linux/iopsys-x86"
	armvirt="target/linux/iopsys-armvirt"

	Red='\033[0;31m'          # Red
	Color_Off='\033[0m'       # Text Reset
	Yellow='\033[0;33m'       # Yellow

	function find_last {
	    egrep "^[ #]*${1}[ =]" $2 | tail -n1
	}

	function is_new {
	    for opt in $conf_warned
	    do
		if [ "$opt" == "$1" ]
		then
		    return 1
		fi
	    done
	    # option not found return true
	    return 0
	}

	function verify_config {
	    IFS=$'\n'
	    org=$(<.genconfig.config)
	    unset IFS
	    local num
	    local conf_opt
	    local conf_org
	    local conf_new

	    #echo "lines to check $tot_lines"
	    num=0
	    for line in $org
	    do
		conf_opt=$(echo $line | grep CONFIG_ | sed 's|.*\(CONFIG_[^ =]*\)[ =].*|\1|')
		if [ -n "${conf_opt}" ]
		then
		    conf_org=$(find_last ${conf_opt} .genconfig.config)
		    conf_new=$(find_last ${conf_opt} .config)
		    if [ "$conf_org" != "$conf_new" ]
		    then
			if is_new $conf_opt
			then
			    echo -e "config option [${Red}$conf_opt${Color_Off}] is not set correctly in .config"
			    echo -e "got value [${Yellow}$conf_new${Color_Off}] but wanted [${Yellow}$conf_org${Color_Off}]"
			    echo "This is a real problem somebody needs to investigate"
			    echo ""
			    conf_warned="$conf_warned $conf_opt"
			fi
		    else
			true
			# for debug to see all options
			#echo -e "wanted [$conf_org] got [$conf_new]"
		    fi
		fi
		num=$((num+1))
	    done
	}

	# Takes a board name and returns the target name in global var $target
	set_target() {
		local profile=$1

		[ -n "$profile" ] || return

		if [ -n "$TARGET" -a -d "./target/linux/$TARGET" ]; then
			local targetpath="./target/linux/$TARGET"
			local profiles=
			local pfound=0

			if [ -e "$targetpath/genconfig" ]; then
				profiles=$(cd $targetpath; ./genconfig)

				for p in $profiles; do
					if [ $p == $profile ]; then
						pfound=1
						break
					fi
				done
			fi

			if [ $pfound -eq 1 ]; then
				target="$(echo $TARGET | tr '-' '_')"
				target_config_path="$targetpath/config"
			fi

			return
		fi

		[ -e $brcm63xx_mips/genconfig ] &&
			iopsys_brcm63xx_mips=$(cd $brcm63xx_mips; ./genconfig)
		[ -e $brcm63xx_arm/genconfig ] &&
			iopsys_brcm63xx_arm=$(cd $brcm63xx_arm; ./genconfig)
		[ -e $ramips/genconfig ] &&
			iopsys_ramips=$(cd $ramips; ./genconfig)
		[ -e $intel_mips/genconfig ] &&
			iopsys_intel_mips=$(cd $intel_mips; ./genconfig)
		[ -e $x86/genconfig ] &&
			iopsys_x86=$(cd $x86; ./genconfig)
		[ -e $armvirt/genconfig ] &&
			iopsys_armvirt=$(cd $armvirt; ./genconfig)

	    if [ "$profile" == "LIST" ]; then
			for list in iopsys_brcm63xx_mips iopsys_brcm63xx_arm iopsys_ramips iopsys_intel_mips iopsys_x86 iopsys_armvirt; do
				echo "$list based boards:"
				for b in ${!list}; do
					echo -e "\t$b"
				done
			done
			return
	    fi

	    for p in $iopsys_brcm63xx_mips; do
		if [ $p == $profile ]; then
		    target="iopsys_brcm63xx_mips"
			target_config_path="$brcm63xx_mips/config"
		    return
		fi
	    done

	    for p in $iopsys_brcm63xx_arm; do
		if [ $p == $profile ]; then
		    target="iopsys_brcm63xx_arm"
			target_config_path="$brcm63xx_arm/config"
		    return
		fi
	    done

	    for p in $iopsys_ramips; do
		if [ $p == $profile ]; then
		    target="iopsys_ramips"
			target_config_path="$ramips/config"
		    return
		fi
	    done

	    for p in $iopsys_intel_mips; do
		if [ $p == $profile ]; then
		    target="intel_mips"
			target_config_path="$intel_mips/config"
		    return
		fi
	    done

	    for p in $iopsys_x86; do
		if [ $p == $profile ]; then
		    target="iopsys_x86"
			target_config_path="$x86/config"
		    return
		fi
	    done

	    for p in $iopsys_armvirt; do
		if [ $p == $profile ]; then
		    target="iopsys_armvirt"
			target_config_path="$armvirt/config"
		    return
		fi
	    done

	}

	git remote -v | grep -qE '(git@|ssh://)' && {
		DEVELOPER=1

		bcmAllowed=0
		endptAllowed=0
		natalieAllowed=0
		mediatekAllowed=0

		git ls-remote git@dev.iopsys.eu:broadcom/bcmcreator.git -q 2>/dev/null && bcmAllowed=1
		git ls-remote git@dev.iopsys.eu:mediatek/linux.git -q 2>/dev/null && mediatekAllowed=1
		git ls-remote git@dev.iopsys.eu:dialog/natalie-dect-12.26.git -q 2>/dev/null && natalieAllowed=1
		git ls-remote git@dev.iopsys.eu:iopsys/endptmngr.git -q 2>/dev/null && endptAllowed=1
	}

	v() {
		[ "$VERBOSE" -ge 1 ] && echo "$@"
	}

	usage() {
		echo
		echo 1>&2 "Usage: $0 [ OPTIONS ] < Board_Type > [ Customer [customer2 ]...]"
		echo
		echo -e "  -c|--clean\t\tRemove all files under ./files and import from config "
		echo -e "  -v|--verbose\t\tVerbose"
		echo -e "  -n|--no-update\tDo NOT! Update customer config before applying"
		echo -e "  -t|--target\t\tExplicitly specify the linux target to build the board profile from"
		echo -e "  -s|--override\t\tEnable 'Package source tree override'"
		echo -e "  -S|--brcmsingle\tForce build of bcmkernel to use only one thread"
		echo -e "  -h|--help\t\tShow this message"
		echo -e "  -l|--list [customer]\tList all Customers or all boards for one customer"
		echo -e "  -a|--list-all\t\tList all Customers and their board types"
		echo -e "  -b|--boards\t\tList all board types"
		echo
		echo "Example ./iop genconfig eg400 OPERATORX"
		echo "(if no customerconfig is chosen, iopsys config will be used)"
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
		git remote -v | grep -q http || {
			if git ls-remote $CUSTREPO -q 2>/dev/null; then
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
		}

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
		rm -f .config
		v "Config $BOARDTYPE selected"
		v "cp $CONFIGPATH/config .config"
		cp $CONFIGPATH/config .config

		if [ -f $target_config_path/config ]; then
		    cat $target_config_path/config >> .config
		    echo "" >> .config
		fi
		if [ -f $target_config_path/$BOARDTYPE/config ]; then
		    cat $target_config_path/$BOARDTYPE/config >> .config
		    echo "" >> .config
		fi

		#special handling for intel_mips/iopsys_ramips which use TARGET_DEVICES
		if [ "$target" = "intel_mips" ]; then
			subtarget="xrx500"
			echo "CONFIG_TARGET_${target}=y" >> .config
			echo "CONFIG_TARGET_${target}_${subtarget}=y" >> .config
			echo "CONFIG_TARGET_MULTI_PROFILE=y" >> .config
			echo "CONFIG_TARGET_PER_DEVICE_ROOTFS=y" >> .config
			device=$(echo $BOARDTYPE | tr a-z A-Z)
			echo "CONFIG_TARGET_DEVICE_${target}_${subtarget}_DEVICE_${device}=y" >> .config
		elif [ "$target" = "iopsys_ramips" ]; then
			subtarget="mt7621"
			echo "CONFIG_TARGET_${target}=y" >> .config
			echo "CONFIG_TARGET_${target}_${subtarget}=y" >> .config
			echo "CONFIG_TARGET_${target}_${subtarget}_DEVICE_${BOARDTYPE}=y" >> .config
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
					echo "" >> .config
				fi
				if [ -e "$CUSTCONF/$CUSTOMER/$BOARDTYPE/$BOARDTYPE.diff" ]; then
					v "Apply $CUSTCONF/$CUSTOMER/$BOARDTYPE/$BOARDTYPE.diff"
					cat $CUSTCONF/$CUSTOMER/$BOARDTYPE/$BOARDTYPE.diff >> .config
					echo "" >> .config
				fi
			done
		fi

		# Set target version
		local GIT_TAG=$(git describe --abbrev=0 --tags)
		echo "CONFIG_TARGET_VERSION=\"${GIT_TAG}\"" >> .config
		echo "CONFIG_VERSION_CODE=\"${GIT_TAG}\"" >> .config
		echo "CONFIG_VERSION_PRODUCT=\"$BOARDTYPE"\" >> .config

		# Enable Pckage source tree override if selected
		[ $SRCTREEOVERR -eq 1 ] && echo CONFIG_SRC_TREE_OVERRIDE=y >> .config

		# developer mode selected ?
		echo "CONFIG_DEVEL=y" >>.config
		if [ $DEVELOPER -eq 1 ]; then
			# rewrite url to clone with ssh instead of http
			echo "CONFIG_GITMIRROR_REWRITE=y" >>.config
			[ $bcmAllowed -eq 0 ] && echo "CONFIG_BCM_OPEN=y" >> .config
			[ $endptAllowed -eq 0 ] && echo "CONFIG_ENDPT_OPEN=y" >> .config
			[ $natalieAllowed -eq 0 ] && echo "CONFIG_NATALIE_OPEN=y" >> .config
			[ $mediatekAllowed -eq 0 ] && echo "CONFIG_MEDIATEK_OPEN=y" >> .config
		else
			echo "# CONFIG_GITMIRROR_REWRITE is not set" >>.config
			echo "CONFIG_BCM_OPEN=y" >> .config
			echo "CONFIG_ENDPT_OPEN=y" >> .config
			echo "CONFIG_NATALIE_OPEN=y" >> .config
			echo "CONFIG_MEDIATEK_OPEN=y" >> .config
		fi

		if [ -n "$BRCM_MAX_JOBS" ]
		then
		    echo "CONFIG_BRCM_MAX_JOBS=\"1\"" >>.config
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

		# Store generated config
		cp .config .genconfig.config

		# Set default values based on selected parameters
		v "$(make defconfig 2>&1)"

		echo Set version to $(grep -w CONFIG_TARGET_VERSION .config | cut -d'=' -f2 | tr -d '"')

		# Clean base-file package to force rebuild when changing profile
		v "$(make package/base-files/clean 2>&1)"

		verify_config
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
			-t|--target) export TARGET="$2"; shift;;
			-p|--profile) export PROFILE="$2"; shift;;
			-r|--repo) export CUSTREPO="$2"; shift;;
			-s|--override) export SRCTREEOVERR=1;;
			-S|--brcmsingel) export BRCM_MAX_JOBS=1;;
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

		CUSTREPO="${CUSTREPO:-git@dev.iopsys.eu:consumer/iopsys.git}"

		setup_dirs
		create_and_copy_files "$@"
	fi
}

register_command "genconfig" "Generate configuration for board and customer"
