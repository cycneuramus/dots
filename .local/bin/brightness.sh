#!/bin/bash

if [[ "$1" == "up" ]]; then
	xbacklight -inc 5
elif [[ "$1" == "down" ]]; then
	xbacklight -dec 5
fi

current=$(xbacklight -get)

msg_id=991049
dunstify -t 1500 -i display-brightness-symbolic -r "$msg_id" "Ljusstyrka" "${current}%"
