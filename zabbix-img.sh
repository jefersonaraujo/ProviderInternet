#!/bin/bash

######################################################################
# Variaveis de producao - Deve-se alterar de acordo com seu ambiente #
######################################################################

DIR_IMAGENS=/var/www/html/cliente/imagens #Diretorio que vai armazenar as imagens
NOME_IMAGEM=grafico #Nome das imagens a serem geradas
DIR_COOKIE=/root #Diretorio que vai armazenar o cookie
NOME_COOKIE=zabbix.cookie
ENDERECO='http://<IP-Servidor>/zabbix' #Url do Zabbix
USUARIO=admin # Usuario do Zabbix que tenha privilegio de visualizar todos os mapas
SENHA='zabbix'  # Senha do usuario acima
CHART=2 # ID do tipo de grafico
ID=523 # ID do grafico que sera gerada a imagem
PERIODO=3600 # Periodo (em segundos) que serao exibidos no grafico

######################################################################
# Logica do Script - Nao altere a menos que saiba o que esta fazendo #
######################################################################

# Gera o cookie
wget -q --save-cookies=$DIR_COOKIE\/$NOME_COOKIE -4 --keep-session-cookies 2> /dev/null -O - -S --post-data="name=

$USUARIO&password=$SENHA&enter=Sign in&autologin=1&request=" $ENDERECO\/index.php?login=1 > /dev/null

# Gera as imagens
wget -q -4 --load-cookies=$DIR_COOKIE\/$NOME_COOKIE -O $DIR_IMAGENS\/$NOME_IMAGEM.png "$ENDERECO/chart$CHART.php?graphid=$ID&period=$PERIODO"

# Remove o cookie
rm -rf $DIR_COOKIE/$NOME_COOKIE
