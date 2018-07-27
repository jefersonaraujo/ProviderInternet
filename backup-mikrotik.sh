#!/bin/bash


PASS=`minhasena`
PORT=22
DATE=`date +%Y%m%d`

#local onde vai salvar
mkdir -p /home/mikrotik/$DATE

#precisa instalar o sshpass. 
for IP in `cat /tmp/rb-list`; do

        sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -p $PORT -l backup $IP '/export' > /home/mikrotik/$DATE/bkp-$IP.rsc
done
