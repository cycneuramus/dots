#!/bin/bash

. funktioner.sh

last_dir=$(pwd)
cd $HOME/docker

for f in *; do
	cd $f

	docker-compose pull
	if [[ $(docker-compose up -d 2>&1) == *Recreating* ]]; then
		updated="$updated$f\n"
	fi

	cd ..
done

# if [[ $(echo $updated | grep librephotos) ]]; then
# 	cd caddy
# 	docker-compose restart 2>&1
# fi 

if [[ -n $updated ]]; then
	newline=$'\n'
	push "Dockerbehållare har uppdaterats:${newline}${newline}$(printf $updated)" # printf för att slippa eftersläpande radbrytning (https://unix.stackexchange.com/a/140906)
else
	echo "Inga uppdateringar."
fi

cd $last_dir
docker system prune -af
