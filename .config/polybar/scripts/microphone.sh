#!/bin/sh

current_source=$(pactl info | grep "Default Source" | cut -f3 -d" ")

if [[ $1 == "toggle" ]]; then
	pactl set-source-mute "$current_source" toggle
fi

muted=$(pactl list sources | grep -A 10 "$current_source" | grep "Mute: yes")

if [[ $muted ]]; then
	echo "%{F#66ffffff}󰍭"
else
	echo "󰍬"
fi
