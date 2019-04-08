# gem. Doku hier https://s3.amazonaws.com/foliodocs/api/mod-data-loader/loader.html

# MARCFILE=hbz01.w0001.wbb.sys.ok.z103.sys.first10.mrc
# MARCFILE=Atest.utf8.mrc
MARCFILE=2017-11-Business_Management_Economics_UTF8.mrc

# Host and port of the inventory storage module
# Port von mod-inventory-storage aus Modulliste heraus"greppen":
curl -w '\n' -D - https://folio-demo.hbz-nrw.de/okapi/_/discovery/modules | egrep "mod-inventory-storage|\"url\""

# falls FOLIO auf localhost läuft :
# storageURL=http://localhost:9136
# Zugriff von extern (Port 3000 wurde freigeschaltet und umgeleitet auf mod-inventory-storage :
storageURL=http://folio-demo.hbz-nrw.de:3000
curl -s -S -D - -H "X-Okapi-Tenant: diku" -H "Content-type: application/octet-stream" -H "Accept: text/plain" -d \@$MARCFILE http://localhost:8081/load/marc-data?storageURL=$storageURL\&storeSource=true

