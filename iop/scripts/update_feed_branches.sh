#!/bin/sh

# Exported interface
function update_feed_branches {
	release="$1"
	ipath="$(pwd)"
	branch="$2"

	[ -n "$release" ] || {
		echo "Usage: ./update_feeds <RELEASE> <BRANCH>"
		echo ""
		echo "If you do not give a branch as argument,"
		echo "<RELEASE> branch will be updated to commit"
		echo "hash given in feeds.conf for each feed repo"
		exit 1
	}

	if [ -n "$branch" ]; then
		echo "Updating release branch $release to branch $branch in all feeds repos."
	else
		echo "Updating release branch $release to specific commit hash given in feeds.conf for each feed repo"
	fi

	ifeeds="$(grep -r feed_inteno feeds.conf  | awk '{print$2}' | cut -d'_' -f3 | tr '\n' ' ')"

	for f in $ifeeds; do
		commith=$(grep feed_inteno_$f feeds.conf | cut -d'^' -f2)
		cd $ipath/feeds/feed_inteno_$f
		git br -D $release 2>/dev/null
		if [ -n "$branch" ]; then
			echo "feed_inteno_$f: updating release branch $release to branch $branch"
			git co $branch
		else
			echo "feed_inteno_$f: updating release branch $release to commit $commith"
			git co $commith
		fi
		git push origin :$release
		git co -b $release
		git push origin $release
		[ -n "$branch" ] && git co $branch
		cd $ipath
	done

	if [ -n "$branch" ]; then
		echo "Release branch $release is updated to branch $branch in all feeds repos."
	else
		echo "Release branch $release is updated to specific commit hash given in feeds.conf for each feed repo"
	fi
}

register_command "update_feed_branches" "Update branches in feeds from the current top level commit"
