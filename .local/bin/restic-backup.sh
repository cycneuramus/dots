#!/bin/bash

# Lazy workaround for running from ACPI handler while keeping env variables
if [[ -z $BIN ]]; then
	. /home/antsva/.profile
fi

. $BIN/functions.sh
. $BIN/secrets > /dev/null 2>&1

export RESTIC_REPOSITORY="$restic_repo"
export RESTIC_PASSWORD="$restic_pass"

pacman=$CFG/pkg.pacman
aur=$CFG/pkg.aur
log=$LOG/restic-backup.log
exclude=$BIN/restic.exclude
rclone_args="serve restic --stdio --verbose --stats=10s"

# Initialize repository
# restic -r $restic_repo init
# exit 

# Limit execution to once every 24 hours by checking for age of log file
if [[ -f "$log" && ! $(find "$log" -mmin +1440) ]]; then exit; fi

pacman -Qqen > $pacman
pacman -Qqem > $aur

commit_msg=$(date +"%Y%m%d_%H%M%S")
git --git-dir=$HOME/.dots/ --work-tree=$HOME commit -a -m "$commit_msg"
git --git-dir=$HOME/.dots/ --work-tree=$HOME push 

if [[ $(wifi_type) != "home" ]]; then exit; fi

exec 1>$log 2>&1
notify-send "Säkerhetskopiering" "Påbörjar synkronisering..."

echo "Påbörjar säkerhetskopiering..."
restic backup						\
	-o rclone.args="$rclone_args"	\
	--verbose						\
	--exclude-caches				\
	--exclude-file="$exclude"		\
	$HOME
backup_exit=$?

restic forget						\
	-o rclone.args="$rclone_args"	\
	--keep-daily 1					\
	--keep-weekly 2					\
	--keep-monthly 2				\
	--prune
prune_exit=$?

restic check						\
	-o rclone.args="$rclone_args"	\
	--with-cache					
check_exit=$?

if (( $backup_exit + $prune_exit + $check_exit > 0 )); then
	result="felmeddelanden"
else
	result="framgång"
fi

# fwupdmgr refresh
# if [[ $(fwupdmgr get-updates | grep "Ny version\|New version") ]]; then
#	  notify-send -t 60000 "fwupdmgr" "Uppdateringar tillgängliga"
# fi

flatpak --user update -y

# https://github.com/rand256/valetudo/issues/41#issuecomment-565130242
curl http://192.168.1.5/api/get_config > $HOME/Nextcloud/Säkerhetskopior/Dammsugare/valetudo_bak.json

pkg-update-check pjheslin/diogenes
pkg-update-check rand256/valetudo
# pkg-update-check john9527/asuswrt-merlin

notify-send -t 60000 "Säkerhetskopiering" "Slutfördes med $result"
