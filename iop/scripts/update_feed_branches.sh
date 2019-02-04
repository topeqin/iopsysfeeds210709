#!/bin/sh

# Exported interface
function update_feed_branches {
	local release="$1"
	local ipath="$(pwd)"
	local branch="$2"
	local curbranch

	[ -n "$release" ] || {
		echo "Usage: ./update_feeds <RELEASE> <BRANCH>"
		echo ""
		echo "If you do not give a branch as argument,"
		echo "<RELEASE> branch will be updated to commit"
		echo "hash given in feeds.conf for each feed repo"
		exit 1
	}

	if [ -n "$branch" ]; then
		echo "Updating release branch $release to specific commit hash given in feeds.conf for each feed repo at branch $branch"
		if git diff-index --quiet HEAD; then
			curbranch=`git symbolic-ref HEAD 2>/dev/null`
			curbranch=${curbranch##refs/heads/}
			if [ -z $curbranch ]; then
				curbranch=`git log -1 --pretty=format:"%H"`
			fi
			git checkout $branch || {
				echo "couldn't checkout branch $branch"
				exit 99
			}
		else
			echo "You have unsaved changes."
			exit 99
		fi
	else
		echo "Updating release branch $release to specific commit hash given in feeds.conf for each feed repo"
	fi

	ifeeds="$(grep -r 'dev.iopsys.eu' feeds.conf | awk '{print$2}' | tr '\n' ' ')"

	for f in $ifeeds; do
		commith=$(grep $f feeds.conf | cut -d'^' -f2)
		cd $ipath/feeds/$f
		git branch -D $release 2>/dev/null
		echo "$f: updating release branch $release to commit $commith"
		git checkout $commith
		git push origin :$release
		git checkout -b $release
		git push origin $release
		cd $ipath
	done

	if [ -n "$branch" ]; then
		echo "Release branch $release is updated to specific commit hash given in feeds.conf in in branch $branch for each feed repo"
		git checkout $curbranch
	else
		echo "Release branch $release is updated to specific commit hash given in feeds.conf for each feed repo"
	fi
}

register_command "update_feed_branches" "<release> [branch] Update branches in feeds from the current top level commit or specified top level branch"
