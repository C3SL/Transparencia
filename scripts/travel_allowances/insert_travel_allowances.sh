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
    varName=$1
    file=$2
    echo "Var ${varName} is unset. Set in file '${file}'."
    return 0
}

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <year> <month> <user> <password>"
    echo "Example: $0 2016 12 myuser mypass"
    exit
fi

year=$1
month=$2
user=$3
passwd=$4

source ./config.sh

# Check if all variables in config file are set:
configFile='scripts/travel_allowance/config.sh'
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
nxtMonth=$(date +%Y%m -d "$(date +${year}${month}15) next month")
# Append day 01 (20160601).
tempDate=$(date -d "${nxtMonth}01")
# Remove 1 day: 20160531, get only day: 31.
day=$(date -d "$tempDate - 1 day" "+%d")

ym=$year-$month
path="./tmp_$ym"

# Step 1:
# Create directory to store files
mkdir -p "$path"

# Download files
request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='${year}'&m='${month}'&consulta=Diarias'

curl $request  --compressed > $path/${year}${month}_Diarias.zip

# Unzip them
unzip -o $path/${year}${month}_Diarias.zip -d $path/

# Remove zip file
rm $path/${year}${month}_Diarias.zip

for key in "${!filter[@]}"
do
    # Step 2:
    ./create_travel_allowance_config.py $year $month "$day" "$index" "$host" "$key" $user $passwd "${path}"
    # Step 3:
    ./resume_travel_allowance.sh "$path" ${year}-${month} "${filter[$key]}" "${columnName}"
    # Step 4:
    logstash -f ${path}/config-${year}-${month} < ${path}/${year}${month}.csv
    # Remove processed file
    rm ${path}/${year}${month}.csv
    rm ${path}/config-${year}-${month}
done

rm $path/${year}${month}_Diarias.csv
rmdir $path
