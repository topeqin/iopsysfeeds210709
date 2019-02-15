#! /bin/bash

function feeds_update {

    developer=0
    override=1
    start=$(date -u +'%s');
    while getopts "n" opt; do
	case $opt in
	    n)
		override=0
		;;
	esac
    done


    git remote -v | grep -q http || developer=1

    cp .config .genconfig_config_bak

    #if -d argument is passed, clone feeds with ssh instead of http
    if [ $developer == 1 ]; then
	./scripts/feeds update -g
    else
	./scripts/feeds update
    fi
	./scripts/feeds update -ai

    # replace core packages with iopsys versions
    if [ $override == 1 ]; then
		./scripts/feeds install -f -p lede_core -a
    fi

    # targets need to be installed explicitly
    targets="iopsys-brcm63xx-mips iopsys-brcm63xx-arm iopsys-ramips intel_mips"
    for target in $targets
    do
	rm target/linux/$target
	./scripts/feeds install targets $target
    done

    # install all packages
    ./scripts/feeds install -a 

    # remove broken symlinks ( for packages that are no longer in the feed )
    find -L package/feeds -maxdepth 2 -type l -delete

    cp .genconfig_config_bak .config
    make defconfig

    # record when we last run this script
    touch tmp/.iop_bootstrap 

    # always return true
    exit 0
}

register_command "feeds_update" "Update feeds to point to commit hashes from feeds.conf"




