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
pass_find=0
user_find=0
DIR="/tmp"
#=======================================================================#
for i in $(cat radios.txt); do
	pass_find=0
	for senha in $(cat ${DIR}/pass.txt); do
		case "$pass_find" in
			"0")if(sshpass -p $senha ssh $i -l admin -o StrictHostKeyChecking=no -oCheckHostIP=no \
			"exit")
			then
				pass_find=1;
				echo -ne "Tarefa concluida ip $i senha $senha.\r\n" >> /var/log/log_sucesso_snmp.$hoje.log
			else
				echo -ne "Tarefa não concluida  ip $i $senha \r\n" >> /var/log/log_erro_snmp.$hoje.log
				pass_find=0;
			fi
			;;
		esac
	done
done
