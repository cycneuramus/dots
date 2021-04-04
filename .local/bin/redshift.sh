#!/bin/bash

. $BIN/functions.sh

until [[ $(internet) == "on" ]]; do
	sleep 5
	count=$(($count + 1))
	if (( $count > 10 )); then break; fi
done
rs on
