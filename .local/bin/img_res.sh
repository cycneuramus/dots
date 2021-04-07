#!/bin/bash

target_width="1920"
target_height="1080"
target_resolution="${target_width}x${target_height}"

mkdir new_res
for f in *.{png,jpg,jpeg}; do 
	if (( $(identify -ping -format '%w' "$f") )) > "$target_width"; then 
		convert "$f" -resize "$target_resolution" new_res/"$f"
	fi
done
