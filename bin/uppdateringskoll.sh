#!/bin/bash

# Kontrollera uppdateringar och avisera på telefon
# https://www.a-netz.de/blog/2012/12/check-for-updates-in-raspbian/

. funktioner.sh

# Uppdatera paketlistor och läs utdata
sudo apt-get update 2>&1 # > /dev/null
output=$(sudo apt -s dist-upgrade 2>&1)

# Beräkna antal uppdaterbara paket
updateable=$(echo "$output" | grep -E '^Inst ' | wc -l)

if [ $updateable -ne 0 ]; then

	# Skapa lista över uppdaterbara paket och avisera på telefon
	pkg=$(echo "$output" | grep -E '^Inst' | cut -d ' ' -f 2)
	newline=$'\n'
	push "${updateable} paket kan uppdateras${newline}${newline}${pkg}"

fi
