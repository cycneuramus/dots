#!/bin/bash

if [[ "$1" == "up" ]]; then
	xbacklight -inc 5
elif [[ "$1" == "down" ]]; then
	xbacklight -dec 5
fi

current=$(xbacklight -get)

if (( $current < 25 )); then
	icon="display-brightness-off-symbolic"
elif (( $current >= 25 && $current < 50 )); then
	icon="display-brightness-low-symbolic"
elif (( $current >= 50 && $current < 75 )); then
	icon="display-brightness-medium-symbolic"
elif (( $current >= 75 )); then
	icon="display-brightness-high-symbolic"
fi

msg_id=991049
dunstify -u low -t 1500 -i "$icon" -r "$msg_id" "Ljusstyrka" "${current}%"
