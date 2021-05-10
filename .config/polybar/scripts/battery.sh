#!/bin/sh

PATH_AC="/sys/class/power_supply/AC0"
PATH_BATTERY_0="/sys/class/power_supply/BAT0"
PATH_BATTERY_1="/sys/class/power_supply/BAT1"

ac=0
battery_level_0=0
battery_level_1=0
battery_max_0=0
battery_max_1=0

if [ -f "$PATH_AC/online" ]; then
    ac=$(cat "$PATH_AC/online")
fi

if [ -f "$PATH_BATTERY_0/charge_now" ]; then
    battery_level_0=$(cat "$PATH_BATTERY_0/charge_now")
fi

if [ -f "$PATH_BATTERY_0/charge_full" ]; then
    battery_max_0=$(cat "$PATH_BATTERY_0/charge_full")
fi

if [ -f "$PATH_BATTERY_1/charge_now" ]; then
    battery_level_1=$(cat "$PATH_BATTERY_1/charge_now")
fi

if [ -f "$PATH_BATTERY_1/charge_full" ]; then
    battery_max_1=$(cat "$PATH_BATTERY_1/charge_full")
fi

battery_level=$(("$battery_level_0 + $battery_level_1"))
battery_max=$(("$battery_max_0 + $battery_max_1"))

battery_percent=$(("$battery_level * 100"))
battery_percent=$(("$battery_percent / $battery_max"))

teal="%{F#88C0D0}"
green="%{F#A3BE8C}"
yellow="%{F#EBCB8B}"
orange="%{F#D08770}"
red="%{F#BF616A}"

if [ "$ac" -eq 1 ]; then
    if [ "$battery_percent" -ge 90 ]; then
        icon="󰂅"
    elif [ "$battery_percent" -ge 80 ]; then
        icon="󰂋"
    elif [ "$battery_percent" -ge 70 ]; then
		icon="󰂊"
    elif [ "$battery_percent" -ge 60 ]; then
		icon="󰢞"
    elif [ "$battery_percent" -ge 50 ]; then
		icon="󰂉"
    elif [ "$battery_percent" -ge 40 ]; then
        icon="󰢝"
    elif [ "$battery_percent" -ge 30 ]; then
		icon="${yellow}󰂈"
    elif [ "$battery_percent" -ge 20 ]; then
		icon="${red}󰂇"
    elif [ "$battery_percent" -ge 10 ]; then
        icon="${red}󰂆"
    else
        icon="${red}󰢜"
    fi

	echo "$icon %{F-}%{T1}$battery_percent %"
else
    if [ "$battery_percent" -ge 90 ]; then
        icon="󰁹"
    elif [ "$battery_percent" -ge 80 ]; then
        icon="󰂂"
    elif [ "$battery_percent" -ge 70 ]; then
		icon="󰂁"
    elif [ "$battery_percent" -ge 60 ]; then
		icon="󰂀"
    elif [ "$battery_percent" -ge 50 ]; then
		icon="󰁿"
    elif [ "$battery_percent" -ge 40 ]; then
        icon="󰁾"
    elif [ "$battery_percent" -ge 30 ]; then
		icon="${yellow}󰁽"
    elif [ "$battery_percent" -ge 20 ]; then
		icon="${red}󰁼"
    elif [ "$battery_percent" -ge 10 ]; then
        icon="${red}󰁻"
    else
        icon="${red}󰁺"
    fi

	if [ "$battery_percent" -eq 20 ]; then
		$HOME/.config/polybar/scripts/low-battery.sh
	fi
    echo "$icon %{F-}%{T1}$battery_percent %"
    # echo "$icon"
fi
