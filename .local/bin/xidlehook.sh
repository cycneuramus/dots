#!/bin/bash

# Only exported variables can be used within the timer's command.
# export PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"

# Run xidlehook
xidlehook \
  --not-when-fullscreen \
  --not-when-audio \
  --timer 300 \
  	'$HOME/.local/bin/screensaver.sh' \
	'xdotool key q' \
  --timer 600 \
    'systemctl suspend' \
    ''
