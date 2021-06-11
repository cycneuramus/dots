#!/bin/bash

push() {
	. secrets
	curl -X POST "$gotify_server/message?token=$gotify_token" -F "message=$1" -F "priority=1"
}

alert-done() {
	until [[ ! $(pgrep "$1") ]]; do
		sleep 5
	done
	push "$1 är färdigt"
}

cpu() {
	cat /proc/loadavg | awk -v cores=$(nproc) '{print int((($1 * 100) / cores) + 0.5)"%"}'
}


internet() { 
    # if wget -T 5 -q --spider http://kernel.org; then
	if ping -q -w1 -c1 kernel.org &>/dev/null; then
        echo "on"
    else
        echo "off"
    fi
}

signal-file() {
	. secrets
	$HOME/bin/signal-cli/bin/signal-cli -u $phone_number send -m "Från $(hostname)" $phone_number -a "$1"
}

signal-link() {
	. secrets
	$HOME/bin/signal-cli/bin/signal-cli link -n signal-cli-$(hostname) > qr & sleep 5; qrencode -t ANSI $(cat qr)
}

signal-msg() {
	. secrets
	$HOME/bin/signal-cli/bin/signal-cli -u $phone_number send -m "$1" $phone_number
}

# temp() {
#         sed 's/...$/°C/' /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp1_input
# 	# /sys/class/hwmon/hwmon2/temp1_input
# }

