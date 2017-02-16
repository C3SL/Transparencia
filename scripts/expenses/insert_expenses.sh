#!/bin/bash

# This script is the one that should be called to insert data from one month.

# Input: Year, month and day from the data to be inserted, ElasticSearch's user and password. The day should be the last day of the month.
# Example: ./insert_expenses.sh 2016 10 31 myuser mypass
# It has 4 steps:
#   1- Download files and put them in the right location.
#   2- Generate logstash config file via create_expenses_config.py.
#   3- Generate a CSV with only UFPR data via resume_expenses.sh, which is stored in transparencia/data/expenses/processed/year-month.csv
#   4- Insert data in ElasticSearch via logstash, using the config file created and the CSV created by resume_expenses.sh.
# Output: The commands/scripts outputs.

if [ "$#" -ne 5 ]; then
	echo "Usage: $0 <year> <month> <day> <user> <password>"
	echo "Example: $0 2016 12 31 myuser mypass"
	exit
fi


ym=$1-$2
dataPath="../../data/"
path="../../data/expenses/"

if [ ! -d "$dataPath" ]; then
	mkdir "$dataPath"
fi
if [ ! -d "$path" ]; then
	mkdir "$path"
fi

# Step 1:
# Create directory to store files
mkdir $path$ym

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&consulta=GastosDiretos'
curl -o $path$ym/${1}${2}_GastosDiretos.zip $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://transparencia.gov.br/downloads/mensal.asp?c=GastosDiretos' -H 'Cookie: ASPSESSIONIDAQRABSAD=OJDLNBCANLIDINCHJHELHHFB; ASPSESSIONIDAQSDCQAD=BOKBKPNCDKOBJKGAMMEKADFL; _ga=GA1.3.1927288562.1481545643; ASPSESSIONIDSCSBBTCD=IGJLJBBCEEJBGLOOJKGNMHBH' -H 'Connection: keep-alive' --compressed

# Unzip them
unzip $path$ym/${1}${2}_GastosDiretos.zip -d $path$ym/

# Remove zip file
rm $path$ym/${1}${2}_GastosDiretos.zip

# Step 2:
./create_expenses_config.py $1 $2 $3 $4 $5
# Step 3:
./resume_expenses.sh ../../data/expenses/ ${1}-${2}
# Step 4:
logstash -f ../../configs/expenses/logstash/config-${1}-${2} < ../../data/expenses/processed/${1}${2}.csv
