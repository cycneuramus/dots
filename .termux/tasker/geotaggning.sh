#!/data/data/com.termux/files/usr/bin/bash

. $HOME/bin/secrets

set -x
exec 1>$HOME/log/geotaggning.log 2>&1

termux-wake-lock
trap 'termux-wake-unlock' err exit

img=${1/\/storage\/emulated\/0\//storage\/shared/}
ssid_home="$ssid_home"
loc_home="$loc_home_json"

if [[ $1 == *exiftool* || $(find $img -mmin +1) ]]; then
	exit
fi

if [[ $1 == *pending* ]]; then
	until [[ ! $(find ~/storage/shared/DCIM/Camera -newermt "1 minutes ago" -iname "*pending*") ]]; do
		sleep 5
	done
fi

if [[ ! $(find storage/shared/DCIM/Camera -newermt '2 minutes ago' -type f -iname '*.jp*' -a -not -iname '*pending*') ]]; then
	exit
fi

if [[ $(termux-wifi-connectioninfo | jq '.ssid') == *$ssid_home* ]]; then
	loc=$loc_home 
	sleep 5
else
	loc=$(termux-location -p gps -r once)
fi

if [[ $(echo $loc | grep latitude) ]]; then
 	lat=$(echo $loc | jq '.latitude')
 	lon=$(echo $loc | jq '.longitude')
else
 	echo "Kunde inte fastställa plats, avbryter..."
	termux-notification -c "Kunde inte fastställa plats" --icon location_off
 	termux-wake-unlock
	exit
fi

targets="$(find storage/shared/DCIM/Camera -newermt '2 minutes ago' -type f -iname '*.jp*' -a -not -iname '*pending*')"

exiftool -GPSLatitude=$lat -GPSLatitudeRef=$lat -GPSLongitude=$lon -GPSLongitudeRef=$lon -overwrite_original $targets
