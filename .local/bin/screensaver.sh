#!/bin/bash

. $BIN/functions.sh

# if [[ $(pgrep -f "audacity|zoom|ffmpeg|vlc") || $(lid) == "closed" || $(ps -fA) =~ unimatrix || $(system-sleep-inhibited) == true ]]; then exit; fi

if [[ $(pgrep -f "audacity|zoom|ffmpeg|vlc") || $(lid) == "closed" || $(ps -fA) =~ unimatrix ]]; then exit; fi

# Get system inactive time and convert from ms to sec
# idletime=$(expr $(qdbus org.kde.screensaver /ScreenSaver GetSessionIdleTime) / 1000)
# 
# # Start screensaver after x seconds
# if [[ $1 ]]; then
# 	targettime=$1 # För testning
# else
# 	targettime=300
# fi

# if (( $idletime > $targettime )); then
	# Start screensaver on external monitor if found 
	if [[ $(xrandr --listmonitors | grep HDMI | wc -l) == 1 ]]; then 
		# konsole --fullscreen -geometry 1920x1200+0-0 -e unimatrix -l Gg -s 90 &   
		kitty --start-as fullscreen -e unimatrix -l Gg -s 90 &   
	fi
	# konsole --fullscreen -geometry 1920x1200+0-0 -e unimatrix -l Gg -s 90 &   
	kitty --start-as fullscreen -e unimatrix -l Gg -s 90 &
# fi
