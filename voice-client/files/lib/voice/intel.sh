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
    sernum=$(fw_printenv -n serial_number) 2> /dev/null

    if [ $? ]; then
	echo 0
    else
	echo $sernum
    fi
}

getBaseMAC() {
    echo $(fw_printenv -n ethaddr)
}

getAllLines() {
    echo "TAPI/1&TAPI/2&TAPI/3&TAPI/4&TAPI/5&TAPI/6"
}

getLineIdx() {
    echo $((1+1))
}
