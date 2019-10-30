#!/bin/sh
function license_report {
    LICDIR="/tmp/licenses-generator/"
    LICBIN="${LICDIR}/bin"


    dpkg -s python3 python3-requests python3-yaml python3-mako python3-six &> /dev/null
    if [ $? -ne 0 ]
        then
            echo "Missing dependencies"
            sudo apt-get update
            sudo apt-get install python3 python3-requests python3-yaml python3-mako python3-six

        else
            echo    "Dependecy check passed"
    fi


if [ -d "$LICDIR" ]; then
  ### Take action if $DIR exists ###
  echo "Creating json licences file and html formated report"
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Error: licenses-generator not found. getting from iopsys repo"
  git clone git@dev.iopsys.eu:iopsys/licenses-generator.git $LICDIR
fi
  LICGET=`${LICBIN}/licenses-generator  gen-License bin/`
  echo $LICGET
  ${LICBIN}/licenses-generator gen-licrprt $LICGET
exit 0

}


register_command "license_report" "Generate a Licence report on latest build in json format and html under reports"
