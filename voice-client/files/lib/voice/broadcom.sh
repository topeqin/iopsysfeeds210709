#! /bin/sh
# Voice library for Broadcom boards

getChipVendor() {
    echo brcm
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
    echo $(cat /proc/nvram/BaseMacAddr | sed 's/ //g')
}

getAllLines() {
    echo "BRCM/0&BRCM/1&BRCM/2&BRCM/3&BRCM/4&BRCM/5"
}

getLineIdx() {
    echo $1
}

getEchoCancellingValue() {
    case $1 in
	0)
	    echo '0'
	    ;;
	1)
	    echo '1'
	    ;;
	*)
	    # Unknown value
	    echo ''
	    ;;
    esac
}

supportedCountries() {
	echo "Australia:AUS"
	echo "Belgium:BEL"
	echo "Brazil:BRA"
	echo "Chile:CHL"
	echo "China:CHN"
	echo "Czech:CZE"
	echo "Denmark:DNK"
	echo "ETSI:ETS"
	echo "Finland:FIN"
	echo "France:FRA"
	echo "Germany:DEU"
	echo "Hungary:HUN"
	echo "India:IND"
	echo "Italy:ITA"
	echo "Japan:JPN"
	echo "Netherlands:NLD"
	echo "New Zealand:NZL"
	echo "North America:USA"
	echo "Spain:ESP"
	echo "Sweden:SWE"
	echo "Switzerland:CHE"
	echo "Norway:NOR"
	echo "Taiwan:TWN"
	echo "United Kingdoms:GRB"
	echo "United Arab Emirates:ARE"
	echo "CFG TR57:T57"
}
