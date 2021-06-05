#!/bin/bash

if [[ $(pgrep i3lock) ]]; then exit; fi

C='#4c566a'
D='#3b4252'
H='#81a1c1'
T='#eceff4'
W='#Bf616a'

if [[ $(wmctrl -l | grep unimatrix) ]]; then 
	wmctrl -lp | awk "/unimatrix/{print \$3}" | xargs kill
fi

i3lock -C -i $BIN/lock.png 	\
--verif-text=""				\
--wrong-text=""				\
--lock-text=""				\
							\
--insidever-color=$D   		\
--ringver-color=$C    		\
							\
--insidewrong-color=$D 		\
--ringwrong-color=$W   		\
							\
--inside-color=$C      		\
--ring-color=$D        		\
--line-color=$D        		\
--separator-color=$D   		\
							\
--verif-color=$T        	\
--wrong-color=$T        	\
--layout-color=$T      		\
--keyhl-color=$H       		\
--bshl-color=$H        		\
							\
--blur 5              		\
