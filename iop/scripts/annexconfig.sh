#!/bin/bash

function disable_add_config () {
	local COPTION="$1"

	HAVE_OPTION=`grep $COPTION .config | wc -l`
	HAVE_OPTION_DISABLED=`grep "# $COPTION" .config | wc -l`
	if [ "$HAVE_OPTION" = "1" ]
	then
		if [ "$HAVE_OPTION_DISABLED" = "0" ]
		then
			sed -i -e "s,$COPTION=y,# $COPTION is not set,g" .config
		fi
	else
		echo "# $COPTION is not set" >> .config
	fi
}

function enable_option () {
	local COPTION="$1"
#	cat .config| grep DSL
	sed -i -e "s,# $COPTION is not set,$COPTION=y,g" .config
#	cat .config| grep DSL
}

function annexconfig {

	v() {
		[ "$VERBOSE" -ge 1 ] && echo "$@"
	}

	local ANNEX="$1"

	disable_add_config CONFIG_TARGET_NO_DSL
	disable_add_config CONFIG_TARGET_DSL_ANNEX_A
	disable_add_config CONFIG_TARGET_DSL_ANNEX_B
	disable_add_config CONFIG_TARGET_DSL_ANNEX_C
	disable_add_config CONFIG_TARGET_DSL_SADSL
	disable_add_config CONFIG_TARGET_DSL_GFAST


	if [ "$ANNEX" = "no" ]
	then
		echo "No DSL"
		enable_option CONFIG_TARGET_NO_DSL
	elif [ "$ANNEX" = "a" ]
	then
		echo "Annex A"
		enable_option CONFIG_TARGET_DSL_ANNEX_A
	elif [ "$ANNEX" = "b" ]
	then
		echo "Annex B"
		enable_option CONFIG_TARGET_DSL_ANNEX_B
	elif [ "$ANNEX" = "c" ]
	then
		echo "Annex C"
		enable_option CONFIG_TARGET_DSL_ANNEX_C
	elif [ "$ANNEX" = "sadsl" ]
	then
		echo "sadsl"
		enable_option CONFIG_TARGET_DSL_SADSL
	elif [ "$ANNEX" = "gfast" ]
	then
		echo "G.fast"
		enable_option CONFIG_TARGET_DSL_GFAST
	else
		echo "Only option no,a,b,c,sadsl,gfast supported"
	fi

}

register_command "annexconfig" "Select configuration annex"
