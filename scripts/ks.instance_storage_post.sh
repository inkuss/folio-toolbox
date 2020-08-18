#!/bin/bash
INSTANCE_FILE=sample_instance.json
OKAPI=https://folio-demo.hbz-nrw.de/okapi
TOKEN=$( curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -H "Accept: application/json" -d '{"tenant":"diku","username":"diku_admin","password":"admin"}' $OKAPI/authn/login | grep -i "^x-okapi-token: " )
curl -s -S -D - -H "$TOKEN" -H "X-Okapi-Tenant: diku" -H "Content-type: application/json" -H "Accept: text/plain" -d \@$INSTANCE_FILE $OKAPI/instance-storage/instances
