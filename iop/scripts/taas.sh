
# Shorthand command for doing a HIL runtime smoketest on the
# latest built image. Does the image boot up correctly?
# More info here:
# https://dev.iopsys.eu/iopsys/iopsys-taas


#--------------------------------------------------------------
function taas-init() {
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
}



#--------------------------------------------------------------
function taas-smoketest {
	local image app

	taas-init || return

	# Find the default latest image (.y3 or FIT).
	for image in bin/targets/iopsys-*/generic/last.y3 \
			bin/targets/iopsys-*/generic/last.pkgtb; do
		[ -s "$image" ] || continue

		# Convert Iopsys target name to the TaaS product name format.
		product=$(grep CONFIG_TARGET_PROFILE .config | \
			tr -s "=\"" " " | cut -d " " -f 2)
		case "$product" in
			smarthub3)
				product="SmartHub3a"
				;;
			dg400prime|eg400)
				product=$(echo -n "$product" | tr [[:lower:]] [[:upper:]])
				;;
			*)
				product=""
				;;
		esac

		if [ -n "$product" ]; then
			command taas-smoketest "$image" "$product" || exit
			echo "Smoketest OK"
		else
			echo "Unsupported target; skipping smoketest."
		fi

		exit 0
	done

	echo "No image found"
	exit 1
}

register_command "taas-smoketest" "Write image to a device in the lab and check if it boots up."

