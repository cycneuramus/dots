#!/bin/bash

push() {
	. secrets > /dev/null 2>&1
	curl -X POST "$gotify_server/message?token=$gotify_token" -F "message=$1" -F "priority=1"
}

alert-done() {
	until [[ ! $(pgrep "$1") ]]; do
		sleep 5
	done
	push "$1 är färdigt"
}

cpu() {
	# Get non-multicore load average from /proc/loadavg,
	# multiply by 100 to get percent value, divide by number of cpu cores 
	# to get the multicore load average, and round to nearest integer 
	# using 0.5 as the break-off value for rounding up or down
	cat /proc/loadavg | awk -v cores=$(nproc) '{print int((($1 * 100) / cores) + 0.5)"%"}'
}

cheat() {
	curl cheat.sh/$1
}

dots-sync() {
	commit_msg=$(date +"%Y%m%d_%H%M%S")

	dots commit -a -m "$commit_msg"
	dots push
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
	. secrets > /dev/null 2>&1
	$HOME/bin/signal-cli/bin/signal-cli -u $phone_number send -m "Från $(hostname)" $phone_number -a "$1"
}

signal-link() {
	$HOME/bin/signal-cli/bin/signal-cli link -n signal-cli-$(hostname) > qr & sleep 5; qrencode -t ANSI $(cat qr)
}

signal-msg() {
	. secrets > /dev/null 2>&1
	$HOME/bin/signal-cli/bin/signal-cli -u $phone_number send -m "$1" $phone_number
}

temp() {
	sed 's/...$/°C/' /sys/class/thermal/thermal_zone0/temp
}
