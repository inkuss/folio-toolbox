#!/bin/bash
# Kuss, 17.08.2020
# Aufruf z.B.: ./ks.putInstance.sh instance/PUT_InstanceSample.json
OKAPI=https://folio-demo.hbz-nrw.de/okapi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -H "Accept: application/json" -d '{"tenant":"diku","username":"diku_admin","password":"admin"}' $OKAPI/authn/login | grep -i "^x-okapi-token: " )
# echo "TOKEN=$TOKEN"
instanceDatei=$1
echo "instanceDatei=$instanceDatei"
instanceId=$2
echo "instanceId=$instanceId"
curl -s -S -D - -X PUT -H "$TOKEN" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json; charset=utf-8" -H "Accept: application/json" -d \@$instanceDatei $OKAPI/inventory/instances/$instanceId
