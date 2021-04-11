#!/bin/bash

. functions.sh 
. secrets > /dev/null 2>&1

if [[ $(internet) == "off" ]]; then exit; fi

trap 'push "$(basename $0) stötte på fel"' err

newline=$'\n'
log_dir="/home/antsva/log/bot-metal"

signal_cli="$HOME/bin/signal-cli/bin/signal-cli"
$signal_cli receive > /dev/null 2>&1

signal_from="$phone_number"
signal_group="$($signal_cli listGroups | awk '/Autistic/{print $2}')"

if [[ -n $signal_group ]]; then
	signal_to="$signal_group"
else
	signal_to="$phone_number"
fi

# Function to send message through pipe, preserving line breaks
signal_send() {
	if [[ $signal_to == $phone_number ]]; then
		$signal_cli -u "$signal_from" send "$signal_to" # To contact
	else
		$signal_cli -u "$signal_from" send -g "$signal_to" # To group
	fi
}

if [[ ! -d "$log_dir" ]]; then
	mkdir -p "$log_dir"
fi

read -d '' artists << EOF || true
Allen Lande=1751194
Arch Echo=6290096
Ayreon=263989
Devin Townsend=251249
Devin Townsend Band=1441645
DGM=1940603
Dream Theater=260935
Haken=2481019
Leprous=1927912
Liquid Tension Experiment=94846
Meshuggah=252273
Michael Romeo=333536
Opeth=245797
Pain of Salvation=388262
Plini=3511496
Symphony X=291495
Thomas Bergersen=782590
EOF

echo "$artists" | while read line; do

	artist=$(echo "$line" | cut -d= -f1)
	artist_id=$(echo "$line" | cut -d= -f2)

	log="$log_dir"/"$artist".log

	release_json=$(curl -s "https://api.discogs.com/artists/"$artist_id"/releases?sort=year&sort_order=desc&page=1&per_page=1" --user-agent "FooBarApp/3.0" | jq -r '.releases[0]')
	release_title_year="$(echo "$release_json" | jq '.title') ($(echo "$release_json" | jq '.year'))"

	# Bail out to next artist on API error
	if [[ -z "$release_title_year" || "$release_title_year" == *null* ]]; then continue; fi 

	if [[ -f "$log" && "$release_title_year" != $(cat "$log") ]]; then
		msg_newrelease="Nytt släpp av $artist: $release_title_year.${newline}${newline}/Antons hårdrocksbot (https://git.io/JOkwF)"

		push "$msg_newrelease" # In case signal-cli fails
		echo -e "$msg_newrelease" | signal_send
	fi

	echo "$release_title_year" > "$log"

done
