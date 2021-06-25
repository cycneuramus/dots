#!/bin/bash
. secrets

TOKEN=$(curl -s -d "username=$librephotos_user&password=$librephotos_pass" -X POST $librephotos_server/api/auth/token/obtain/ | jq '.access' | tr -d '"')
curl -H 'Accept: application/json' -H "Authorization: Bearer ${TOKEN}" $librephotos_server/api/scanphotos
