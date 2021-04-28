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
	# mpstat 2 1 | grep "Genomsnitt" | awk '$12 ~ /[0-9.]+/ { print 100 - $12"%" }'
	{ head -n1 /proc/stat; sleep 5; head -n1 /proc/stat; } | awk '/^cpu /{u=$2-u;s=$4-s;i=$5-i;w=$6-w}END{print int(0.5+100*(u+s+w)/(u+s+i+w))"%"}'
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

pylint() {
	pylama "$1" -f pylint
}

signal-file() {
	. secrets
	$HOME/bin/signal-cli/bin/signal-cli -u $phone_number send -m "Från $(hostname)" $phone_number -a "$1"
}

signal-link() {
	$HOME/bin/signal-cli/bin/signal-cli link -n signal-cli-$(hostname) > qr & sleep 5; qrencode -t ANSI $(cat qr)
}

signal-msg() {
	. secrets
	$HOME/bin/signal-cli/bin/signal-cli -u $phone_number send -m "$1" $phone_number
}

temp() {
        sed 's/...$/°C/' /sys/devices/platform/thinkpad_hwmon/hwmon/hwmon3/temp1_input
	# /sys/class/hwmon/hwmon2/temp1_input
}
