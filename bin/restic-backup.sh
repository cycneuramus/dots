#!/bin/bash

if (( $EUID != 0 )); then
    echo "This script must be run as root"
    exit
fi

. functions.sh
. secrets > /dev/null 2>&1

trap 'push "$(basename $0) stötte på fel"' err

export B2_ACCOUNT_ID=$b2_account_id 
export B2_ACCOUNT_KEY=$b2_account_key
export RESTIC_REPOSITORY=$restic_repo 
export RESTIC_PASSWORD=$restic_pass 

# First run:
# restic -r $restic_repo init
# exit 

running_containers=$(docker ps -q)
docker pause $running_containers

restic backup /home/antsva			\
	--verbose						\
	--exclude-caches				\
	--exclude="/home/antsva/mnt"	
backup_exit=$?

docker unpause $running_containers

restic forget			\
	--keep-daily 1 		\
	--keep-weekly 2 	\
	--keep-monthly 2 	\
	--keep-yearly 1 	\
	--prune

restic check --with-cache
