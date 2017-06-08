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

function inputError(){
	echo "Var ${1} is unset. Set in file '${2}'."
	return 0
}

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <year> <month> <user> <password>"
    echo "Example: $0 2016 12 myuser mypass"
    exit
fi

source ./config.sh

# Check if all variables in config file are set:
configFile='scripts/expenses/config.sh'
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

# Getting the Last day of this month (Using date 2016-05-15 as example):
# First, get next month (201606).
nxtMonth=$(date +%Y%m -d "$(date +${1}${2}15) next month")
# Append day 01 (20160601).
tempDate=$(date +%Y%m%d -d "${nxtMonth}01")
# Remove 1 day: 20160531, get only day: 31.
day=$(date -d "$tempDate - 1 day" "+%d")

ym=$1-$2
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
downloadLink='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='

# Download expenses file:
request="${downloadLink}${1}&m=${2}&consulta=GastosDiretos"
curl -o $path/${1}${2}_GastosDiretos.zip $request --compressed

# Download file with information about company:
request="${downloadLink}${1}&m=${2}&consulta=FavorecidosGastosDiretos"
curl -o $path/${1}${2}_Favorecidos.zip $request --compressed

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
    strReplacement=$( echo "${filter[$key]}" | sed 's/ /\\ /g' )
    ./merge_files.py $path/config-cnpj-${1}-${2}.json "$strReplacement" "${columnName}"
    ./merge_files.py $path/config-cnae-${1}-${2}.json "$strReplacement" "${columnName}"
    ./merge_files.py $path/config-natjur-${1}-${2}.json "$strReplacement" "${columnName}"
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
