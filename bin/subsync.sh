#!/bin/bash
usage() {
	echo Usage: subsync.sh \"sub-file.srt\" \"vid-file.mp4\"
	exit
}

if (( $# < 2 )); then
	usage
fi

sub="$1"
vid="$2"

ffsubsync "$2" -i "$1" -o "$1"
