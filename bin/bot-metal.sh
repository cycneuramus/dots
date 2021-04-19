#!/bin/bash

. functions.sh 
. secrets > /dev/null 2>&1

if [[ $(internet) == "off" ]]; then exit; fi

trap 'push "$(basename $0) stötte på fel"' err

newline=$'\n'
log_dir="$HOME/log/bot-metal"

signal_cli="$HOME/bin/signal-cli/bin/signal-cli"

signal_from="$phone_number"
$signal_cli receive > /dev/null 2>&1
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
Adagio=1122446
Allen - Lande=1751194
Arch Echo=6290096
Ayreon=263989
Beast In Black=6051971
Blind Guardian=262577
Devin Townsend=251249
Devin Townsend Project=1441645
DGM=1940603
Dirty Loops=3707700
Dream Theater=260935
Freedom Call=423373
Frost*=722062
Haken=2481019
Leprous=1927912
Liquid Tension Experiment=94846
Meshuggah=252273
Michael Romeo=333536
Myrath=2060004
Opeth=245797
Pain Of Salvation=388262
Plini=3511496
Running Wild=271521
Star One=291519
Symphony X=291495
The Rippingtons=555275
Thomas Bergersen=782590
Twilight Force=3861827
Ulver=92973
Vince DiCola=99328
Wilderun=3824271
EOF

user_agent="$discogs_user_agent"
auth="Authorization: Discogs key=$discogs_key, secret=$discogs_secret"

echo "$artists" | while read line; do

	artist=$(echo "$line" | cut -d= -f1)
	artist_id=$(echo "$line" | cut -d= -f2)
	log="$log_dir"/"$artist".log

	url="https://api.discogs.com/artists/$artist_id/releases?sort=year&sort_order=desc&page=1"

	release_json=$(curl -s "$url" 					\
		--user-agent "$user_agent" 					\
		-H "$auth" 									\
		| jq ".releases[] 							\
		| select(.artist|test(\"$artist\"))" 		\
		| jq -s 'sort_by(.year) | last')

	release_title_year="$(echo "$release_json" 		\
		| jq '.title') ($(echo "$release_json" 		\
		| jq '.year'))"

	# Bail out to next artist on API error
	if [[ -z "$release_title_year" || "$release_title_year" == *null* ]]; then
		continue
	fi 

	if [[ -f "$log" && "$release_title_year" != $(cat "$log") ]]; then

		msg_newrelease="Nytt släpp av $artist: 			\
			$release_title_year.						\
			${newline}${newline}						\
			/Hårdrocksboten ( https://git.io/JOkwF )"

		push "$msg_newrelease" # In case signal-cli fails
		echo -e "$msg_newrelease" | signal_send

	fi

	echo "$release_title_year" > "$log"

done
