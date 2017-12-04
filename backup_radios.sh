#!/bin/bash
DATA=`date +%Y-%m-%d`
DIR="/tmp"
DIR_OUTPUT="/mnt/backup"
USER="ubnt"
PASS="ubnt"

for device in $(cat ${DIR}/devices.txt);
do
  sshpass -p "${PASS}" ssh $device -l "${USER}" \
    -oStrictHostKeyChecking=no -oCheckHostIP=no \
    -oConnectTimeout=10  \
    "shell
     cat /tmp/system.cfg" < /dev/null | tee "${DIR_OUTPUT}backup-radio-$DATA-${device}.cfg" > /dev/null
    # StrictHostKeyChecking=no => ignora checagem de chaves
    # CheckHostIP              => ignora checagem de host/ip
    # ConnectTimeout           => tempo limite de espera para conectar
  echo "FINALIZADO O $device as `date +%d-%m-%Y-%H:%M:%S`"  >> /var/log/backup_radios-$DATA.log

done
