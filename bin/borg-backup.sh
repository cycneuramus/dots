#!/bin/bash

# Återställningsexempel (notera sudo): 
#
# cd /
# sudo borg extract --list /mnt/extern/backup/x230/borgbak::x230-20210522_040002 home/antsva/
#
# sudo rclone mount Backblaze:antsva-x230 mnt/ --config=/home/antsva/.config/rclone/rclone.conf &
# cd /
# sudo borg extract --list /home/antsva/mnt::x230-20201130_040002 home/antsva/

if (( $EUID != 0 )); then
    echo "Needs to be run as root"
    exit
fi

. functions.sh
. secrets > /dev/null 2>&1

trap 'push "$(basename $0) stötte på fel"' err

export BORG_REPO=/mnt/extern/backup/x230/borgbak
export BORG_PASSPHRASE="$borg_pass"

remote_path="$borg_repo"
src_path=/mnt/extern/backup/x230/borgbak

rclone_cfg=/home/antsva/.config/rclone/rclone.conf
exclude=/home/antsva/bin/borg.exclude

log=/home/antsva/log/borg-backup.log
# running_containers=$(docker ps -q)

cp /etc/default/tlp /home/antsva/bak/tlp.bak
cp /etc/systemd/resolved.conf.d/adguardhome.conf /home/antsva/bak/adguardhome.conf.bak
cp /etc/update-motd.d/20-sysinfo /home/antsva/bak/20-sysinfo.bak

crontab -l > /home/antsva/bak/crontab-root.bak
crontab -u antsva -l > /home/antsva/bak/crontab-antsva.bak

# docker pause $running_containers

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

# docker unpause $running_containers

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
fi
