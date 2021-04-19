#!/bin/bash

# Designed to run as a cron job every 10 minutes

. functions.sh
trap 'push "$(basename $0) stötte på fel"' err

lock=/tmp/sysmonitor_triggered.tmp
cpu=$(cpu | sed 's/[^0-9]//g')
temp=$(temp | sed 's/[^0-9]//g')

if (( $cpu > 30 || $temp > 60 )); then

    if [[ -f $lock ]]; then
		newline=$'\n'
        push "Server ($(hostname)) under kontinuerlig belastning${newline}${newline}CPU: $cpu%${newline}Temp: $temp°${newline}${newline}$(ps -eo pcpu,args --sort=-pcpu | awk 'NR >= 2 && NR <= 6 { print $1"%",$2 }')"
        rm $lock
    else
        touch $lock
    fi

else
    if [[ -f $lock ]]; then rm $lock; fi
fi
