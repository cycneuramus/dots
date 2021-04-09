#!/bin/bash

. functions.sh

if [[ $(internet) == "off" ]]; then exit; fi

trap 'push "$(basename $0) stötte på fel"' err

log=/home/antsva/log/signal-cli-update.log
latest_release=$(curl --silent "https://api.github.com/repos/AsamK/signal-cli/releases/latest" | jq -r .tag_name)

if [[ -f $log && $latest_release != $(cat $log) ]]; then

	cd $HOME/bin
	wget -c $(curl --silent "https://api.github.com/repos/AsamK/signal-cli/releases/latest" | jq -r '.assets[0].browser_download_url')
	signal_new_tar=$(ls signal*.tar.gz)
	tar xf $signal_new_tar
	rm $signal_new_tar

	signal_new_folder=${signal_new_tar%.tar.gz} 
	if [[ -d signal-cli ]]; then rm -r signal-cli/; fi 
	mv $signal_new_folder signal-cli/

	push "signal-cli har uppdaterats till $latest_release"

fi

echo $latest_release > $log

