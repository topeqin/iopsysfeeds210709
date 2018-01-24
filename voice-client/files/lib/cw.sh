#! /bin/sh

if [ $2 != '?' ]; then
    for brcm in `uci show voice_client | grep brcm | grep $1 | cut -d . -f 2`; do
	sed -i "/\[$brcm\]/,/^\[/ s/\(callwaiting=\)[0-9]/\1$2/" /etc/asterisk/brcm.conf
    done
else
    for brcm in `uci show voice_client | grep brcm | grep $1 | cut -d . -f 2`; do
	status=`sed -n "/\[$brcm\]/,/^\[/ s/callwaiting=\([0-9]\)/\1/p" /etc/asterisk/brcm.conf`
	echo $status
	exit 0
    done
fi
