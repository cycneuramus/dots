#!/bin/bash
# /etc/NetworkManager/dispatcher.d/
# Must be owned by root! (chown root:root)

# DEBUG
# log=/home/antsva/nm-dispatcher.log
# exec 1>$log 2>&1
# set -x

. /home/antsva/.local/bin/functions.sh
	
# export DISPLAY=:0 
# export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus 

interface="$1"
status="$2"

wifi=$(wifi)

if [[ $interface == "wlp1s0" && $status == "up" ]]; then
	if [[ $wifi != "home" && ! $(nmcli con show -a | grep "Wireguard\|pivpn") ]]; then 
		vpn on
	elif [[ $wifi == "home" && $(nmcli con show -a | grep "Wireguard\|pivpn") ]]; then
		vpn off
	fi
# elif [[ $status == "connectivity-change" || $status == "down" ]]; then
# 	if [[ $wifi == "off" && $(nmcli con show -a | grep "Wireguard\|pivpn") ]]; then
# 		vpn off
# 	fi
fi
