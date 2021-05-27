#!/bin/sh

if [[ $(rfkill list bluetooth | grep "Soft blocked: yes") ]]; then
	sudo rfkill unblock bluetooth
	sleep 1
	bluetoothctl power on >> /dev/null
	sleep 1

	devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
	echo "$devices_paired" | while read -r line; do
		bluetoothctl connect "$line" >> /dev/null
	done
else
	devices_paired=$(bluetoothctl paired-devices | grep Device | cut -d ' ' -f 2)
	echo "$devices_paired" | while read -r line; do
		bluetoothctl disconnect "$line" >> /dev/null
	done

	bluetoothctl power off >> /dev/null
	sleep 1
	sudo rfkill block bluetooth
fi
