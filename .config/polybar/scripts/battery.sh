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

if [ "$ac" -eq 1 ]; then
    icon=""

    if [ "$battery_percent" -gt 97 ]; then
        echo "$icon"
    else
        echo "$icon %{T1}$battery_percent %"
    fi
else
    if [ "$battery_percent" -gt 90 ]; then
        icon=""
    elif [ "$battery_percent" -gt 80 ]; then
        icon=""
    elif [ "$battery_percent" -gt 70 ]; then
		icon=""
    elif [ "$battery_percent" -gt 60 ]; then
		icon=""
    elif [ "$battery_percent" -gt 50 ]; then
		icon=""
    elif [ "$battery_percent" -gt 40 ]; then
		icon=""
    elif [ "$battery_percent" -gt 30 ]; then
		icon=""
    elif [ "$battery_percent" -gt 20 ]; then
		icon=""
    elif [ "$battery_percent" -gt 10 ]; then
        icon=""
    else
        icon="%{F#BF616A}%{F-}"
    fi

    echo "$icon %{T1}$battery_percent %"
fi
