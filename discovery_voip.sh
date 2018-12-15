#!/bin/bash
#===============================================================================
#
#          FILE:  discovery_voip.sh
# 
#         USAGE:  ./discovery_voip.sh discovery
# 
#   DESCRIPTION:  Script para Descoberta automÃ¡tica caso o cliente possua Provedor VOIP
# 
#       OPTIONS:  ---
#  REQUIREMENTS:  Necessario Primeiramente realizar o Discovery para Identificar os Provedores VOIP do cliente, apÃ³s cadastra na Funcao 03
#          BUGS:  ---
#         NOTES:  Diretorio que deve ser instalado/executado: /usr/local/sbin/z_serviceiot/
#        AUTHOR:  Israel Nogueira (), israel@fortics.com.br
#       COMPANY:  Fortics Tecnologia | "Otimizar o segu negócio é a a nossa especialidade"
#       VERSION:  3.0
#       CREATED:  09-01-2018 17:30:00 BRT
#===============================================================================

# Parametros e Variaveis #

USER=$(cat /etc/asterisk/TRONCOSVOIP/tronco-* | grep username  | cut -d'=' -f2 | sed 's/ //g')
SECRET=$(cat /etc/asterisk/TRONCOSVOIP/tronco-* | grep secret  | cut -d'=' -f2 | sed 's/ //g')
IP=$(cat /etc/asterisk/TRONCOSVOIP/tronco-* | grep domain  | cut -d'=' -f2 | sed 's/ //g')

for i in `echo "$USER"` ; do
	STATUS2=$(rasterisk -x "sip show registry"  | grep -v "Host" | grep -v "registrations." | grep "${i:0:10}" | awk '{print $1","$3","$5}')
	STATUS=" $STATUS2 
$STATUS"
done

for i in `echo "$USER"` ; do
       NOME2=$(rasterisk -x "sip show peers" | grep "${i}" | awk '{print $1}' | cut -d'/' -f1 | sed 's/ //g')
       NOME="$NOME2
$NOME"
done

QTDPROVEDORVOIP=$(rasterisk -x "sip show registry"  | grep -v "Host" | grep -v "registrations.")
LINHAS=$(echo "$QTDPROVEDORVOIP" | wc -l)

# Funcao 01 = JSON #########################################################################################################
# Monta JSON com os nomes das tabelas

function discovery
{
rm -f /tmp/lld_*
echo -e "{" >> /tmp/lld_voip.txt
echo -e "\t\"data\":[\n" >> /tmp/lld_voip.txt

for ((i=1; i<$LINHAS; i++))
do

echo -e "\t{" >> /tmp/lld_voip.txt
	echo -e "\t\t\"{#USER}\":\"`echo "$STATUS" | head -$i | tail -1 | cut -d, -f2`\"," >> /tmp/lld_voip.txt
        echo -e "\t\t\"{#NOME}\":\"`echo "$NOME" | head -$i | tail -1`\"," >> /tmp/lld_voip.txt
	echo -e "\t\t\"{#IP}\":\"`echo "$STATUS" | head -$i | tail -1 | cut -d' ' -f2 | cut -d, -f1`\"," >> /tmp/lld_voip.txt
	echo -e "\t\t\"{#STATUS}\":\"`echo "$STATUS" | head -$i | tail -1 | cut -d, -f3 | cut -d' ' -f1`\"" >> /tmp/lld_voip.txt
	echo -e "\t}" >> /tmp/lld_voip.txt
	echo -e "\t," >> /tmp/lld_voip.txt
done

echo -e "\t{" >> /tmp/lld_voip.txt
        echo -e "\t\t\"{#USER}\":\"`echo "$STATUS" | head -$i | tail -1 | cut -d, -f2`\"," >> /tmp/lld_voip.txt
        echo -e "\t\t\"{#NOME}\":\"`echo "$NOME" | head -$i | tail -1`\"," >> /tmp/lld_voip.txt
	echo -e "\t\t\"{#IP}\":\"`echo "$STATUS" | head -$i | tail -1 | cut -d' ' -f2 | cut -d, -f1`\"," >> /tmp/lld_voip.txt
	echo -e "\t\t\"{#STATUS}\":\"`echo "$STATUS" | head -$i | tail -1 | cut -d, -f3 | cut -d' ' -f1`\"" >> /tmp/lld_voip.txt
	echo -e "\t}\n" >> /tmp/lld_voip.txt


echo -e "\t]" >> /tmp/lld_voip.txt
echo -e "}\n" >> /tmp/lld_voip.txt

cat /tmp/lld_voip.txt

}


# Funcao 02 = Disponibilidade
# Checar Disponibilidade do Link VOIP de acordo com os Troncos Cadastrados
function verificaLinkVoip(){

        STATUS=$(rasterisk -x "sip show registry"  | grep -v "Host" | grep -v "registrations." | grep "$conta" | awk '{print $5}')
	echo "$STATUS " >>/dev/null

        if [ "$STATUS" == "Registered" ] ; then >>/dev/null
echo "1" ;
else
echo "0" ;
fi

}



# Funcao 03 = Checagens
# Opcoes do Parametro $1 ###################################################################################################

case $1 in
          discovery)
discovery ;;

# Troncos Identificados Pelo JSON - Cadastrar cada 1 Abaixo utilizando: NOME e USUARIO da Conta Voip para correta checagem
	DIRECTCALL)
	conta="WTUYN"
	verificaLinkVoip
;;
          *)

echo "##################################################### AJUDA #####################################################"
echo "#                                                                                                               #"
echo "# Opcoes Disponiveis no Parametro JSON | IP | SECRET | STATUS                                                   #"
echo "#                                                                                                               #"
echo "# Ex: discovery_new.sh discovery                                                                                #"
echo "# Ex: discovery_new.sh Nome do Tronco - De acordo com: {#NOME} obtido no DISCOVERY                              #"
echo "#                                                                                                               #"
echo "#################################################################################################################"
exit ;;
esac
############################################################################################################################
