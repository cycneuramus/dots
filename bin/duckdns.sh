. secrets
. functions.sh

trap 'push "$(basename $0) stötte på fel"' err

echo url="https://www.duckdns.org/update?domains=antsva&token=$duckdns_token&ip=" | curl -k -o /home/antsva/log/duckdns.log -K -
