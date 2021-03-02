ffmpeg -i "$1" -c:v libx264 -vf scale="480:-2" -c:a copy -x264-params crf=28 "${1%.*}_komp.${1#*.}"
