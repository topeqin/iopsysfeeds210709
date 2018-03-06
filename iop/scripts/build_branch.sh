#!/bin/sh
# build_branch
#./iop build_branch <branch> <board> [<customer>]

function build_branch_usage {
	echo "usage: $0 build_branch <branch> <board> [<customer>]"
	echo "example: $0 build_branch devel-new ex400 DEV"
	echo "example: $0 build_branch_sysupgrade devel-new ex400 DEV 192.168.1.1 -n"
	exit 1
}

function branch_exists {
	local branch=$1
	[ -z "$branch" ] && return 1
	git branch | grep -q $branch && return 0
	return 1
}

function build_branch {
	local branch=$1
	local board=$2
	local customer=$3
	[ "$customer" == "INT" ] && customer=""

	if ! branch_exists $branch ; then
		echo "Branch $branch not found"
		build_branch_usage
	fi

time {
	git fetch origin || build_branch_usage
	git fetch --all -p || build_branch_usage
	git checkout $branch || build_branch_usage
	git pull || exit 1
	./iop feeds_update || build_branch_usage
	./iop genconfig -c $board $customer || build_branch_usage
	make -j 8 || build_branch_usage
}
}

function build_branch_sysupgrade {
	set -x
	local branch=$1 ; shift
	local board=$1 ; shift
	local customer=$1 ; shift
	local ip=$1 ; shift
	local opts=$*

time {
	./iop build_branch $branch $board $customer
	./iop ssh_sysupgrade_latest $ip $opts
}
	set +x
}

register_command "build_branch" "<branch> <board> [<customer>]  Build a <branch> for a <board> [with a <customer> profile]"
register_command "build_branch_sysupgrade" "<branch> <board> <customer>|INT <ip> [<opts>]  Build a <branch> for a <board> [with a <customer> profile] and sysupgrade [with <opts>] it on the router at <ip>"
