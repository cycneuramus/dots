#!/bin/bash

unixtime_now=$(date +%s)
unixtime_wakeup=$(journalctl -q -n1 -u sleep.target -o short-unix | cut -d. -f1)
minutes_since_wakeup=$(( ($unixtime_now - $unixtime_wakeup) / 60 ))

if (( $minutes_since_wakeup > 3 )); then 
	notify-send "$1" "$2"
	# paplay /usr/share/sounds/Oxygen-Im-Message-In.ogg
	paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga
fi
