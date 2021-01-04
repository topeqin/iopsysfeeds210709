#!/bin/sh

SOUND_BASE=/lib/modules/$(uname -r)/kernel/sound
SOUND_MODULES="$SOUND_BASE/soundcore.ko $SOUND_BASE/core/snd.ko $SOUND_BASE/core/snd-timer.ko"
SOUND_MODULES="$SOUND_MODULES $SOUND_BASE/core/snd-pcm.ko $SOUND_BASE/core/snd-hwdep.ko"
SOUND_MODULES="$SOUND_MODULES $SOUND_BASE/core/seq/snd-seq-device.ko"
SOUND_MODULES="$SOUND_MODULES $SOUND_BASE/core/seq/snd-seq.ko $SOUND_BASE/core/snd-rawmidi.ko "
SOUND_MODULES="$SOUND_MODULES $SOUND_BASE/usb/snd-usbmidi-lib.ko $SOUND_BASE/usb/snd-usb-audio.ko"

load_sound_modules() {
	for mod in $SOUND_MODULES; do
		insmod $mod
	done
}

unload_sound_modules() {
	local modules=

	# reverse the order
	for mod in $SOUND_MODULES; do
		modules="$mod $modules"
	done

	for mod in $modules; do
		rmmod $mod
	done
}
