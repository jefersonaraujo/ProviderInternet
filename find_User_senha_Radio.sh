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
for i in $(cat ${DIR}/radios.txt); do
	pass_find=0
	user_find=0
	if [ "$pass_find" -eq 0 ] && [ "$user_find" -eq  0 ]; then
		for senha in $(cat ${DIR}/pass.txt); do
			for usuario in $(cat ${DIR}/users.txt); do
				if (sshpass -p $senha ssh $i -l $usuario -o StrictHostKeyChecking=no -oCheckHostIP=no \ "exit");	then
					pass_find=1;
					user_find=1;
					echo -ne "$i,$usuario,$senha\r\n" >> senha.txt
					break #finish loop user
				else
					echo -ne "Not Found $i \r\n" >> /var/log/find_pass.$hoje.log
				fi
			done #end users
		done #end pass
	fi
done
