#!/data/data/com.termux/files/usr/bin/bash
. secrets

termux-wake-lock

# notifications=$(termux-notification-list)

if [[ $(termux-wifi-connectioninfo | grep $ssid_home) ]]; then
	curl -H "Content-Type: application/json" -X POST -d '{"service": "device_tracker.see", "dev_id": "tasker_anton", "location_name": "home"}' http://192.168.1.94:8123/api/webhook/anton_homeaway
else
	termux-wifi-enable true
	sleep 15

	if [[ ! $(termux-wifi-connectioninfo | grep $ssid_home) ]]; then
		termux-wifi-enable false
	fi
fi

termux-wake-unlock
