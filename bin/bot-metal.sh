#!/bin/bash

. functions.sh 
. secrets > /dev/null 2>&1

if [[ $(internet) == "off" ]]; then exit; fi

trap 'push "$(basename $0) stötte på fel"' err

log_dir="/home/antsva/log/bot-metal"
signal_cli="./signal-cli/bin/signal-cli"
signal_from="$phone_number"
# signal_to="$(signal-cli listGroups | awk '/Autistic/{print $2}')"
signal_to="$phone_number"
newline=$'\n'

# Definierar funktion för att skicka meddelandet genom pipe och därmed få med radbrytningar
signal_send() {
	$signal_cli -u "$signal_from" send "$signal_to" # Till kontakt
    # $signal_cli -u "$signal_from" send -g "$signal_to" # Till grupp
}

if [[ ! -d "$log_dir" ]]; then
	mkdir -p "$log_dir"
fi

while read line; do

	artist=$(echo "$line" | cut -d= -f1)
	artist_id=$(echo "$line" | cut -d= -f2)

	log="$log_dir"/"$artist".log

	release_json=$(curl -s "https://api.discogs.com/artists/"$artist_id"/releases?sort=year&sort_order=desc&page=1&per_page=1" --user-agent "FooBarApp/3.0" | jq -r '.releases[0]')
	release_title_year="$(echo "$release_json" | jq '.title') ($(echo "$release_json" | jq '.year'))"

	# Bail out to next artist on API error
	if [[ "$release_title_year" == *null* ]]; then continue; fi 

	if [[ -f "$log" && "$release_title_year" != $(cat "$log") ]]; then
		msg_newrelease="Nytt släpp av $artist: $release_title_year.${newline}${newline}/Antons hårdrocksbot"

		push "$msg_newrelease" # Ifall signal-cli inte fungerar
		echo -e "$msg_newrelease" | signal_send
	fi

	echo "$release_title_year" > "$log"

done < $HOME/bin/artists
