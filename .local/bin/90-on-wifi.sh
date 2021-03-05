#!/bin/bash
# /etc/NetworkManager/dispatcher.d/
# Must be owned by root! (chown root:root)

# DEBUG
# log=/home/antsva/Skrivbord/nm.log
# exec 1>$log 2>&1
# set -x

. /home/antsva/.local/bin/functions.sh
	
# Continue only if triggered by Wi-Fi-connection
if [[ $2 != "up" || $1 != "wlp1s0" ]]; then exit; fi # || $(internet) = "off" ]]; then exit; fi

wifi=$(wifi)

if [[ $wifi != "home" && ! $(nmcli con show -a | grep "Wireguard\|pivpn") ]]; then 
	vpn on
elif [[ $wifi == "home" && $(nmcli con show -a | grep "Wireguard\|pivpn") ]]; then
	vpn off
fi
