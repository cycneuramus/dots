#!/data/data/com.termux/files/usr/bin/bash
. $HOME/bin/secrets

termux-wake-lock
trap 'termux-wake-unlock' err exit

if [[ "$1" == *amihome* ]]; then

	wifi_info=$(termux-wifi-connectioninfo)

	if [[ $(echo wifi_info | grep DISCONNECTED) ]]; then
		wifi_on=0
	else
		wifi_on=1
	fi

	if [[ $(echo $wifi_info | grep $ssid_home) ]]; then
		home=1
	else
		home=0
	fi

	if [[ $home = 1 ]]; then
		curl -H "Content-Type: application/json" -X POST -d '{"service": "device_tracker.see", "dev_id": "tasker_anton", "location_name": "home"}' http://192.168.1.94:8123/api/webhook/anton_homeaway
	else
		if [[ $wifi_on = 0 ]]; then
			termux-wifi-enable true
			sleep 15
		fi

		if [[ $home = 0 && $wifi_on = 0 ]]; then
			termux-wifi-enable false
		fi
	fi

elif [[ "$1" == *loc* ]]; then

	loc=$(termux-location -p gps -r once)
	if [[ $(echo $loc | grep latitude) ]]; then
		lat=$(echo $loc | jq '.latitude')
		lon=$(echo $loc | jq '.longitude')
		
		if [[ $(termux-wifi-connectioninfo | grep $ssid_home) ]]; then
			location_name="home"
		else
			location_name="not_home"
		fi

		curl -H "Content-Type: application/json" -X POST -d '{"service": "device_tracker.see", "dev_id": "tasker_anton", "gps": ["$lat","$lon"], "location_name": "$location_home"}' http://192.168.1.94:8123/api/webhook/anton_homeaway
	else
		echo "Kunde inte fastställa plats, avbryter..."
		termux-notification -c "Kunde inte fastställa plats" --icon location_off
		exit
	fi

fi
