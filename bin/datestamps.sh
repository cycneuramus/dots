#!/data/data/com.termux/files/usr/bin/bash

# exec 1>$HOME/storage/shared/datum.log 2>&1

for f in $@; do exiftool "-alldates<filename" "-FileModifyDate<filename" "-MediaCreateDate<filename" "-MediaModifyDate<filename" "-TrackCreateDate<filename" "-TrackModifyDate<filename" -overwrite_original "$f"
done

exit
