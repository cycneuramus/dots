#!/bin/sh
if [[ $(rfkill list bluetooth | grep "Soft blocked: yes") ]]; then
	echo "%{F#66ffffff}󰂯"
else
	if [ $(echo info | bluetoothctl | grep 'Device' | wc -c) -eq 0 ]; then 
		echo "󰂯"
	else
		echo "󰂱"
	fi
fi
