#!/bin/bash

# This script is the one that should be called to insert data from one month.

# Input: Year, month and day from the data to be inserted, ElasticSearch's user and password. The day should be the last day of the month.
# Example: ./insert_ministry_of_health.sh 2016 10 myuser mypass
# It has 4 steps:
#   1- Download files and put them in the right location.
#   2- Generate logstash config file via create_ministry_of_health_config.py.
#   3- Generate a CSV with only UFPR data via resume_ministry_of_health.sh, which is stored in ./tmp/year-month.csv
#   4- Insert data in ElasticSearch via logstash, using the config file created and the CSV created by resume_ministry_of_health.sh.
# Output: The commands/scripts outputs.

if [ "$#" -ne 4 ]; then
	echo "Usage: $0 <year> <month> <user> <password>"
	echo "Example: $0 2016 12 myuser mypass"
	exit
fi

source ./config.sh

if [ -z ${index+x} ]; then
    echo "Var 'index' is unset. Set it in file 'scripts/ministry_of_health/config.sh'.";
    exit;
fi
if [ -z ${host+x} ]; then
    echo "Var 'host' is unset. Set it in file 'scripts/ministry_of_health/config.sh'.";
    exit;
fi
if [ -z ${filter+x} ]; then
    echo "Var 'filter' is unset. Set it in file 'scripts/ministry_of_health/config.sh'.";
    exit;
fi

# Change variable names to improve legibility
year=$1
month=$2

# Getting the Last day of this month (Using date 2016-05-15 as example):
# First, get next month (201606).
aux=$(date +%Y%m -d "$(date +${year}${month}15) next month")
# Append day 01 (20160601).
temp=$(date -d "${aux}01")
# Remove 1 day: 20160531, get only day: 31.
day=$(date -d "$temp - 1 day" "+%d")

ym=$year-$month
path="./tmp_$ym"

mkdir -p "$path"

# Step 1:
# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${year}'&m='${month}'&consulta=GastosDiretos'
curl -o $path/${year}${month}_GastosDiretos.zip $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://transparencia.gov.br/downloads/mensal.asp?c=GastosDiretos' -H 'Cookie: ASPSESSIONIDAQRABSAD=OJDLNBCANLIDINCHJHELHHFB; ASPSESSIONIDAQSDCQAD=BOKBKPNCDKOBJKGAMMEKADFL; _ga=GA1.3.1927288562.1481545643; ASPSESSIONIDSCSBBTCD=IGJLJBBCEEJBGLOOJKGNMHBH' -H 'Connection: keep-alive' --compressed

# Unzip them
unzip -o $path/${year}${month}_GastosDiretos.zip -d $path/

# Remove zip file
rm $path/${year}${month}_GastosDiretos.zip

# Step 2:
./create_ministry_of_health_config.py $year $month "$day" "$index" "$host" $3 $4
# Step 3:
./resume_ministry_of_health.sh "${path}" ${year}-${month} "$filter"
# Step 4:
logstash -f $path/config-${year}-${month} < $path/${year}${month}.csv

# Data inserted, we can now remove it.
rm $path/${year}${month}.csv
rm $path/config-${year}-${month}
rm $path/${year}${month}_GastosDiretos.csv
rmdir $path
