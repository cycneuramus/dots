#!/bin/bash

if [[ $(pgrep i3lock) ]]; then exit; fi

C='#4c566a'
D='#3b4252'
H='#81a1c1'
T='#eceff4'
W='#Bf616a'

i3lock -C -i $BIN/lock.png 	\
--insidevercolor=$C   		\
--ringvercolor=$D     		\
							\
--insidewrongcolor=$C 		\
--ringwrongcolor=$W   		\
							\
--insidecolor=$C      		\
--ringcolor=$D        		\
--linecolor=$D        		\
--separatorcolor=$D   		\
							\
--verifcolor=$T        		\
--wrongcolor=$T        		\
--layoutcolor=$T      		\
--keyhlcolor=$H       		\
--bshlcolor=$H        		\
							\
--blur 5              		\
