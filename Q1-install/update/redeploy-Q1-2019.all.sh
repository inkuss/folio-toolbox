#!/bin/sh -- die Schritte sind aber einzeln von Hand auszuführen !
# Diese Anleitung beschreibt eine komplette Neuaufstellung (Re-Deploy) des FOLIO-Systems,
#   mit Aktualisieren und Neu-Bau der Sourcen, Verwendung aktueller Container, jedoch ohne den gesamten Server neu aufzusetzen.
# Es wird davon ausgegangen, dass man sich bereits auf einem (evtl. virtuellen) Server mit einer Komplettinstallation (eines älteren Releases) befindet.
# Diese Anleitung beschreibt, wie man mit minimalem Aufwand von dem alten Release zu Q1-2019 kommt.
# Hier (hbz): Q4-2018 (platform-complete) auf VM mit SLES 12.3 installiert. 15 GB RAM.
#       Als Webserver wird ngnix benutzt.
#       Keine Verwendung von Vagrant.
# Installationsanleitung für Neuinstallation:  https://github.com/folio-org/folio-install/blob/master/single-server.md

#  Neueste Sourcen - oder stabiles Release - von folio-install holen (enthält Installationsskripte (Perl), Beispieldaten):
  cd ~/folio-install
  git fetch
  # * [neuer Branch]    q1-2019      -> origin/q1-2019
  LATEST=$(git describe --tags `git rev-list --tags --max-count=1`); echo $LATEST # q1-2019-2
  git checkout $LATEST

  # Entferne "alten Zustand" der Datenbank "folio"
  # 1. Deaktiviere die Module für diesen Mandanten
  # Hole die Liste der Module für diesen Mandanten
  curl -w '\n' -XGET http://localhost:9130/_/proxy/tenants/diku/modules
  # Sende LÖSCHEN an  /_/proxy/tenants/<tenantId>/modules/<moduleId> für jedes Modul in der Liste,
  # aber lasse Okapi aktiviert !
  # Lösche die Module, wie sie im o.g. curl auftauchen.
  # Schreibe die Module in dieser Reihenfolge in ein Skript ks.disableModules.sh und führe das Skript aus:
  curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/folio_calendar-1.0.100018
  curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/folio_checkin-1.1.100049
  curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/folio_checkout-1.1.4000158
  ...
  cd ~/update
  ./ks.disableModules.sh
  # Aufgrund "fehlender Anhängigkeiten" werden nicht alle Module gelöscht.
  # Lasse dir erneut alle Module auflisten:
  curl -w '\n' -XGET http://localhost:9130/_/proxy/tenants/diku/modules
  # und sende DELETE an diese Module. Sammle die curl-DELETE-Befehle in einem zweiten Skript:
  ./ks.disableModules_2ndrun.sh
  # mod-configuration-5.0.1 muss noch einzeln gelöscht werden:
  curl -w '\n' -XDELETE http://localhost:9130/_/proxy/tenants/diku/modules/mod-configuration-5.0.1
  # Am Ende:
  curl -w '\n' -XGET http://localhost:9130/_/proxy/tenants/diku/modules
  [ {
    "id" : "okapi-2.25.0"
    } ]

  # 2. Alle Container zurückziehen (undeploy)
  cd ~/update/
  ./ks.undeployModules.sh
  # wird jeweils mit "HTTP/1.1 204 No Content" quittiert.

  # 3. Lösche die "folio" Datenbank (drop) und lege sie neu an (Annahme: es ist eine andere Datenbank als die, die du als Okapi-Speicher benutzt)
  psql -U folio
  Passwort: folio123
  \c postgres;
  drop database folio;
  # lasse Dir alle Rollen anzeigen:
  # \du
  # nun lasse alle Rollen fallen, AUßER: folio, okapi, postgres; Also nur Rollen für den Mandanten diku.
  cd ~/update; sudo su; ./cc.deleteSchemasAndRoles.sh
  # "Tenant Id" : diku
  # Warnungen ignorieren ("DROP: Befehl nicht gefunden"); hinterher dürfen nur noch folio, okapi, postgres als Rollen drin stehen:
  # \du

  # 3.2 Erzeuge Datenbank und Rollen
  CREATE DATABASE folio WITH OWNER folio;
  \q 
 
  # i) Baue die neueste Freigabe der FOLIO Stripes Plattform
  # Move to NodeJS LTS
  sudo n lts
  # Klone das Repositorium platform-complete, wechsle in das Verzeichnis
  # git clone https://github.com/folio-org/platform-complete
  cd ~/platform-complete
  git fetch
  # * [neuer Branch]    q1-2019                        -> origin/q1-2019
  # Leihe den Zweig q1-2019 aus.
  git checkout q1-2019
  git pull
  # letzter Commit ist vom 12. April 2019
  # Installiere npm-Pakete
  sudo su
  yarn install
  # (das verändert die stripes.config.js)
  # Ändere jeweils eine Zeile in 
  vim ./stripes.config.js
  vim ./node_modules/@folio/stripes-cli/resources/platform/stripes.config.js
  => okapi: { 'url':'https://folio-demo.hbz-nrw.de/okapi', 'tenant':'diku' },

  NODE_ENV=production yarn build output   # das dauert etwas

  # Neustart nginx:
  # Konfiguration von nginx ist bereits erfolgt; siehe /etc/nginx/nginx.conf
  /usr/sbin/nginx -s stop
  # etwas warten
  /usr/sbin/nginx

  # ii) Aktualisiere Okapi
  cd ~/okapi
  git fetch
  #  * [neues Tag]         v2.27.0    -> v2.27.0
  # lokale Änderungen irgendwo wegspeichern => Nur wenn man welche gemacht hat (z.B. Log-Konfigurationen oder sogar Eigenentwicklungen) (habe ich nicht)
  git checkout v2.27.0
  vim dist/okapi.conf
  # Folgende Einstellungen überprüfen:
  # Eigene IP verwenden !!
      role="dev"
      port_start="9131"
      port_end="9230"
      host="193.30.112.62" # hier die eigene IP-Adresse des Servers verwenden !
      storage="postgres"
      okapiurl="http://193.30.112.62:9130"
      log4j_config="/usr/folio/okapi/dist/log4j.properties" # Hier evtl. eigene Logging-Konfiguration verwenden
  mvn clean install  # dauert 'ne Weile
  # okapi-core-fat.jar muss neu gebaut worden sein (dies prüfen):
  ls -l okapi-core/target/okapi-core-fat.jar
  
  # I. Neustart Okapi Server (das entfernt alle für den Mandanten bereitgestellten Module)
  ps -eaf | grep okapi
  kill <Okapi-PID>
  java -Djava.awt.headless=true -Dport_end=9230 -Dhost=193.30.112.62  -Dokapiurl=http://193.30.112.62:9130 -Dstorage=postgres -jar /usr/folio/okapi/okapi-core/target/okapi-core-fat.jar dev ## jeweils eigene IP verwenden !!
  ctrl-Z; bg
  # überprüfe in /var/log/folio/okapi/okapi.conf: "Deploy completed succesfully"

  # Ziehe Moduldeskriptoren aus dem zentralen Repositorium (das dauert eine Weile)
  # Das speichert die Modul-Deskriptoren im Okapi-Speicher, also in der PostgreSQL-Datenbank. 
  cd ~/okapi
  # folio@folio-demo:~/okapi> cat okapi-pull.json
  #   { "urls": [ "http://folio-registry.aws.indexdata.com" ] }
  curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @okapi-pull.json http://localhost:9130/_/proxy/pull/modules
  # schließlich :
  # 16:53:34 INFO  ProxyContext         305375/proxy RES 200 47594282us okapi-2.25.0 /_/proxy/pull/modules


  # iii) Erneute Bereitstellung (Re-Deploy) aller kompatiblen FOLIO Backend-Module, Aktivierung für den Mandanten
  #
  # II. Docker-Neustart um Ports freizugeben
  systemctl stop docker.service
  #  Das gibt die Ports 9131-9147 frei.
  systemctl start docker.service

  # 1. Melde Informationen über die Datenquellen an die Okapi-Umgebung. Werden von den bereitgestellten Modulen benutzt.
  # Muss man das noch einmal machen ? Ja, weil Datenbank "folio" gelöscht wurde.
  # Eigene IP benutzen !
  curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_HOST\",\"value\":\"193.30.112.62\"}" http://localhost:9130/_/env;
  curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_PORT\",\"value\":\"5432\"}" http://localhost:9130/_/env;
  curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_DATABASE\",\"value\":\"folio\"}" http://localhost:9130/_/env;
  curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_USERNAME\",\"value\":\"folio\"}" http://localhost:9130/_/env;
  curl -w '\n' -D - -X POST -H "Content-Type: application/json" -d "{\"name\":\"DB_PASSWORD\",\"value\":\"folio123\"}" http://localhost:9130/_/env;

  # 2. Melde die Liste der Backend-Module, um sie bereitzustellen und zu aktivieren
  # Das zieht auch die Docker-Abbilder von folioci
  # Bemerkung: Es läuft sehr lange, denn alle Docker-Abbilder müssen vom Docker-Hub gezogen werden. Du kannst den Fortschritt im Okapi-Log verfolgen, bei /var/log/folio/okapi/okapi.log
  cd ~
  curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @platform-complete/okapi-install.json http://localhost:9130/_/proxy/tenants/diku/install?deploy=true\&preRelease=false
