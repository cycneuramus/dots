#!/bin/bash

if (( $EUID != 0 )); then
    echo "Var vänlig kör som root"
    exit
fi

. functions.sh
. secrets

trap 'push "$(basename $0) stötte på fel"' err

export B2_ACCOUNT_ID=$b2_account_id 
export B2_ACCOUNT_KEY=$b2_account_key
export RESTIC_REPOSITORY=$restic_repo 
export RESTIC_PASSWORD=$restic_pass 

# First run:
# restic -r $restic_repo init
# exit 

docker pause $(docker ps -q)

restic backup /home/antsva			\
	--verbose						\
	--exclude-caches				\
	--exclude="/home/antsva/mnt"	
backup_exit=$?

docker unpause $(docker ps -q)

restic forget			\
	--keep-daily 1 		\
	--keep-weekly 2 	\
	--keep-monthly 2 	\
	--keep-yearly 1 	\
	--prune
prune_exit=$?

restic check --with-cache
check_exit=$?

if (( $backup_exit + $prune_exit + $check_exit > 0 )); then
	push "Schemalagd säkerhetskopiering stötte på fel"
else
	push "Schemalagd säkerhetskopiering slutförd med framgång"
fi
