#!/bin/bash
# I. Kuss, 17.08.2020
# Aufruf z.B.: ./ks.putHoldingsStorage instance/HoldingsSample.json <holdingsId>
OKAPI=https://folio-demo.hbz-nrw.de/okapi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -H "Accept: application/json" -d '{"tenant":"diku","username":"diku_admin","password":"admin"}' $OKAPI/authn/login | grep -i "^x-okapi-token: " )
# echo "TOKEN=$TOKEN"
holdingsDatei=$1
echo "holdingsDatei=$holdingsDatei"
holdingsId=$2
echo "holdingsId=$holdingsId"
curl -s -S -D - -X PUT -H "$TOKEN" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json; charset=utf-8" -H "Accept: text/plain" -d \@$holdingsDatei $OKAPI/holdings-storage/holdings/$holdingsId
