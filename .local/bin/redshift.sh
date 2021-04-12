#!/bin/bash

. $BIN/functions.sh

until [[ $(internet) == "on" ]]; do
	sleep 5
	(( count++ ))
	if (( $count > 10 )); then break; fi
done

if [[ $(internet) == "on" ]]; then 
	rs on
fi
