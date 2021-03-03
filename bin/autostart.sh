#!/bin/bash

if (( $EUID != 0 )); then
    echo "Var vänlig kör som root"
    exit
fi

. funktioner.sh

echo 0 > /sys/class/backlight/intel_backlight/brightness

# För att stänga av skärmen; slutade fungera i och med 20.04, så jag låter helt enkelt datorlocket vara stängt vilket tycks uppgå i samma sak
# vbetool dpms off

until mountpoint -q /mnt/extern; do
    sleep 5
    count=$((count + 1))
    if (( $count > 5 )); then
        echo "timed out"
        push "hdparm kunde inte ange standbyintervall för extern hårddisk"
        exit
    fi
done

hdparm -B 120 -S 120 /dev/disk/by-uuid/64073cce-9b55-4231-af58-cf0b0206ecc2
