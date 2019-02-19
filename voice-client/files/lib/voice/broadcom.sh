#! /bin/sh
# Voice library for Broadcom boards

getChipVendor() {
    echo broadcom
}

getChannelName() {
    echo BRCM
}

getLineName() {
    echo brcm
}

getSerial() {
    echo $(cat /proc/nvram/SerialNumber)
}

getBaseMAC() {
    echo =$(cat /proc/nvram/BaseMacAddr | sed 's/ //g')
}

getAllLines() {
    echo "BRCM/0&BRCM/1&BRCM/2&BRCM/3&BRCM/4&BRCM/5&BRCM/6"
}

getLineIdx() {
    echo $1
}
