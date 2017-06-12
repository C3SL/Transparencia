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
    echo "Var ${year} is unset. Set in file '${month}'."
    return 0
}

year=$1
month=$2
user=$3
passwd=$4

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

ym=$year-$month
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${year}'&m='${month}'&d=C&consulta=Servidores'

curl $request --compressed > $path/${year}${month}_Servidores.zip

# Unzip them
unzip -o $path/${year}${month}_Servidores.zip -d $path/

# Remove zip file
rm $path/${year}${month}_Servidores.zip

# Get day
day=$(ls $path | grep -m 1 $year$month | cut -c 7,8)

for key in "${!filter[@]}"
do
    # Step 2:
    # Create config files
    ./create_config.py $year $month "$day" "$index" "$host" "$key" $user $passwd "${path}"

    # Step 3:
    # Start processing
    strReplacement=$( echo "${filter[$key]}" | sed 's/ /\\ /g' )
    ./merge_files_es.py $path/config-${year}-${month}.json "$strReplacement" "${columnName}"
    rm $path/${year}${month}${day}_Cadastro_Unique.csv

    # Step 4:
    # Insert data in ElasticSearch
    logstash -f $path/config-${year}-${month} < $path/${year}${month}${day}.csv

    # Remove data
    rm -f $path/config-${year}-${month}
    rm -f $path/config-${year}-${month}.json
    rm -f $path/${year}${month}${day}.csv
done

rm -f $path/${year}${month}${day}_Afastamentos.csv
rm -f $path/${year}${month}${day}_Cadastro.csv
rm -f $path/${year}${month}${day}_Honorarios\(Jetons\).csv
rm -f $path/${year}${month}${day}_Jetom.csv
rm -f $path/${year}${month}${day}_Observacoes.csv
rm -f $path/${year}${month}${day}_Remuneracao.csv
rmdir $path
