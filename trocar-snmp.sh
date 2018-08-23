#!/bin/bash


PASS=`cat /root/pf`
PORT=22
DATE=`date +%Y%m%d`

mkdir /home/mikrotik/$DATE

for IP in `cat rb-list`; do

        sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -p $PORT -l backup $IP '/export'   

done

