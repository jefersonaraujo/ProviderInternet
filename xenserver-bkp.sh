#!/bin/bash
# Script de backup das VM's Xen-Server (VM's a QUENTE)
####################################################################################
# Criado por: Rafael Oliveira #
# Fone:(27) 99981-4409 #
# e-mail: faelolivei@gmail.com #
####################################################################################
 
# Variaveis ########################################################################
storagebkp="9aee4ad3-9db2-315b-1bc6-401fea6ba74a" # Seu Storage.
dataarq=`date +%d-%m-%Y` # data para numenclatura do arquivo de log.
datain2=`date +%s` # data usada para subtracao de tempo final da execução do script
bkpdestino=/mnt/backup/bkpvms # Caminho para armazenamento do backup
 
# Cria o diretorio que armazena o log caso não exista ##############################
if test -d /var/log/backup/vms; then echo ""; else mkdir -p /var/log/backup/vms; fi;
 
# Definicao de array ###############################################################
echo "==============================================================================" > /var/log/backup/vms/bkpvms-${dataarq}.log
arrayvms=(Ubuntu1 Ubuntu2 WinServer2008R2)
echo "Servidores a serem backupeados: ${arrayvms[*]}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
 
# For de backup ####################################################################
for vmname in ${arrayvms[*]}
do {
dhvm=`date +%d-%m-%Y_%H-%M-%S` # data completa de informacao de cada etapa.
datain=`date +%s` # data usada para subtracao de tempo de cada vm.
sleep 60 # Aguarda 1 minuto antes de iniciar o bkp.
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "Iniciando backup da vm ${vmname} em ${dhvm}" >> /var/log/backup/vms/bkpvms-${dataarq}.log
data=`date +%c` # Data e hora atual.
echo "1) Cria snapshot da maquina em ${data}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
idvm=`xe vm-snapshot vm=${vmname} new-name-label=${vmname}_snapshot` &> /var/log/backup/vms/bkpvms-${dataarq}.log
if [ $? -eq 0 ]; then {
echo "Id Snapshot criado: ${idvm}" >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
data=`date +%c` # Data e hora atual.
echo "2)Convertendo o snapshot criado em template em ${data}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
xe template-param-set is-a-template=false uuid=${idvm} &> /var/log/backup/vms/bkpvms-${dataarq}.log
if [ $? -eq 0 ]; then {
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
data=`date +%c` # Data e hora atual.
echo "3)Convertendo o template em VM em ${data}" >> /var/log/backup/vms/bkpvms-${dataarq}.log
cvvm=`xe vm-copy vm=${vmname}_snapshot sr-uuid=${storagebkp} new-name-label=${vmname}_${dhvm}` &> /var/log/backup/vms/bkpvms-${dataarq}.log
if [ $? -eq 0 ]; then {
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
data=`date +%c` # Data e hora atual.
echo "4)Exportando VM criada para o HD externo em ${data}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
if test -d ${bkpdestino}/${vmname}; then { # Se existir o diretorio
xe vm-export vm=${cvvm} filename="${bkpdestino}/${vmname}/${vmname}_${dhvm}.xva" &> /var/log/backup/vms/bkpvms-${dataarq}.log
} else { # Se não existir o diretorio, cria um.
mkdir -p ${bkpdestino}/${vmname}
echo "Criando diretorio ${bkpdestino}/${vmname}"
xe vm-export vm=${cvvm} filename="${bkpdestino}/${vmname}/${vmname}_${dhvm}.xva" &> /var/log/backup/vms/bkpvms-${dataarq}.log
} fi;
if [ $? -eq 0 ]; then {
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
data=`date +%c` # Data e hora atual.
echo "5)Deletando VM e seu VDI criado em ${data}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
xe vm-uninstall vm=${cvvm} force=true &> /var/log/backup/vms/bkpvms-${dataarq}.log
if [ $? -eq 0 ]; then {
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
data=`date +%c` # Data e hora atual.
echo "6)Deletando Snapshot criado em ${data}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
xe vm-uninstall --force uuid=${idvm} &> /var/log/backup/vms/bkpvms-${dataarq}.log
if [ $? -eq 0 ]; then {
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
data=`date +%c` # Data e hora atual.
echo "7)Excluindo backups duplicados em ${data}" >> /var/log/backup/vms/bkpvms-${dataarq}.log
ls -td1 ${bkpdestino}/${vmname}/* | sed -e '1,2d' | xargs -d '\n' rm -rif &> /var/log/backup/vms/bkpvms-${dataarq}.log
if [ $? -eq 0 ]; then {
echo "Executou com sucesso." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "------------------------------------------------------------------------------" >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "Backup VM ${vmname} concluido em ${data}." >> /var/log/backup/vms/bkpvms-${dataarq}.log
} else {
echo "Problemas na execução, verifique o arquivo de log." >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 1
} fi;
 
dataoud=`date +%s` #data final de execução
seg=$((${dataoud} - ${datain}))
min=$((${seg}/60))
seg=$((${seg}-${min}*60))
hor=$((${min}/60))
min=$((${min}-${hor}*60))
echo "Tempo estimado: ${hor}:${min}:${seg}" >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
} done;
dataoud=`date +%s` #data final de execução
seg=$((${dataoud} - ${datain2}))
min=$((${seg}/60))
seg=$((${seg}-${min}*60))
hor=$((${min}/60))
min=$((${min}-${hor}*60))
echo "Tempo Total Estimado: ${hor}:${min}:${seg}" >> /var/log/backup/vms/bkpvms-${dataarq}.log
echo "==============================================================================" >> /var/log/backup/vms/bkpvms-${dataarq}.log
exit 0
