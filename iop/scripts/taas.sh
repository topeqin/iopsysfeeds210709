
# Shorthand command for doing a HIL runtime smoketest on the
# latest built image. Does the image boot up correctly?
# More info here:
# https://dev.iopsys.eu/iopsys/iopsys-taas


#--------------------------------------------------------------
function taas-init() {
	local f

	# Path to TaaS binarys. Try some likely ones.
	if ! which taas-smoketest >/dev/null; then
		PATH="${PATH}:${PWD}/../iopsys-taas/bin"
		PATH="${PATH}:${PWD}/../taas/bin"
		PATH="${PATH}:${HOME}/iopsys-taas/bin"
		PATH="${PATH}:${HOME}/taas/bin"
		PATH="${PATH}:${HOME}/bin"
		PATH="${PATH}:/opt/iopsys-taas/bin"
		PATH="${PATH}:/opt/taas/bin"
	fi

	if ! which taas-smoketest >/dev/null; then
		echo "Error; TaaS is missing! Install it with:"
		echo "git clone git@dev.iopsys.eu:iopsys/iopsys-taas.git ../iopsys-taas"
		exit 1
	fi

	# NAND erase block size.
	nandBlkSz=$(grep CONFIG_TARGET_NAND_BLOCKSZ .config | \
		tr -s "=\"" " " | cut -d " " -f 2)
	nandBlkSz=$((nandBlkSz / 1024))

	# Create a list of all images which might be of use.
	for f in ${PWD}/bin/targets/iopsys-*/generic/last.* \
			${PWD}/build_dir/target-arm*/bcmkernel/bcm963xx/targets/9*/bcm*_linux_raw_image_${nandBlkSz}.bin; do
		[[ -s "$f" ]] && images+=("$f")
	done

	# Convert Iopsys target name to the TaaS product name format
	# according to what is available in the remote lab for HIL.
	# Also find a suitable image.
	product=$(grep CONFIG_TARGET_PROFILE .config | \
		tr -s "=\"" " " | cut -d " " -f 2) || exit
	case "$product" in
		smarthub3)
			export product="SmartHub3a"
			;;
		dg400prime|eg400|ex600)
			export product=$(echo -n "$product" | tr [[:lower:]] [[:upper:]])
			;;
		*)
			echo "Unsupported target; skipping!"
			exit 0
			;;
	esac

	if [[ ${#images[@]} -eq 0 ]]; then
		echo "No image found"
		exit 1
	fi
}



#--------------------------------------------------------------
function taas-smoketest {
	declare -a images

	taas-init || return
	echo "Testing a $product with ${images[@]}..."
	command taas-smoketest "${images[@]}" "$product" "$@"
}



#--------------------------------------------------------------
function taas-bootstrap {
	declare -a images

	if [[ -n "$1" ]]; then
		taas-init || return
		echo "Flashing $1..."
		command taas-bootstrap "${images[@]}" "$@"
	else
		echo "Usage: ./iop taas-bootstrap dutX"
		exit 1
	fi
}



register_command "taas-bootstrap" "Write image to a remote lab device."
register_command "taas-smoketest" "Write image to a remote lab device and test it."

