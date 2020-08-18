#!/bin/bash
OKAPI=https://folio-demo.hbz-nrw.de/okapi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -H "Accept: application/json" -d '{"tenant":"diku","username":"diku_admin","password":"admin"}' $OKAPI/authn/login | grep -i "^x-okapi-token: " )
instanceId="4777a233-2ed4-4c37-813b-a2203f46d49e"
instanceId="d576590c-d537-42c5-a4f4-93a73531b7bd"
instanceId="1f616ead-5c30-4eba-a10d-104e94e89e43"
outdatei="instance/"$instanceId".json"
echo "outdatei=$outdatei"
curl -s -S -D - -X GET -H "$TOKEN" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" $OKAPI/inventory/instances/$instanceId > $outdatei

