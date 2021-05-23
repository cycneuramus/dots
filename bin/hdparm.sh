#!/bin/bash

. functions.sh

if (( $EUID != 0 )); then
    echo "Needs to be run as root"
    exit
fi

trap 'push "$(basename $0) stötte på fel"' err

# if (( $(hdparm -I /dev/disk/by-uuid/63c7ab15-be2c-44a5-a515-8d2889e5071f | grep "Advanced power management level:" | grep -Eo '[0-9]*') != 120 )); then
#     hdparm -B 120 -S 120 /dev/disk/by-uuid/63c7ab15-be2c-44a5-a515-8d2889e5071f
#     push "Standbyintervall för liten extern HD har justerats"
# fi

if (( $(hdparm -I /dev/disk/by-uuid/64073cce-9b55-4231-af58-cf0b0206ecc2 | grep "Advanced power management level:" | grep -Eo '[0-9]*') != 120 )); then
    hdparm -B 120 -S 120 /dev/disk/by-uuid/64073cce-9b55-4231-af58-cf0b0206ecc2
    push "Standbyintervall för extern HD har justerats"
fi
