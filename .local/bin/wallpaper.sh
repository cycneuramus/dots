#!/bin/bash

wallpapers_path=/home/antsva/.local/share/wallpapers/nord
random_wallpaper=$(ls "$wallpapers_path" | shuf -n 1)

if command -v xrandr; then
	for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
		feh --bg-fill ${wallpapers_path}/${random_wallpaper}
	done
fi
