#!/bin/bash
# Legt "Check"-Skripte für die Überwachung der Folio-Modulcontainer mit monit an
# - für aktuell in ~/platform-complete ausgeliehenes und installiertes Release
# - Legt Check-Skripte für alle Module des Releases an.
# - für Single Server (alle Module laufen nur jeweils einmal und im gleichen Docker-Netzwerk)
# - momit: https://mmonit.com/monit/
# I. Kuss, 19.02.2021
# Aufruf: sudo ./$0
 
prgname=$0
echo "HOME=$HOME"
set -- `id`
if [[ ! $1 =~ \(root\)$ ]]; then
  echo "ERROR: root-Berechtigung erforderlich ! Bitte das Programm so aufrufen: sudo $prgname"
  exit 0
fi
# Ein neues Unterverzeichnis für die Check-Skripte anlegen:
datetimestamp=`date "+%Y%m%d%H%M%S"`
scriptverz=/etc/monit/scripts/scripts.$datetimestamp
origuser=`logname`
origgroup=`id -gn $origuser`
install -o $origuser -g $origgroup -m u=rwx,g=rwx,o=rx -d $scriptverz
if [ $? -ne 0 ] ; then
    echo "ERROR: Konnte Skript-Verzeichnis ($scriptverz) nicht anlegen !"
    exit 1;
else
    echo "INFO: Neues monit-Skriptverzeichnis angelegt: $scriptverz"
fi
# Ein neues Unterverzeichnis auch für die Monit-Includes anlegen:
monitincludeverz=/etc/monit/conf.d/deploy.$datetimestamp
install -o $origuser -g $origgroup -m u=rwx,g=rwx,o=rx -d $monitincludeverz
if [ $? -ne 0 ] ; then
    echo "ERROR: Konnte Monit-Inlcude-Verzeichnis ($monitincludeverz) nicht anlegen !"
    exit 1;
else
    echo "INFO: Neues Monit-Include-Verzeichnis angelegt: $monitincludeverz"
fi
# Gehe alle installierten Module in einer while-Schleife durch:
cd $HOME/platform-complete
grep "\"id\":" okapi-install.json | while read -r line
do
  # echo "Zeile: $line"
  # Zeile ist z.B.: "id": "mod-user-import-3.3.0",
  # Extrahiere Modulnamen und Versionsbezeichnung:
  modul_version=`echo $line | sed 's/\"id\": \"//'`
  # echo "modul_version=$modul_version"
  modulname=`echo $modul_version | sed 's/\-[0-9].*$//'`
  version=`echo $modul_version | sed 's/^.*\-\([0-9].*\)",$/\1/'`
  # echo "modulname=$modulname"
  # echo "version=$version"
  if [[ ! $modulname =~ ^[a-z\-]+$ ]] ; then
    echo "WARN: ungültiger Modulname : $modulname"
    continue
  fi
  if [[ ! $version =~ ^[0-9\.]+$ ]] ; then
    echo "WARN: ungültige Versionsnummer : $version"
    continue
  fi
  # Finde die Container-ID(s) zu dem Modul
  dockerps=`docker ps | grep $modulname:$version`
  set -- $dockerps
  if [[ ! $1 ]]; then
    echo "WARN: Modul $modulname in Version $version nicht in Docker-Prozessliste gefunden !"
    echo "WARN: Modul $modulname:$version wird nicht in die Überwachung aufgenommen !!"
    continue
  fi
  containerid=$1
  echo "SUCCESS: Container-ID ($containerid) für Modul:Version $modulname:$version gefunden."
  # 1. Ein Skript chk_container_<modulname>-<version>.sh im Skript-Verzeichnis anlegen:
  chkscript=$scriptverz/chk_container_$modulname-$version.sh
  echo "#!/bin/bash
HOME=/root
docker top $containerid
exit \$?" > $chkscript
  chmod 775 $chkscript
  chown $origuser:$origgroup $chkscript
  # 2. Start-Stop-Anweisungen (=Monit-Includes) in /etc/monit/conf.d/deploy.<Zeitstempel> erzeugen:
  includestrecke=$monitincludeverz/chk_container_$modulname:$version
  echo "CHECK PROGRAM $modulname-$version WITH PATH $chkscript
  START PROGRAM = \"/usr/bin/docker start $containerid\"
  STOP PROGRAM = \"/usr/bin/docker stop $containerid\"
  IF status != 0 FOR 2 CYCLES THEN RESTART
  IF 3 RESTARTS WITHIN 10 CYCLES THEN UNMONITOR" > $includestrecke
  chmod 664 $includestrecke
  chown $origuser:$origgroup $includestrecke
done
echo "SUCCESS: Check-Skripte für Container im Skriptverzeichnis ($scriptverz) angelegt."
echo "SUCCESS: Monit-Includes im Verzeichnis ($monitincludeverz) angelegt."
echo "INFO: Nun bitte manuell in /etc/monit/monitrc das neue Inklude-Verzeichnis inkludieren: include $monitincludeverz/*"
echo "INFO: Nicht mehr benötigte include-Anweisungen in monitrc bitte löschen."
echo "INFO: Anschließend monit durchstarten: systemctl restart monit"
echo "SUCCESS: Programm $prgname erfolgreich durchgelaufen. Programm beendet sich."
exit 0
