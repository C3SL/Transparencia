#!/bin/bash

# This script is the one that should be called to insert data from one month.

# Input: Year, month and day from the data to be inserted, ElasticSearch's user and password. The day should be the last day of the month.
# Example: ./insert_travel_allowance.sh 2016 10 myuser mypass
# It has 4 steps:
#   1- Download files and put them in the right location.
#   2- Generate logstash config file via create_travel_allowance_config.py.
#   3- Generate a CSV with only UFPR data via resume_travel_allowance.sh, which is stored in transparencia/data/travel_allowance/processed/year-month.csv
#   4- Insert data in ElasticSearch via logstash, using the config file created and the CSV created by resume_travel_allowance.sh.
# Output: The commands/scripts outputs.

if [ "$#" -ne 4 ]; then
	echo "Usage: $0 <year> <month> <user> <password>"
	echo "Example: $0 2016 12 myuser mypass"
	exit
fi

# Getting the Last day of this month (Using date 2016-05-15 as example):
# First, get next month (201606).
aux=$(date +%Y%m -d "$(date +${1}${2}15) next month")
# Append day 01 (20160601).
temp=$(date -d "${aux}01")
# Remove 1 day: 20160531, get only day: 31.
day=$(date -d "$temp - 1 day" "+%d")

ym=$1-$2
dataPath="../../data/"
path="../../data/travel_allowance/"
configPath="../../configs/travel_allowance/logstash/"

source config.sh

if [ ! -d "$dataPath" ]; then
	mkdir "$dataPath"
fi
if [ ! -d "$path/processed" ]; then
	mkdir -p "$path/processed"
fi
if [ ! -d "$configPath" ]; then
	mkdir -p "$configPath"
fi

# Step 1:
# Create directory to store files
mkdir $path$ym

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&consulta=Diarias'
curl -o $path$ym/${1}${2}_Diarias.zip $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://transparencia.gov.br/downloads/mensal.asp?c=GastosDiretos' -H 'Cookie: ASPSESSIONIDAQRABSAD=OJDLNBCANLIDINCHJHELHHFB; ASPSESSIONIDAQSDCQAD=BOKBKPNCDKOBJKGAMMEKADFL; _ga=GA1.3.1927288562.1481545643; ASPSESSIONIDSCSBBTCD=IGJLJBBCEEJBGLOOJKGNMHBH' -H 'Connection: keep-alive' --compressed

# Unzip them
unzip $path$ym/${1}${2}_Diarias.zip -d $path$ym/

# Remove zip file
rm $path$ym/${1}${2}_Diarias.zip

# Step 2:
./create_travel_allowance_config.py $1 $2 $day $index $host $3 $4
# Step 3:
./resume_travel_allowance.sh $path ${1}-${2} $filter
# Step 4:
logstash -f ../../configs/travel_allowance/logstash/config-${1}-${2} < ${path}processed/${1}${2}.csv

# Remove processed file
rm ${path}processed/${1}${2}.csv
