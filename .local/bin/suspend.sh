#!/bin/bash

. $BIN/functions.sh

if [[ $(pwr) == "bat" && ! $(pgrep "audacity|zoom|ffmpeg|mpv|pacman|yay") && ! $(pactl list sinks | grep RUNNING) ]]; then 
	bash $HOME/.local/bin/lock.sh
	systemctl suspend
fi
