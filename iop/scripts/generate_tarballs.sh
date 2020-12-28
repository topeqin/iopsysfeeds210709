#!/bin/bash
# shellcheck disable=SC2029

build_bcmkernel_consumer() {
	local tarfile bcmkernelcommith sdkversion serverpath serverlink

	sdkversion="$(grep "CONFIG_BRCM_SDK_VER.*=y" .config | awk -F'[_,=]' '{print$5}')"
	sdkversion="${sdkversion:0:4}${sdkversion:(-1)}"
	bcmkernelcommith="$(grep -w "PKG_SOURCE_VERSION:" "$curdir/feeds/broadcom/bcmkernel/${sdkversion:0:5}"*".mk" | cut -d'=' -f2)"

	[ -n "$board" ] && [ -n "$bcmkernelcommith" ] || return

	serverpath="$FPATH/bcmopen-$board-$bcmkernelcommith.tar.gz"
	serverlink="$FPATH/bcmopen-$board-$majver.$minver-latest"

	# do not build bcmopen sdk if it was already built before
	# if it was, check if there's a symlink in place and create it if missing
	ssh "$SERVER" "test -f '$serverpath' && { test -L '$serverlink' || ln -sf '$serverpath' '$serverlink'; }" && return

	cd "./build_dir/target-"*"/bcmkernel-"*"-${sdkversion:0:4}"*"/bcm963xx/release"
	bash do_consumer_release -p "$profile" -y -F

	tarfile='out/bcm963xx_*_consumer.tar.gz'
	[ $(ls -1 $tarfile | wc -l) -ne 1 ] && echo "Too many tar files: '$tarfile'" && return

	scp -pv $tarfile "$SERVER":"$serverpath"
	ssh "$SERVER" "test -f '$serverpath' && ln -sf '$serverpath' '$serverlink'"
	rm -f $tarfile

	cd "$curdir"
}

build_endptmngr_consumer() {
	# create endptmngr open version tar file
	local endptversion endptcommith
	grep -q "CONFIG_TARGET_NO_VOICE=y" .config && return
	endptversion=$(grep -w "PKG_VERSION:" ./feeds/iopsys/endptmngr/Makefile | cut -d'=' -f2)
	endptcommith=$(grep -w "PKG_SOURCE_VERSION:" ./feeds/iopsys/endptmngr/Makefile | cut -d'=' -f2)
	[ -n "$profile" ] && [ -n "$endptversion" ] && [ -n "$endptcommith" ] || return
	ssh $SERVER "test -f $FPATH/endptmngr-$profile-$endptversion-$endptcommith.tar.gz" && return
	cd ./build_dir/target-*/endptmngr-$endptversion/
	mkdir endptmngr-open-$endptversion
	mkdir endptmngr-open-$endptversion/src
	cp ./src/endptmngr endptmngr-open-$endptversion/src
	cp -r ./files/ endptmngr-open-$endptversion/
	tar -czv  endptmngr-open-$endptversion/ -f endptmngr-$profile-$endptversion-$endptcommith.tar.gz
	scp -pv endptmngr-$profile-$endptversion-$endptcommith.tar.gz $SERVER:$FPATH/
	cp endptmngr-$profile-$endptversion-$endptcommith.tar.gz $curdir/
	rm -rf endptmngr-open-$endptversion
	rm -f endptmngr-$profile-$endptversion-$endptcommith.tar.gz
	cd "$curdir"
}

function print_usage {
	echo "Usage: $0 generate_tarballs"
	echo "  -t <target>"
}

function generate_tarballs {

    SERVER="god@download.iopsys.eu"
    FPATH="/var/www/html/iopsys/opensdk"

    set -e
    git remote -v | grep -q http && return # do not continue if this is an open SDK environment

    board=$(grep CONFIG_TARGET_FAMILY .config | cut -d'=' -f2 | tr -d '"')
    profile=$(grep CONFIG_BCM_KERNEL_PROFILE .config | cut -d'=' -f2 | tr -d '"')
    majver=$(grep CONFIG_TARGET_VERSION .config | cut -d'=' -f2 | tr -d '"' | cut -f1 -d .)
    minver=$(grep CONFIG_TARGET_VERSION .config | cut -d'=' -f2 | tr -d '"' | cut -f2 -d .)
    curdir="$PWD"


	# Execute user command
	while getopts "t:h" opt; do
		case $opt in
			t)
				stk_target=${OPTARG}
				;;
			h)
				print_usage
				exit 1
				;;
			\?)
				print_usage
				exit 1
				;;
		esac
	done

	if [ -z "$stk_target" ]; then
		print_usage
		exit 1
	fi

	if [ "$stk_target" == "broadcom" ]; then
		build_bcmkernel_consumer
		build_endptmngr_consumer
	else
		echo "Invalid target: $stk_target"
		print_usage
		exit 1
	fi

}

register_command "generate_tarballs" "Generate tarballs for Open SDK"

