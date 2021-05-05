#!/bin/bash

. $BIN/functions.sh
. $BIN/secrets > /dev/null 2>&1

export BORG_REPO=$borg_repo
export BORG_PASSPHRASE=$borg_pass

log=$LOG/borg-backup.log
pacman=$LOG/pkg.pacman
aur=$LOG/pkg.aur
exclude=$BIN/borg.exclude
src_path=$HOME/.borgbak
remote_path="Nextcloud:Säkerhetskopior/Dator"
wifi=$(wifi)

# Limit execution to every 24 hours by checking for age of log file
if [[ -f "$log" && ! $(find "$log" -mmin +1440) ]]; then exit; fi

exec 1>$log 2>&1

notify-send "Säkerhetskopiering" "Påbörjar synkronisering..."

pacman -Qqe | grep -vx "$(pacman -Qqm)" > $pacman
pacman -Qqm > $aur

echo "Påbörjar säkerhetskopiering..."
borg create							\
	--exclude-from $exclude			\
	--exclude-caches				\
	--stats							\
	--list							\
	--filter=AME					\
	--compression lzma,6			\
									\
	::'{hostname}-{now:%Y%m%d}'		\
	$HOME

backup_exit=$?	  

echo "Trimmar säkerhetskopior..."
borg prune							\
	--list							\
	--prefix '{hostname}-'			\
	--keep-daily	1				\
	--keep-weekly	2				\
	--keep-monthly	2

prune_exit=$?
	
if [[ $wifi = "home" && $(( $backup_exit + $prune_exit )) == 0 ]]; then
	rclone sync $src_path $remote_path -v \
	--delete-excluded					  \
	--stats=10s

	rclone_exit=$?
else
	rclone_exit=0
fi

if (( $backup_exit + $prune_exit + $rclone_exit > 0 )); then
	result="felmeddelanden"
else
	result="framgång"
fi

notify-send -t 60000 "Säkerhetskopiering" "Slutfördes med $result"

# fwupdmgr refresh
# if [[ $(fwupdmgr get-updates | grep "Ny version\|New version") ]]; then 
#	  notify-send -t 60000 "fwupdmgr" "Uppdateringar tillgängliga"
# fi

# https://github.com/rand256/valetudo/issues/41#issuecomment-565130242
if [[ $wifi = "home" ]]; then
	curl http://192.168.1.5/api/get_config > $HOME/Nextcloud/Säkerhetskopior/Dammsugare/valetudo_bak.json
fi

pkg-update-check pjheslin/diogenes
pkg-update-check rand256/valetudo
# pkg-update-check john9527/asuswrt-merlin
