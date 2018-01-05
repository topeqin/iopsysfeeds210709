#!/bin/bash

function extract_top {
	tmp_dir=extract_top_tmp

	# Paths to packages that should be ignored.
	paths+='package/network/services/samba36 '
	paths+='package/network/services/dnsmasq '
	paths+='package/network/services/dropbear '
	paths+='package/network/services/odhcpd '
	paths+='package/network/config/firewall '
	paths+='package/network/config/netifd '
	paths+='package/network/config/qos-scripts '
	paths+='package/network/utils/iproute2 '
	paths+='package/network/utils/curl '
	paths+='package/utils/busybox '
	paths+='package/base-files '

	function extract {

		current_branch=$(git rev-parse --abbrev-ref HEAD)
		git format-patch $start_commit -o $tmp_dir #> /dev/null

		ls $tmp_dir |
			while read file; do
				# Remove feed patches.
				#			echo $file | grep -i Update-feed > /dev/null && \
				#				rm $tmp_dir/$file && continue
				cat $tmp_dir/$file | grep "+++ b/feeds.conf" > /dev/null && \
					rm $tmp_dir/$file && continue
				
				# Remove core patches.
				for path in $paths; do
					cat $tmp_dir/$file | grep $path > /dev/null && \
						rm $tmp_dir/$file && break
				done
			done

		git checkout -b ${current_branch}-new $start_commit
		git am $tmp_dir/*
		git checkout $current_branch
		rm -rf $tmp_dir
	}
	
	function print_usage {

		echo "Usage:"
		echo "  $0 -s <start_commit>"
	}

	# Execute user command
	while getopts "s:" opt; do
		case $opt in
			s)
				start_commit=${OPTARG}
				;;
			\?)
				print_usage
				exit 1
				;;
		esac
	done

	if [ ! -n "$start_commit" ]; then
   		print_usage
		exit 1
	fi

	extract

}

register_command "extract_top" "Extract commits made to top repo"
