#!/bin/bash
# Put script in $HOME/.config/autostart-scripts/

. $BIN/functions.sh

log=$LOG/autostart.log
exec 1>$log 2>&1

# Touchpad gestures
# if ! pgrep gebaard; then
#     gebaard -b
# fi

# Turn off bluetooth
rfkill block bluetooth

# Redshift
until [[ $(internet) == "on" ]]; do
	sleep 5
	count=$(($count + 1))
	if (( $count > 10 )); then break; fi
done
rs on

# spotifyd &
# clight &
