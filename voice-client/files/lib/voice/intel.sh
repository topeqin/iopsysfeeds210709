#! /bin/sh

getChipVendor() {
    echo intel
}

getChannelName() {
    echo TAPI
}

getLineName() {
    echo intel
}

getSerial() {
    sernum=$(fw_printenv -n serial_number)

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

sed -i \
    -e 's/brcm/lantiq/g' \
    -e 's/BRCM/TAPI/g' \
    -e 's/broadcom/lantiq/g' \
    /etc/config/voice_client