HTTP/1.1 100 Continue
  START Do 18. Apr 17:27:17 CEST 2019
  ENDE  Do 18. Apr 17:37    CEST 2019

HTTP/1.1 200 OK
  # 44 Backend-Module (mod*) aktiviert und bereitgestellt.


  # 3. Melde die Liste der "Stripes"-Module, um sie zu aktivieren
  cd ~
  curl -w '\n' -D - -X POST -H "Content-type: application/json" -d @platform-complete/stripes-install.json http://localhost:9130/_/proxy/tenants/diku/install?preRelease=false
HTTP/1.1 100 Continue

HTTP/1.1 200 OK
  -> 32 vorgeschaltete Module (Frontend, UI) (folio*) aktiviert und bereitgestellt.

  # Module auflisten lassen:
  curl -w '\n' -D - http://localhost:9130/_/discovery/modules | grep srvcId
  #  => die 44 Backend-Module. Dazu gibt es 32 Frontend-Module und das Okapi-Modul

  # Erzeuge einen FOLIO "Superuser" und lege Berechtigungen an
  # **************************************************************
  cd ~/folio-install
  perl bootstrap-superuser.pl --tenant diku --user diku_admin --password admin --okapi http://localhost:9130
...
done!


  # Lade zu den Modulen gehörende Referenzdaten
  # *******************************************
  # neu in Q1-2019: Referenzdaten werden nicht mehr benötigt. 
  # Das (Laden der Referenzdaten) wird nun gemacht, wenn die entsprechenden Backend-Module für den Mandanten (tenant) initialisiert werden. Siehe dazu die Jira Issues FOLIO-1866 und RMB-329.


  # Lade Beispieldaten
  # *******************
  # Neu in Q1-2019: Einige Beispieldaten werden geladen, wenn die entsprechenden Backend-Module für den Mandanten (tenant) initialisiert werden.
  # Andere Beispieldaten lädt man vom Verzeichnis sample-data von platform-complete so:
  cd ~/folio-install
  perl load-data.pl --sort fiscal_year,ledger,fund,budget  sample-data

  # Lade MODS-Datensätze
  # Hole ein Okapi-Token -- das ist dann in der Kopfzeile "x-okapi-token"
  curl -w '\n' -D - -X POST -H "Content-type: application/json" -H "Accept: application/json" -H "X-Okapi-Tenant: diku" -d '{"username":"diku_admin","password":"admin"}' http://localhost:9130/authn/login
  TOKEN=...

  # Melde die Dateien in sample-data/mod-inventory an
  for i in ~/folio-install/sample-data/mod-inventory/*.xml; do curl -w '\n' -D - -X POST -H "Content-type: multipart/form-data" -H "X-Okapi-Tenant: diku" -H "X-Okapi-Token: $TOKEN" -F upload=@${i} http://localhost:9130/inventory/ingest/mods; done

  # *** FERTIG ***
  # Log in als "diku_admin:admin" auf https://folio-demo.hbz-nrw.de (bzw. jeweiliger eigener Server)
  # Funktioniert: 77 Module installiert. Siehe bei Apps - Einstellungen - Softwareversionen

  # Fehlt noch:
  # - Absicherung der Okapi-API
  # - Installation und Bedienung von "Edge"-Modulen
