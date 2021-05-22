#!/bin/bash

set -e

backup_dir="/mnt/extern/backup/x230/borgbak"
last_dir=$(pwd)

select backup in $(sudo borg list "$backup_dir" | awk '{print $1}' | tr "\n" " "); do

	echo "This is a dangerous operation. To proceed, type \"yes\"":
	read answer

	if [[ "$answer" == "yes" ]]; then
		cd /
		sudo borg extract --list "$backup_dir"::"$backup"	\
			home/$USER/docker								\
			home/$USER/.local/share/signal-cli
	else
		echo ""
		echo "Aborted."
		exit
	fi

	break
done

cd "$last_dir"
