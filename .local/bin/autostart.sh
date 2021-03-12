#!/bin/bash

. $BIN/functions.sh

log=$LOG/autostart.log
exec 1>$log 2>&1

# Redshift
until [[ $(internet) == "on" ]]; do
	sleep 5
	count=$(($count + 1))
	if (( $count > 10 )); then break; fi
done
rs on
