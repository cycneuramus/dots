#!/bin/bash

if [[ "$1" == "up" ]]; then
	pactl set-sink-volume @DEFAULT_SINK@ +5%
elif [[ "$1" == "down" ]]; then
	pactl set-sink-volume @DEFAULT_SINK@ -5%
fi

# current_volume=$(pamixer --get-volume)
# current_volume=$(pacmd list-sinks | grep -A 15 '* index'| awk '/volume: front/{ print $5 }' | sed 's/[%|,]//g')
current_sink=$(pactl list short sinks | sed -e 's,^\([0-9][0-9]*\)[^0-9].*,\1,' | head -n 1)
current_volume=$(pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $current_sink + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')


if (( $current_volume <= 30 )); then
	icon="audio-volume-low-symbolic"
elif (( $current_volume > 30 && $current_volume < 70 )); then
	icon="audio-volume-medium-symbolic"
elif (( $current_volume >= 70)); then
	icon="audio-volume-high-symbolic"
fi

# canberra-gtk-play -i audio-volume-change -d "changeVolume"
pw-play /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga

msg_id=991050
dunstify -u low -t 1500 -i "$icon" -r "$msg_id" "Ljudvolym" "${current_volume}%"
