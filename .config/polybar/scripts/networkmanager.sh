#!/bin/bash

if [[ $(nmcli radio wifi) == "enabled" ]]; then
	connection=$(nmcli -t -f name,device,state connection show --order type --active 2>/dev/null | grep -v ":bridge:")

	if [[ $(echo $connection | grep "Wireguard\|pivpn") ]]; then
		vpn=true
		connection=$(echo $connection | head -n 1)
	else
		vpn=false
	fi

	ssid=$(echo $connection | cut -d ":" -f 1)
	interface=$(echo $connection | cut -d ":" -f 2)

	signal=$(nmcli -f in-use,signal device wifi | awk '/\*/{print $2}')
	if [[ -z $signal ]]; then
		signal=0
	fi

	if [[ $vpn == "true" ]]; then
		if (( $signal >= 75 )); then
			icon="󰤪"
		elif (( $signal >= 50 )); then
			icon="󰤧"
		elif (( $signal >= 25 )); then
			icon="󰤤"
		elif (( $signal >= 1 )); then
			icon="󰤡"
		else
			icon="%{F#66ffffff}󰤨"
		fi
	else
		if (( $signal >= 75 )); then
			icon="󰤨"
		elif (( $signal >= 50 )); then
			icon="󰤥"
		elif (( $signal >= 25 )); then
			icon="󰤢"
		elif (( $signal >= 1 )); then
			icon="󰤟"
		else
			icon="%{F#66ffffff}󰤨"
		fi
	fi
else
	icon="%{F#66ffffff}󰤭" 
fi

echo "$icon"
# echo "$icon  %{F-}%{T1}$ssid"
