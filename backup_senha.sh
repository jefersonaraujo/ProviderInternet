#!/bin/bash

#=======================================================================#
## Script para Senha de Radios Ubiquiti e intelbras.
## Jeferson Araujo
## E-mail: jefeersonarauj95@gmail.com
##
##

#=======================================================================#
#========================= CONFIGURACAO GLOBAL =========================#
hoje=$(date +"%d_%m_%Y")
DATA=`date +%d-%m-%Y`
pass_find=0
user_find=0
DIR="/tmp"
DIR_OUTPUT="/ARQUIVOS/RADIOS"
mkdir -p $DIR_OUTPUT/$DATA


#=======================================================================#
for i in $(cat ${DIR}/radios.txt); do
        pass_find=0
        user_find=0
        if [ "$pass_find" -eq 0 ] && [ "$user_find" -eq  0 ]; then
                for senha in $(cat ${DIR}/pass.txt); do
                        for usuario in $(cat ${DIR}/users.txt); do
                                if (sshpass -p $senha ssh -p9922 $i -l $usuario -o StrictHostKeyChecking=no -oCheckHostIP=no \ "exit");        then
                                        pass_find=1;
                                        user_find=1;
                                        echo -ne "$i,$usuario,$senha,22\r\n" >> senha.txt
                                        sshpass -p $senha ssh  $i -l $usuario \
                                        -o StrictHostKeyChecking=no -oCheckHostIP=no \
                                        -oConnectTimeout=10  \
                                        "cat /tmp/system.cfg" < /dev/null | tee "${DIR_OUTPUT}/$DATA/backup-radio-$DATA-${i}-porta-9922.cfg" > /dev/null
                                        # StrictHostKeyChecking=no => ignora checagem de chaves
                                        # CheckHostIP              => ignora checagem de host/ip
                                        # ConnectTimeout           => tempo limite de espera para conectar
                                        echo "FINALIZADO O $device as `date +%d-%m-%Y-%H:%M:%S`"  >> /var/log/backup_radios-$DATA.log
                                        break 2; #finish loop user
                                else
                                        echo -ne "Not Found $i \r\n" >> /var/log/find_pass.$hoje.log

                                fi
                        done #end users
                done #end pass
        fi
done
