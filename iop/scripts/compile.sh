#!/bin/sh

function compile {
	local cpath pck
	local lpath=$(find package/ -type l -name $1)
	local dpath=$(find package/ -type d -name $1)

	for pck in $lpath $dpath; do
		if [ -n "$(ls $pck/Makefile 2>/dev/null)" ]; then
			cpath=$pck
			break
		fi
	done

	if [ -n "$cpath" ]; then
		make $cpath/compile V=$2
	else
		echo "Package $1 does not exist. Make sure you have installed the necessary feed."
	fi
}

register_command "compile" "Compile a specific package: ./iop compile <PACKAGE_NAME> [0-99]; i.e ./iop netifd 99"
