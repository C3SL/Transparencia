#!/bin/bash

# Script to help using other scripts. Note that calling it to a data that has already been inserted will DUPLICATE it (which we probably dont want).

# This scripts does 4 things:
#   1- Download required files and store them in the right place.
#   2- Create config files via create_config.py
#   3- Merge CSV data and create a new CSV file via merge_files_es.py.
#   4- Insert CSV file generated in step 2 into ElasticSearch via Logstash.

# Input: Year, Month from CSV file, ElasticSearch's user and password.
# Example (inserting data from file 20130930_Cadastro.csv): ./insert_register_payment.sh 2013 09 myuser mypassword

# Output: The same output as the scripts and commands called.

# WARNING: We get the day from the CSV file by using cut in characters 7 and 8. This means we assume they will write something like 01 as day 1. If they change it to 1, this script will not work!

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <year> <month> <user> <password>"
    echo "Example: $0 2016 12 myuser mypassword"
    exit
fi

source ./config.sh

if [ -z "${index}" ]; then
    echo "Var 'index' is unset. Set it in file 'scripts/workers/config.sh'.";
    exit;
fi
if [ -z "${host}" ]; then
    echo "Var 'host' is unset. Set it in file 'scripts/workers/config.sh'.";
    exit;
fi
if [ -z "${columnName}" ]; then
    echo "Var 'columnName' is unset. Set it in file 'scripts/workers/config.sh'.";
    exit;
fi

size=${#filter[@]}
if [ "$size" -lt 1 ]; then
    echo "Var 'filter' is unset. Set it in file 'scripts/expenses/config.sh'.";
    exit;
fi

ym=$1-$2
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&d=C&consulta=Servidores'
curl $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_    64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://www.portaldatranspar    encia.gov.br/downloads/servidores.asp' -H 'Cookie: ASPSESSIONIDAQRABSAD=OJDLNBCANLIDINCHJHELHHFB; ASPSESSIONIDAQSDCQAD=BOKBKPNCDKOBJKGAMMEKADFL; _ga=GA1.3.1927288562.1481545643; ASPSESSIONIDSCSBBTCD=IGJLJBBC    EEJBGLOOJKGNMHBH' -H 'Connection: keep-alive' --compressed > $path/${1}${2}_Servidores.zip

# Unzip them
unzip -o $path/${1}${2}_Servidores.zip -d $path/

# Remove zip file
rm $path/${1}${2}_Servidores.zip

# Get day
day=$(ls $path | grep -m 1 $1$2 | cut -c 7,8)

for key in "${!filter[@]}"
do
    # Step 2:
    # Create config files
    ./create_config.py $1 $2 "$day" "$index" "$host" "$key" $3 $4 "${path}"

    # Step 3:
    # Start processing
    aux=$( echo "${filter[$key]}" | sed 's/ /\\ /g' )
    ./merge_files_es.py $path/config-${1}-${2}.json "$aux" "${columnName}"
    rm $path/${1}${2}${day}_Cadastro_Unique.csv

    # Step 4:
    # Insert data in ElasticSearch
    logstash -f $path/config-${1}-${2} < $path/${1}${2}${day}.csv

    # Remove data
    rm -f $path/config-${1}-${2}
    rm -f $path/config-${1}-${2}.json
    rm -f $path/${1}${2}${day}.csv
done

rm -f $path/${1}${2}${day}_Afastamentos.csv
rm -f $path/${1}${2}${day}_Cadastro.csv
rm -f $path/${1}${2}${day}_Honorarios\(Jetons\).csv
rm -f $path/${1}${2}${day}_Jetom.csv
rm -f $path/${1}${2}${day}_Observacoes.csv
rm -f $path/${1}${2}${day}_Remuneracao.csv
rmdir $path
