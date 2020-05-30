#!/bin/bash


build_bcmkernel_consumer() {
	local tarfile bcmkernelcommith sdkversion
	sdkversion=$(grep "CONFIG_BRCM_SDK_VER.*=y" .config | awk -F'[_,=]' '{print$5}')
	sdkversion=${sdkversion:0:4}${sdkversion:(-1)}
	bcmkernelcommith=$(grep -w "PKG_SOURCE_VERSION:" $curdir/feeds/broadcom/bcmkernel/${sdkversion:0:5}*.mk | cut -d'=' -f2)
	# do not build bcmopen sdk if it was already built before
	[ -n "$board" -a -n "$bcmkernelcommith" ] || return
	ssh $SERVER "test -f $FPATH/bcmopen-$board-$bcmkernelcommith.tar.gz" && return
	cd ./build_dir/target-*/bcmkernel-*-${sdkversion:0:4}*/bcm963xx/release
	bash do_consumer_release -p $profile -y -F
	tarfile='out/bcm963xx_*_consumer.tar.gz'
	[ $(ls -1 $tarfile |wc -l) -ne 1 ] && echo "Too many tar files: '$tarfile'" && return
	scp -pv $tarfile $SERVER:$FPATH/bcmopen-$board-$bcmkernelcommith.tar.gz
	ssh $SERVER "[ -f $FPATH/bcmopen-$board-$bcmkernelcommith.tar.gz ] && ln -sf $FPATH/bcmopen-$board-$bcmkernelcommith.tar.gz $FPATH/bcmopen-$board-$majver.$minver-latest"
	rm -f $tarfile
	cd "$curdir"
}

build_natalie_consumer() {
	# create natalie-dect open version tar file
	local natalieversion nataliecommith
	grep -q "CONFIG_TARGET_NO_DECT=y" .config && return
	natalieversion=$(grep -w "PKG_VERSION:" ./feeds/iopsys/natalie-dect/Makefile | cut -d'=' -f2)
	nataliecommith=$(grep -w "PKG_SOURCE_VERSION:" ./feeds/iopsys/natalie-dect/Makefile | cut -d'=' -f2)
	[ -n "$profile" -a -n "$natalieversion" -a -n "$nataliecommith" ] || return
	ssh $SERVER "test -f $FPATH/natalie-dect-$profile-$natalieversion-$nataliecommith.tar.gz" && return
	cd ./build_dir/target-*/natalie-dect-$natalieversion/
	mkdir natalie-dect-open-$natalieversion
	cp -f ipkg-*/natalie-dect/lib/modules/*/extra/dect.ko natalie-dect-open-$natalieversion/dect.ko
	tar -czv  natalie-dect-open-$natalieversion/ -f natalie-dect-$profile-$natalieversion-$nataliecommith.tar.gz
	scp -pv natalie-dect-$profile-$natalieversion-$nataliecommith.tar.gz $SERVER:$FPATH/
	cp natalie-dect-$profile-$natalieversion-$nataliecommith.tar.gz $curdir/
	rm -rf natalie-dect-open-$natalieversion
	rm -f natalie-dect-$profile-$natalieversion-$nataliecommith.tar.gz
	cd "$curdir"
}

build_endptmngr_consumer() {
	# create endptmngr open version tar file
	local endptversion endptcommith
	grep -q "CONFIG_TARGET_NO_VOICE=y" .config && return
	endptversion=$(grep -w "PKG_VERSION:" ./feeds/iopsys/endptmngr/Makefile | cut -d'=' -f2)
	endptcommith=$(grep -w "PKG_SOURCE_VERSION:" ./feeds/iopsys/endptmngr/Makefile | cut -d'=' -f2)
	[ -n "$profile" -a -n "$endptversion" -a -n "$endptcommith" ] || return
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

build_mediatek_kernel() {
	local mediatek_commit kernel

	mediatek_commit=$(grep CONFIG_KERNEL_GIT_COMMIT .config | cut -d '=' -f2 | tr -d '"')
	kernel=linux-git*
	[ -n "$mediatek_commit" ] || return
	ssh $SERVER "test -f $FPATH/mediatek-kernel-open-$mediatek_commit.tar.gz" && return
	echo "Building mediatek kernel tarball from kernel commit:"	
	echo $mediatek_commit
	cd build_dir/target-mipsel_1004kc*/linux-iopsys-ramips*/linux-git*

	# remove git repo
	rm -rf .git
	cd ..

	tar -czv $kernel -f mediatek-kernel-open-$mediatek_commit.tar.gz
	scp -pv mediatek-kernel-open-$mediatek_commit.tar.gz $SERVER:$FPATH/
	cd "$curdir"
}

build_mediatek_wifi_consumer() {
	local ver commit
	local chip=$1

	ver=$(grep -w "PKG_VERSION:" ./feeds/mediatek/mt${chip}/Makefile | cut -d'=' -f2)
	commit=$(grep -w "PKG_SOURCE_VERSION:" ./feeds/mediatek/mt${chip}/Makefile | cut -d'=' -f2)
	[ -n "$ver" -a -n "$commit" ] || return
	ssh $SERVER "test -f $FPATH/mtk${chip}e-${ver}_${commit}.tar.xz" && return
	cd build_dir/target-mipsel_1004kc*/linux-iopsys-ramips*/mtk${chip}e-$ver/ipkg-*
	mkdir -p mtk${chip}e-$ver/src
	cp -rf kmod-mtk${chip}e/etc mtk${chip}e-$ver/src/
	cp -rf kmod-mtk${chip}e/lib mtk${chip}e-$ver/src/
	tar Jcf mtk${chip}e-${ver}_${commit}.tar.xz mtk${chip}e-$ver
	scp -pv mtk${chip}e-${ver}_${commit}.tar.xz $SERVER:$FPATH/
	cp mtk${chip}e-${ver}_${commit}.tar.xz $curdir/
	rm -rf mtk${chip}e-$ver
	rm -f mtk${chip}e-${ver}_${commit}.tar.xz
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

    target=$(grep CONFIG_TARGET_BOARD .config | cut -d'=' -f2 | tr -d '"')
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

	if [ ! -n "$stk_target" ]; then
		print_usage
		exit 1
	fi

	if [ "$stk_target" == "broadcom" ]; then
		build_bcmkernel_consumer
		build_natalie_consumer
		build_endptmngr_consumer
	elif [ "$stk_target" == "mediatek" ]; then
		build_mediatek_kernel
		build_mediatek_wifi_consumer 7603
		build_mediatek_wifi_consumer 7615
	else
		echo "Invalid target: $stk_target"
		print_usage
		exit 1
	fi

}

register_command "generate_tarballs" "Generate tarballs for Open SDK"

