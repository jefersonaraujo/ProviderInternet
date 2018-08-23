#!/bin/bash


PASS=`cat /root/pf`
PORT=22
DATE=`date +%Y%m%d`

for IP in `cat rb-list`; do

        sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -p $PORT -l backup $IP 'snmp community set public  addresses=192.168.X.X'   

done

