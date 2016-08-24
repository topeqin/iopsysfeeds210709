#! /bin/bash

function feeds_update {

    developer=0
    override=1

    while getopts "n" opt; do
	case $opt in
	    n)
		override=0
		;;
	esac
    done


    git remote -v | grep -q http || developer=1

    cp .config .genconfig_config_bak

    rm -rf package/feeds

    #if -d argument is passed, clone feeds with ssh instead of http
    if [ $developer == 1 ]; then
	./scripts/feeds update -g
    else
	./scripts/feeds update
    fi
    
    if [ $override == 1 ]; then
	./scripts/feeds install -f -p feed_inteno_openwrt -a
    fi
    ./scripts/feeds install -f -p feed_inteno_juci -a
    ./scripts/feeds install -f -p feed_inteno_packages -a
    ./scripts/feeds install -f -p feed_inteno_broadcom -a
    ./scripts/feeds install -f -p feed_inteno_targets iopsys-brcm63xx-mips
    ./scripts/feeds install -f -p feed_inteno_targets iopsys-brcm63xx-arm
    ./scripts/feeds install -f -p feed_inteno_targets iopsys-ramips
    ./scripts/feeds install -a 
    ./scripts/feeds uninstall asterisk18
    ./scripts/feeds uninstall qrencode
    ./scripts/feeds install -f -p feed_inteno_packages qrencode
    ./scripts/feeds uninstall libwebsockets
    ./scripts/feeds install -f -p feed_inteno_juci libwebsockets

    cp .genconfig_config_bak .config
    make defconfig

    # record when we last run this script
    touch tmp/.iop_bootstrap 

    # always return true
    exit 0
}

register_command "feeds_update" "Update feeds to point to commit hashes from feeds.conf"




