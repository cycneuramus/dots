#!/bin/bash

# Återställningsexempel (notera sudo): 
# sudo rclone mount Backblaze:antsva-x230 mnt/ --config=/home/antsva/.config/rclone/rclone.conf &
# sudo borg extract /home/antsva/mnt::x230-20201130_040002 home/antsva/

if (( $EUID != 0 )); then
    echo "Needs to be run as root"
    exit
fi

. funktioner.sh
. secrets

# export BORG_REPO=ssh://antsva@localhost//mnt/extern/backup/x230/borgbak
export BORG_REPO=/mnt/extern/backup/x230/borgbak
export BORG_PASSPHRASE="$borg_pass"
export RCLONE_CONFIG_PASS="$rclone_config_pass"

remote_path="$borg_repo"
src_path=/mnt/extern/backup/x230/borgbak
rclone_cfg=/home/antsva/.config/rclone/rclone.conf
exclude=/home/antsva/bin/borg.exclude
log=/home/antsva/log/borg-backup.log

# Kommenterar ut detta och sköter loggdirigering från CRON i stället
# exec 1>$log 2>&1

cp /etc/systemd/logind.conf /home/antsva/bak/logind.conf.bak
cp /etc/default/tlp /home/antsva/bak/tlp.bak
cp /etc/default/grub /home/antsva/bak/grub.bak
cp /etc/fstab /home/antsva/bak/fstab.bak
cp /etc/sysctl.conf /home/antsva/bak/sysctl.conf.bak

crontab -l > /home/antsva/bak/crontab-root.bak
crontab -u antsva -l > /home/antsva/bak/crontab-antsva.bak

docker pause $(docker ps -q)

echo "Påbörjar säkerhetskopiering..."
borg create								\
    --exclude-caches					\
	--exclude-from $exclude				\
	--stats								\
    --list								\
    --filter=AME						\
    --compression auto,zstd,6			\
										\
    ::'{hostname}-{now:%Y%m%d_%H%M%S}'	\
    /home/antsva

backup_exit=$?

docker unpause $(docker ps -q)

echo "Trimmar säkerhetskopior..."
borg prune							\
    --list							\
    --prefix '{hostname}-'			\
    --keep-daily	1				\
    --keep-weekly	2               \
    --keep-monthly	2				\
	--keep-yearly	1

prune_exit=$?

if (( $backup_exit + $prune_exit == 0 )); then
    rclone sync $src_path $remote_path -v	\
        --config=$rclone_cfg				\
        --fast-list							\
        --transfers=16						\
        --delete-excluded					\
        --stats=10s
    rclone_exit=$?
else
    rclone_exit=0
fi

if (( $backup_exit + $prune_exit + $rclone_exit > 0 )); then
    push "Schemalagd säkerhetskopiering stötte på fel"
fi
