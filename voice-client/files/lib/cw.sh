#! /bin/sh

. /lib/voice/voicelib.sh

if [ $2 != '?' ]; then
    for tel_line in `uci show voice_client | grep $(getLineName) | grep $1 | cut -d . -f 2`; do
	sed -i "/\[$tel_line\]/,/^\[/ s/\(callwaiting=\)[0-9]/\1$2/" /etc/asterisk/$(getLineName).conf
    done
else
    for tel_line in `uci show voice_client | grep $(getLineName) | grep $1 | cut -d . -f 2`; do
	status=`sed -n "/\[$tel_line\]/,/^\[/ s/callwaiting=\([0-9]\)/\1/p" /etc/asterisk/$(getLineName).conf`
	echo $status
	exit 0
    done
fi
