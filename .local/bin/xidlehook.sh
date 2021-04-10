#!/bin/bash

# Only exported variables can be used within the timer's command.
# export PRIMARY_DISPLAY="$(xrandr | awk '/ primary/{print $1}')"

killall -q xidlehook
while pgrep -u $UID -x xidlehook >/dev/null; do sleep 1; done

xidlehook \
  --not-when-audio \
  --timer 300 \
  	'$HOME/.local/bin/screensaver.sh' \
	'if [[ $(wmctrl -l | grep unimatrix) ]]; then wmctrl -lp | awk "/unimatrix/{print \$3}" | xargs kill; fi' \
  --timer 300 \
  'if [[ $(acpi) == *Discharging* ]]; then wmctrl -lp | awk "/unimatrix/{print \$3}" | xargs kill && sleep 1 && bash $HOME/.local/bin/lock.sh && systemctl suspend; fi' \
	''
