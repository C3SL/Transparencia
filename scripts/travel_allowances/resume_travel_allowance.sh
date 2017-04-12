#!/bin/bash

# WARNING: This script should not be called directly. Look at 'insert_travel_allowance.sh' before calling this script.

# Input: First parameter is the path to data files and the second one is the date in the name of the files. Data files can be found in: http://transparencia.gov.br/downloads/mensal.asp?c=Diarias
# Example: ./resume_travel_allowance.sh ../../data/travel_allowance/ 2016-11

# Output: A CSV file in folder processed, filtering the data to get only relevant data (in our case, from UFPR).

# Path example: ../../data/travel_allowance/
path=$1
# Date example: 2016-11
date=$2
# dateWithoutHyphen example: 201611
dateWithoutHyphen=${date//-}
filter=$3

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <path> <date> <filter>"
	exit
fi

input="${path}${date}/${dateWithoutHyphen}_Diarias.csv"
output="${path}processed/${dateWithoutHyphen}.csv"

if [ ! -d "${path}processsed" ]; then
    mkdir -p "${path}processed"
fi

# About this command:
# - Grep removes irrelevant data. -w option forces to match the whole word, to avoid "UNIVERSIDADE FEDERAL DO PARA" from matching with "UNIVERSIDADE FEDERAL DO PARANA"
# - Tr removes null characters (ctrl + @).

cat "$input" | egrep -w --binary-files=text "$filter" | tr -d '\000' > "$output"
