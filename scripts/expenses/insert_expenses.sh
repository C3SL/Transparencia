#!/bin/bash

# This script is the one that should be called to insert data from one month.

# Input: Year, month and day from the data to be inserted, ElasticSearch's user and password. The day should be the last day of the month.
# Example: ./insert_expenses.sh 2016 10 myuser mypass
# It has 5 steps:
#   1- Download files and put them in the right location (a temporary directory, inside this directory).
#   2- Generate logstash config file and config files to merge downloaded CSVs, via create_expenses_config.py.
#   3- Generate a CSV with the filtered data via resume_expenses.sh.
#   4- Merge CSVs using merge_files.py, based on config files created by create_expenses_config.py.
#   5- Insert data in ElasticSearch via logstash, using the config file created and the CSV created by resume_expenses.sh.
# Output: The commands/scripts outputs.

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <year> <month> <user> <password>"
    echo "Example: $0 2016 12 myuser mypass"
    exit
fi

source ./config.sh

# Check if all variables in config file are set:
if [ -z "${index}" ]; then
    echo "Var 'index' is unset. Set it in file 'scripts/expenses/config.sh'.";
    exit;
fi
if [ -z "${host}" ]; then
    echo "Var 'host' is unset. Set it in file 'scripts/expenses/config.sh'.";
    exit;
fi
if [ -z "${columnName}" ]; then
    echo "Var 'columnName' is unset. Set it in file 'scripts/expenses/config.sh'.";
    exit;
fi

size=${#filter[@]}
if [ "$size" -lt 1 ]; then
    echo "Var 'filter' is unset. Set it in file 'scripts/expenses/config.sh'.";
    exit;
fi

# Getting the Last day of this month (Using date 2016-05-15 as example):
# First, get next month (201606).
aux=$(date +%Y%m -d "$(date +${1}${2}15) next month")
# Append day 01 (20160601).
temp=$(date +%Y%m%d -d "${aux}01")
# Remove 1 day: 20160531, get only day: 31.
day=$(date -d "$temp - 1 day" "+%d")

ym=$1-$2
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
# Download expenses file:
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&consulta=GastosDiretos'
curl -o $path/${1}${2}_GastosDiretos.zip $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://transparencia.gov.br/downloads/mensal.asp?c=GastosDiretos' -H 'Cookie: ASPSESSIONIDAQRABSAD=OJDLNBCANLIDINCHJHELHHFB; ASPSESSIONIDAQSDCQAD=BOKBKPNCDKOBJKGAMMEKADFL; _ga=GA1.3.1927288562.1481545643; ASPSESSIONIDSCSBBTCD=IGJLJBBCEEJBGLOOJKGNMHBH' -H 'Connection: keep-alive' --compressed
# Download file with information about company:
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&consulta=FavorecidosGastosDiretos'
curl -o $path/${1}${2}_Favorecidos.zip $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8,pt;q=0.6' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu Chromium/56.0.2924.76 Chrome/56.0.2924.76 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://www.portaltransparencia.gov.br/downloads/mensal.asp?c=FavorecidosGastosDiretos' -H 'Cookie: ASPSESSIONIDSCBRBBTT=KPBDKGCAENJIEFBMMPOACBHJ' -H 'Connection: keep-alive' --compressed

# Unzip them
unzip -o $path/${1}${2}_GastosDiretos.zip -d $path/
unzip -o $path/${1}${2}_Favorecidos.zip -d $path/

# Remove zip file
rm $path/${1}${2}_GastosDiretos.zip
rm $path/${1}${2}_Favorecidos.zip

# Remove null bytes
cat $path/${1}${2}_CNPJ.csv | tr -d '\000' > $path/${1}{$2}_CNPJ_NotNull.csv
cat $path/${1}${2}_NaturezaJuridica.csv | tr -d '\000' > $path/${1}{$2}_NatJur_NotNull.csv
mv $path/${1}{$2}_CNPJ_NotNull.csv $path/${1}${2}_CNPJ.csv
mv $path/${1}{$2}_NatJur_NotNull.csv $path/${1}${2}_NaturezaJuridica.csv

for key in "${!filter[@]}"
do
    # Step 2:
    ./create_expenses_config.py $1 $2 "$day" "$index" "$host" "$key" $3 $4 "${path}"
    # Step 3:
    ./resume_expenses.sh "${path}" ${1}-${2} "${filter[$key]}" "${columnName}"
    aux=$( echo "${filter[$key]}" | sed 's/ /\\ /g' )
    ./merge_files.py $path/config-cnpj-${1}-${2}.json "$aux" "${columnName}"
    ./merge_files.py $path/config-cnae-${1}-${2}.json "$aux" "${columnName}"
    ./merge_files.py $path/config-natjur-${1}-${2}.json "$aux" "${columnName}"
    # Step 4:
    logstash -f ${path}/config-${1}-${2} < ${path}/${1}${2}.csv
    # Data inserted, we can now remove it.
    rm ${path}/${1}${2}.csv
    rm ${path}/${1}${2}_merged_by_cnpj.csv
    rm ${path}/${1}${2}_merged_by_cnae.csv
    rm ${path}/config-${1}-${2}
    rm ${path}/config-cnae-${1}-${2}.json
    rm ${path}/config-cnpj-${1}-${2}.json
    rm ${path}/config-natjur-${1}-${2}.json
done

# Remove downloaded csvs.
rm -f $path/${1}${2}_GastosDiretos.csv
rm -f $path/${1}${2}_GastosDiretosFiltered.csv
rm -f $path/${1}${2}_CNAE.csv
rm -f $path/${1}${2}_CNPJ.csv
rm -f $path/${1}${2}_NaturezaJuridica.csv
rmdir $path
