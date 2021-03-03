#!/bin/bash

. funktioner.sh

if (( $EUID != 0 )); then
    echo "Var vänlig kör som root"
    exit
fi

# if (( $(hdparm -I /dev/disk/by-uuid/63c7ab15-be2c-44a5-a515-8d2889e5071f | grep "Advanced power management level:" | grep -Eo '[0-9]*') != 120 )); then
#     hdparm -B 120 -S 120 /dev/disk/by-uuid/63c7ab15-be2c-44a5-a515-8d2889e5071f
#     push "Standbyintervall för liten extern HD har justerats"
# fi

if (( $(hdparm -I /dev/disk/by-uuid/64073cce-9b55-4231-af58-cf0b0206ecc2 | grep "Advanced power management level:" | grep -Eo '[0-9]*') != 120 )); then
    hdparm -B 120 -S 120 /dev/disk/by-uuid/64073cce-9b55-4231-af58-cf0b0206ecc2
    push "Standbyintervall för extern HD har justerats"
fi
