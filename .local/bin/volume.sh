#!/bin/bash

if [[ "$1" == "up" ]]; then
	pactl set-sink-volume @DEFAULT_SINK@ +5%
elif [[ "$1" == "down" ]]; then
	pactl set-sink-volume @DEFAULT_SINK@ -5%
fi

current=$(pacmd list-sinks | grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/[%|,]//g')

if (( $current < 25 )); then
	icon="audio-volume-low-symbolic"
elif (( $current >= 25 && $current < 50 )); then
	icon="audio-volume-medium-symbolic"
elif (( $current >= 50 && $current < 75 )); then
	icon="audio-volume-high-symbolic"
elif (( $current >= 75 )); then
	icon="audio-volume-overamplified-symbolic"
fi

canberra-gtk-play -i audio-volume-change -d "changeVolume"

msg_id=991050
dunstify -u low -t 1500 -i "$icon" -r "$msg_id" "Ljudvolym" "${current}%"
