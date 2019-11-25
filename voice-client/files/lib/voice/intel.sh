#! /bin/sh
# Voice library for Intel boards

getChipVendor() {
    echo intel
}

getChannelName() {
    echo TAPI
}

getLineName() {
    echo tapi
}

getSerial() {
    sernum="$(fw_printenv -n serial_number 2> /dev/null)"

    if [ $? ]; then
	echo $sernum
    else
	echo 0
    fi
}

getBaseMAC() {
    echo $(fw_printenv -n ethaddr)
}

getAllLines() {
    echo "TAPI/0&TAPI/1"
}

getLineIdx() {
    echo $1
}

getEchoCancellingValue() {
    case $1 in
	0)
	    echo 'off'
	    ;;
	1)
	    echo 'nlec'
	    ;;
	*)
	    # Unknown value
	    echo ''
	    ;;
    esac
}

supportedCountries() {
	echo "Austria:AUT:AT"
	echo "Denmark:DNK:DK"
	echo "Estonia:EST:EE"
	echo "Germany:DEU:DE"
	echo "Netherlands:NLD:NL"
	echo "Norway:NOR:NO"
	echo "Spain:ESP:ES"
	echo "Sweden:SWE:SE"
	echo "Switzerland:CHE:CH"
	echo "United Kingdom:GBR:UK"
}
