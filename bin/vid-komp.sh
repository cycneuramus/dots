#!/bin/bash

if [[ "$2" ]]; then
        kvalitet="$2"
    else
        kvalitet=25
    fi

    ffmpeg -i "$1" -c:v libx265 -c:a copy -x265-params crf="$kvalitet" "${1%.*}_komp.${1#*.}"
