#!/bin/bash

. $BIN/functions.sh


if [[ $(pgrep -f "audacity|zoom|ffmpeg|mpv") || $(pactl list sinks | grep RUNNING) || $(lid) == "closed" ]]; then
	exit
fi

# if (( $idletime > $targettime )); then
# 	Start screensaver on external monitor if found 
# 	if [[ $(xrandr --listmonitors | grep HDMI | wc -l) == 1 ]]; then 
# 		konsole --fullscreen -geometry 1920x1200+0-0 -e unimatrix -l Gg -s 90 &   
# 	fi
# 	konsole --fullscreen -geometry 1920x1200+0-0 -e unimatrix -l Gg -s 90 &   
# fi

if [[ ! $(wmctrl -lp | grep unimatrix) ]]; then
	kitty --start-as fullscreen -e unimatrix -l Gg -s 90 &
fi
