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
setInFile='scripts/travel_allowance/config.sh'
if [ -z "${index}" ]; then
	inputError "index" $setInFile
    exit;
fi
if [ -z "${host}" ]; then
    inputError "host" $setInFile
    exit;
fi
if [ -z "${columnName}" ]; then
    inputError "columnName" $setInFile
    exit;
fi

size=${#filter[@]}
if [ "$size" -lt 1 ]; then
    inputError "filter" $setInFile
    exit;
fi

# Getting the Last day of this month (Using date 2016-05-15 as example):
# First, get next month (201606).
nxtMonth=$(date +%Y%m -d "$(date +${1}${2}15) next month")
# Append day 01 (20160601).
tempDate=$(date -d "${nxtMonth}01")
# Remove 1 day: 20160531, get only day: 31.
day=$(date -d "$tempDate - 1 day" "+%d")

ym=$1-$2
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${1}'&m='${2}'&consulta=Diarias'

curl $request  --compressed > $path/${1}${2}_Diarias.zip

# Unzip them
unzip -o $path/${1}${2}_Diarias.zip -d $path/

# Remove zip file
rm $path/${1}${2}_Diarias.zip

for key in "${!filter[@]}"
do
    # Step 2:
    ./create_travel_allowance_config.py $1 $2 "$day" "$index" "$host" "$key" $3 $4 "${path}"
    # Step 3:
    ./resume_travel_allowance.sh "$path" ${1}-${2} "${filter[$key]}" "${columnName}"
    # Step 4:
    logstash -f ${path}/config-${1}-${2} < ${path}/${1}${2}.csv
    # Remove processed file
    rm ${path}/${1}${2}.csv
    rm ${path}/config-${1}-${2}
done

rm $path/${1}${2}_Diarias.csv
rmdir $path
