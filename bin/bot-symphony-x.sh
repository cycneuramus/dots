#!/bin/bash

. funktioner.sh
. secrets 

if [[ $(internet) != "på" ]]; then exit; fi

signal_cli=./signal-cli/bin/signal-cli
log=/home/antsva/log/bot-symphony-x.log
signal_from=$phone_number
# signal_to="QOgFNC7FaLrIamemZ7t2Hw==" # Autistic Boys
signal_to="$phone_number"

# Definierar funktion för att skicka meddelandet genom pipe och därmed få med radbrytningar
signal_send() {
    $signal_cli -u $signal_from send $signal_to # Till kontakt
    # $signal_cli -u $signal_from send -g $signal_to # Till grupp
}

# TODO multi-artist
# artists="devin devinband dreamtheater leprous lte symphonyx"
# 
# for artist in $artists; do
# 	log=/home/antsva/log/bot-metal/$artist.log
# 	if [[ $artist == "leprous" ]]; then
# 		artist_id="1927912"
# 	elif [[ $artist == "dreamtheater" ]]; then
# 		artist_id="260935"
# 	elif [[ $artist == "devin" ]]; then
# 		artist_id="251249"
# 	elif [[ $artist == "devinband" ]]; then
# 		artist_id="1441645"
# 	elif [[ $artist == "lte" ]]; then
# 		artist_id="94846"
# 	elif [[ $artist == "symphonyx" ]]; then
# 		artist_id="291495"
# 	fi	
# done

release_json=$(curl "https://api.discogs.com/artists/291495/releases?sort=year&sort_order=desc&page=1&per_page=1" --user-agent "FooBarApp/3.0" | jq -r '.releases[0]')
release_title_year="$(echo "$release_json" | jq '.title') ($(echo "$release_json" | jq '.year'))"

newline=$'\n'
msg_init="Initierar bot för avisering vid nytt material från Symphony X. Senaste släpp: $release_title_year.${newline}${newline}[Detta är ett automatiserat meddelande.]"
msg_newrelease="Nytt släpp av Symphony X: $release_title_year.${newline}${newline}[Detta är ett automatiserat meddelande.]"

if [[ ! -f $log ]]; then
    push "$msg_init" # Ifall signal-cli inte fungerar
    echo -e "$msg_init" | signal_send
elif [[ $release_title_year != $(cat $log) ]]; then
    push "$msg_newrelease" # Ifall signal-cli inte fungerar
    echo -e "$msg_newrelease" | signal_send
fi

echo $release_title_year > $log
