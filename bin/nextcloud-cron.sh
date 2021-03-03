#!/bin/bash

# Förstagångsgenerering av bildförhandsgranskningar
# docker exec -u www-data nextcloud-app php occ preview:generate-all -vvv

# Nyheter
docker exec -u www-data nextcloud-app php -f /var/www/html/cron.php

# Bildförhandsgranskningar
# docker exec -u www-data nextcloud-app php occ preview:pre-generate
