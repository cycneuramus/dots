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
wifi_type=$(wifi-type)
vpn=$(nmcli con show -a | grep "Wireguard\|pivpn")

if [[ "$interface" == "$wifi_interface" && "$status" == "up" ]]; then

	sudo -u antsva DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
		notify-send -i nm-device-wireless "Wi-Fi ansluten" "$(ssid)"

	if [[ "$wifi_type" != @(home|hotspot) && ! "$vpn" ]]; then 
		vpn on

		if [[ "$wifi_type" == "trusted" && $(ip-local) = 192.168.1* ]]; then
			vpn-fix
		fi
	elif [[ "$wifi_type" == @(home|hotspot) && "$vpn" ]]; then
		vpn off
	fi

elif [[ "$status" == "down" || "$status" == "connectivity-change" ]]; then

	if [[ "$wifi_type" == "off" && "$vpn" ]]; then
		vpn off
	fi

fi

polybar-msg hook networkmanager 1 &>/dev/null
