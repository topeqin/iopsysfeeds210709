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
    
    # replace core packages with iopsys versions
    if [ $override == 1 ]; then
	./scripts/feeds install -f -p feed_inteno_openwrt -a
    fi

    # install our feeds first to enable replacing a package in another feed
    ./scripts/feeds install -p feed_inteno_juci -a
    ./scripts/feeds install -p feed_inteno_packages -a
    ./scripts/feeds install -p feed_inteno_broadcom -a

    # targets need to be installed explicitly
    ./scripts/feeds install -p feed_inteno_targets iopsys-brcm63xx-mips
    ./scripts/feeds install -p feed_inteno_targets iopsys-brcm63xx-arm
    ./scripts/feeds install -p feed_inteno_targets iopsys-ramips
    
    # install all packages
    ./scripts/feeds install -a 
    ./scripts/feeds uninstall asterisk18

    cp .genconfig_config_bak .config
    make defconfig

    # record when we last run this script
    touch tmp/.iop_bootstrap 

    # always return true
    exit 0
}

register_command "feeds_update" "Update feeds to point to commit hashes from feeds.conf"




