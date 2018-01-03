#!/bin/bash

#=======================================================================#
## Script para Backups de Radios Ubiquiti e intelbras.
## Jeferson Araujo
## E-mail: jefeersonarauj95@gmail.com
## Adaptado atraves do Merge da Versão de Joabe Guimarães.
##

#=======================================================================#
#=========== CONFIGURACAO GLOBAL DE ACESSO SSH DOS RADIOS ==============#
DATA=`date +%d-%m-%Y`
DIR="/tmp"
DIR_OUTPUT="/mnt/backup"
USER="ubnt"
PASS="ubnt"

#============== COMANDO DE CONFIGURACAO ===========#
comando="cat /tmp/system.cfg"
online="${DIR}/Radios_online.txt"
offline="${DIR}/Radios_offline.txt"
qtdOn=$(cat $online | wc -l)
qtdOff=$(cat $offline | wc -l)
vaziosBkp=$(find $DIR_OUTPUT/$DATA  -type f -empty | cut -d "-" -f8)
vaziosQtd=$(find $DIR_OUTPUT/$DATA -type f -empty| cut -d "-" -f6 | wc -l)
mkdir -p $DIR_OUTPUT/$DATA
#limpar Arqvuivos
> $online
> $offline

#============== CHECAGEM DE ATIVOS ===========#

for apc in $(cat ${DIR}/devices.txt);do
        ping -q -c2 $apc > /dev/null

if [ $? -eq 0 ]
        then
        echo $apc "Online"
        echo $apc >>  $online
else
        echo $apc "Offline"
        echo $apc >> $offline
fi
done


#============== REALIZAR BACKUPS DE ATIVOS (UBIQUITI E INTELBRAS) ===========#

for device in $(cat $online );
do
  sshpass -p "${PASS}" ssh $device -l "${USER}" \
    -oStrictHostKeyChecking=no -oCheckHostIP=no \
    -oConnectTimeout=10  \
    "cat /tmp/system.cfg" < /dev/null | tee "${DIR_OUTPUT}/$DATA/backup-radio-$DATA-${device}.cfg" > /dev/null
    # StrictHostKeyChecking=no => ignora checagem de chaves
    # CheckHostIP              => ignora checagem de host/ip
    # ConnectTimeout           => tempo limite de espera para conectar
  echo "FINALIZADO O $device as `date +%d-%m-%Y-%H:%M:%S`"  >> /var/log/backup_radios-$DATA.log

done

#============== RELATORIOS (UBIQUITI E INTELBRAS) ===========#
echo "#====================== RELATORIO DO BACKUP ======================#" > ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "QUANTIDADE DE RADIOS ONLINE : $qtdOn" >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "QUANTIDADE DE RADIOS OFFLINE : $qtdOff " >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "QUANTIDADE DE RADIOS BACKUP VAZIO : $vaziosQtd " >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "LISTA DE RADIOS ONLINE :" >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
cat $online >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "LISTA DE RADIOS OFFLINE :" >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
cat $offline >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "LISTA DE RADIOS BACKUP VAZIOS :" >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo $vaziosBkp >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt
echo "#====================== FIM RELATORIO DO BACKUP ======================#" >> ${DIR_OUTPUT}/$DATA/RELATORIO.txt

#============== REMOVE OS VAZIOS ===========#
find $DIR_OUTPUT/$DATA -type f -empty | xargs rm
