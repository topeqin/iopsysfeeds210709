#!/bin/bash

function status {
    topdir=$PWD
    echo
    for subdir in .git $(find feeds/ -type d -name .git); do

	echo "======= $(dirname $subdir) ========"
	cd $subdir/..
	if git status |grep -Eq '^\s([^\s\(]+)'; then
	    git status |grep -Ev '(nothing added|use "git |^$)'
	else
	    git status |grep -E "(On branch|HEAD detached)"
	fi
	cd $topdir
    done
    echo
}

register_command "status" "Display the state of your working tree"
