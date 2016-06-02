#!/bin/bash

# Intermediate repo for core packages
core_repo=git@public.inteno.se:iopsys-cc-core.git

# Repo to which core packages should be imported
import_repo=git@public.inteno.se:feed-inteno-openwrt.git
import_branch=openwrt-cc-core


function export_core {

    local path=$1

    # export paths to their own branches in an intermediate repo
    repo=$(basename $path)
    git subtree push -q --prefix=$path $core_repo $repo
}


function update_core {
    
    local path=$1
    
    if [ ! -d $topdir/feeds/feed_inteno_openwrt ]; then
	echo "You need to run ./iop feeds_update"
	exit -1
    fi

    # ensure that we are synced with the remote
    cd $topdir/feeds/feed_inteno_openwrt
    git checkout $import_branch
    git pull

    # first install subtrees if they don't already exist
    repo=$(basename $path)
    git subtree add --prefix=$repo $core_repo $repo
    
    # install subtrees in feed from intermediate repo
    repo=$(basename $path)
    echo "Exporting $repo"
    git subtree pull -q -m "Exporting $repo" --prefix=$repo $core_repo $repo

    # update import repo sync branch
    git push origin $import_branch
}

function display_help {
    
    echo "Usage: ./iop export_core -e path/to/package"
}

function extract_core {

# Dir of script location
topdir=$(pwd)


if [ $# -eq 0 ]; then
    display_help
    exit -1
fi

# Execute user command
while getopts "he:" opt; do
    case $opt in
	e)
	    path=${OPTARG}
	    echo "Extracting ${path} from core to ${import_repo}:${import_branch}"
	    export_core $path
	    update_core $path
	    ;;
	h)
	    display_help
	    exit 0
	    ;;
	\?)
	    display_help
	    exit -1
	    ;;
	esac
done

}

register_command "extract_core" "Extract core package to feeds_inteno_openwrt"


