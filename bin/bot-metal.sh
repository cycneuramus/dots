#!/bin/bash

. funktioner.sh
. secrets 

if [[ $(internet) != "på" ]]; then exit; fi

signal_cli="./signal-cli/bin/signal-cli"
log_dir="/home/antsva/log/bot-metal"
signal_from="$phone_number"
# signal_to="$(signal-cli listGroups | awk '/Autistic/{print $2}')"
signal_to="$phone_number"

# Definierar funktion för att skicka meddelandet genom pipe och därmed få med radbrytningar
signal_send() {
    $signal_cli -u "$signal_from" send "$signal_to" # Till kontakt
    # $signal_cli -u "$signal_from" send -g "$signal_to" # Till grupp
}


if [[ ! -d "$log_dir" ]]; then
	mkdir -p "$log_dir"
fi

newline=$'\n'

while read artist; do
	log="$log_dir"/"$artist".log

	case "$artist" in
		"Arch Echo")
			artist_id="6290096"
			;;
		"Ayreon")
			artist_id="263989"
			;;
		"Devin Townsend")
			artist_id="251249"
			;;
		"Devin Townsend Band")
			artist_id="1441645"
			;;
		"DGM")
			artist_id="1940603"
			;;
		"Dream Theater")
			artist_id="260935"
			;;
		"Haken")
			artist_id="2481019"
			;;
		"Leprous")
			artist_id="1927912"
			;;
		"Liquid Tension Experiment")
			artist_id="94846"
			;;
		"Michael Romeo")
			artist_id="333536"
			;;
		"Opeth")
			artist_id="245797"
			;;
		"Pain of Salvation")
			artist_id="388262"
			;;
		"Plini")
			artist_id="3511496"
			;;
		"Symphony X")
			artist_id="291495"
			;;
		"Thomas Bergersen")
			artist_id="782590"
			;;
		esac

	release_json=$(curl -s "https://api.discogs.com/artists/"$artist_id"/releases?sort=year&sort_order=desc&page=1&per_page=1" --user-agent "FooBarApp/3.0" | jq -r '.releases[0]')
	release_title_year="$(echo "$release_json" | jq '.title') ($(echo "$release_json" | jq '.year'))"

	if [[ -f "$log" && "$release_title_year" != $(cat "$log") ]]; then
		msg_newrelease="Nytt släpp av $artist: $release_title_year.${newline}${newline}/Antons hårdrocksbot"

		push "$msg_newrelease" # Ifall signal-cli inte fungerar
		echo -e "$msg_newrelease" | signal_send
	fi

	echo "$release_title_year" > "$log"
done < $HOME/bin/artists
