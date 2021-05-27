#!/bin/bash
# /etc/NetworkManager/dispatcher.d/
# Must be owned by root! (chown root:root)

# DEBUG
# log=/home/antsva/nm-dispatcher.log
# exec 1>$log 2>&1
# set -x

. /home/antsva/.local/bin/functions.sh
	
interface="$1"
status="$2"

wifi_interface=$(ls /sys/class/ieee80211/*/device/net/)
wifi_type=$(wifi_type)
vpn=$(nmcli con show -a | grep "Wireguard\|pivpn")

if [[ "$interface" == "$wifi_interface" && "$status" == "up" ]]; then
	if [[ "$wifi_type" != @(home|hotspot) && ! "$vpn" ]]; then 
		vpn on
	elif [[ "$wifi_type" == @(home|hotspot) && "$vpn" ]]; then
		vpn off
	fi
elif [[ "$status" == "down" || "$status" == "connectivity-change" ]]; then
	if [[ "$wifi_type" == "off" && "$vpn" ]]; then
		vpn off
	fi
fi

polybar-msg hook networkmanager 1 &>/dev/null
