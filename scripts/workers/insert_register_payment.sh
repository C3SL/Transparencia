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

function inputError(){
    echo "Var ${1} is unset. Set in file '${2}'."
    return 0
}


if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <year> <month> <user> <password>"
    echo "Example: $0 2016 12 myuser mypassword"
    exit
fi

source ./config.sh
configFile='scripts/workers/config.sh'
if [ -z "${index}" ]; then
    inputError "index" $configFile
    exit;
fi
if [ -z "${host}" ]; then
    inputError "host" $configFile
    exit;
fi
if [ -z "${columnName}" ]; then
    inputError "columnName" $configFile
    exit;
fi

size=${#filter[@]}
if [ "$size" -lt 1 ]; then
    inputError "filter" $configFile
    exit;
fi

ym=$1-$2
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&d=C&consulta=Servidores'

curl $request --compressed > $path/${1}${2}_Servidores.zip

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
    strReplacement=$( echo "${filter[$key]}" | sed 's/ /\\ /g' )
    ./merge_files_es.py $path/config-${1}-${2}.json "$strReplacement" "${columnName}"
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
