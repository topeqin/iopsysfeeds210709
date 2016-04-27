# this is a developer helper script to SCP changed files to remote host

ROOT=build_dir/target-mips_uClibc-0.9.33.2/root-iopsys-brcm63xx-mips/
ROOT_OLD=tmp/root_old/
ROOT_TMP=tmp/root_tmp/

function scp_changes_reset {
	{ cd `dirname $0`
		rm -rf "$ROOT_OLD"
		mkdir -p "$ROOT_OLD"
		cp -a "$ROOT"* "$ROOT_OLD"
	}
}

function scp_changes {
	if [ -z "$1" ] ; then
		echo "usage: $0 scp_changes <host/-r(eset)/-p(retend)>"
		echo "Error: host required"
		exit 1
	fi
	{ cd `dirname $0`
		if [ ! -d $ROOT ]; then
			echo "$ROOT does not exist"
			echo "please build the project first"
			exit 1;
		fi
		if [ "$1" = "-r" ]; then
			echo "reset changes"
			scp_changes_reset
			exit 0
		fi
		if [ ! -d $ROOT_OLD ]; then
			echo "$ROOT_OLD does not exist"
			echo "you didn't store state of previous buildroot"
			#echo "please run ./scp_changes_reset.sh"
			echo "doing it now"
			scp_changes_reset
			exit 1;
		fi
		FILES=`diff -rq "$ROOT" "$ROOT_OLD" 2>&1 | sed -ne "s?^Files .* and $ROOT_OLD\\(.*\\) differ?\\1?p" -ne "s?^Only in $ROOT\\(.*\\): \\(.*\\)?\\1/\\2?p"`
		if [ "$1" = "-p" ]; then
			echo "files that would be copied:"
			echo $FILES
			exit 0
		fi
		for f in $FILES
		do
			mkdir -p "$ROOT_TMP`dirname $f`"
			cp -af "$ROOT$f" "$ROOT_TMP$f"
		done
		if [ -d "$ROOT_TMP" ]; then
			echo "scp changed files to $1"
			pushd "$ROOT_TMP" 2>&1 >/dev/null
			scp -r * root@$1:/
			RETVAL=$?
			popd 2>&1 >/dev/null
			rm -rf "$ROOT_TMP"
			if [ "$RETVAL" -eq 0 ]; then
				scp_changes_reset
			else
				echo "scp error"
				exit $RETVAL
			fi
		else
			echo "no change"
		fi
	}
}

register_command "scp_changes" "<host/-r(eset)/-p(retend)>  SCP only changed files to device"
