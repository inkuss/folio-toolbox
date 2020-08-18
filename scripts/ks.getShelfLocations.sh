#!/bin/bash
# Listet Identifikatorentypen auf
OKAPI=https://folio-demo.hbz-nrw.de/okapi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -H "Accept: application/json" -d '{"tenant":"diku","username":"diku_admin","password":"admin"}' $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl -s -S -D - -X GET -H "$TOKEN" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" $OKAPI/shelf-locations

