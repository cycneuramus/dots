#!/bin/bash

termux-wake-lock

log=$HOME/storage/shared/rclone.log

if [[ $1 == pushrespons ]]; then

    src_path="$HOME/storage/shared/Tasker"
    remote_path="Nextcloud:Dator/Skript/Loggfiler"

    rclone copy $src_path $remote_path -v \
	--filter "+ pushrespons.log" \
	--filter "- *"

fi

exec 1>$log 2>&1

if [[ $1 == bilder || $1 == allt ]]; then

    src_path="$HOME/storage/shared/DCIM/Camera"
    remote_path="Nextcloud:Bilder/Mobilder"

    rclone copy $src_path $remote_path -v \
        --filter "+ *.{jpg,jpeg,png,gif,mp4,mkv,avi}" \
        --filter "- *" \
	--ignore-existing # \
	# --dry-run

fi

if [[ $1 == diverse || $1 == allt ]]; then

    src_path="$HOME/storage/shared/"
    remote_path="Nextcloud:Säkerhetskopior/Telefon"

    rclone sync $src_path $remote_path -v \
	--filter "- **Image-ExifTool*/**" \
	--filter "- Tasker/userguide/**" \
        --filter "+ {bible,data,Inspelningar,Librera,Signal,Träning}/**" \
        --filter "- *" # \
	# --dry-run

fi

if [[ $1 == forskning || $1 == allt ]]; then

    src_path="$HOME/storage/shared/Forskning/Akademiskt"
    remote_path="Nextcloud:Texter/Forskning/Akademiskt"

    rclone copy $src_path $remote_path -v # \
	# --dry-run

fi

if [[ $1 == läsning || $1 == allt ]]; then

    src_path="$HOME/storage/shared/Forskning/Personligt"
    remote_path="Nextcloud:Texter/Forskning/Personligt"

    rclone copy $src_path $remote_path -v # \
	# --dry-run

fi

if [[ $1 == tibu || $1 == allt ]]; then

    src_path="$HOME/storage/shared/OABackupX"
    remote_path="Nextcloud:Säkerhetskopior/Telefon/OABackupX"

    rclone sync $src_path $remote_path -v # \
        # --dry-run

fi

termux-wake-unlock
