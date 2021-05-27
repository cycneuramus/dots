#!/bin/bash

battery_level=$(acpi | awk '{print $4}' | tr -d ,)

if [[ "$1" == "critical" ]]; then
	msg_id=43545
	dunstify -u critical -r "$msg_id" -i battery "Låg batterinivå" "$battery_level"
else
	msg_id=23874
	dunstify -u low -t 1500 -r "$msg_id" -i battery "Batterinivå" "$battery_level"
fi
