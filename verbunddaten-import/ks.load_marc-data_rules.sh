# gem. Doku hier https://s3.amazonaws.com/foliodocs/api/mod-data-loader/loader.html
# 1. Rules-Datei laden
# hier ist eine von mod-data-loader mitgelieferte Rules-Datei für ein MARC-Mapping:
RULES=/usr/folio/additionalModules/mod-data-loader/src/test/resources/rules.json
curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/octet-stream" -H "Accept: text/plain" -d \@$RULES http://localhost:8081/load/marc-rules
