#!/bin/bash

C='#4c566a'
D='#3b4252'
H='#81a1c1'
T='#eceff4'
W='#Bf616a'

i3lock \
--insidevercolor=$C   \
--ringvercolor=$D     \
\
--insidewrongcolor=$D \
--ringwrongcolor=$W   \
\
--insidecolor=$D      \
--ringcolor=$C        \
--linecolor=$D        \
--separatorcolor=$D   \
\
--verifcolor=$T        \
--wrongcolor=$T        \
--layoutcolor=$T      \
--keyhlcolor=$H       \
--bshlcolor=$H        \
\
--blur 5              \
