#!/bin/bash

# WARNING: This script should not be called directly. Look at 'insert_ministry_of_health.sh' before calling this script.

# Input: First parameter is the path to data files and the second one is the date in the name of the files. Data files can be found in: http://transparencia.gov.br/downloads/mensal.asp?c=GastosDiretos
# Example: ./resume_ministry_of_health.sh ./tmp_2016-11 2016-11 "MINISTERIO DA SAUDE"

# Output: A CSV file in folder processed, filtering the data to get only relevant data (in our case, from MINISTERIO DA SAUDE).

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <path> <date> <filter>"
	exit
fi

# Path example: ./tmp_2016-11
path=$1
# Date example: 2016-11
date=$2
# Filter example: "MINISTERIO DA SAUDE"
filter=$3
# dateWithoutHyphen example: 201611
dateWithoutHyphen=${date//-}

input="${path}/${dateWithoutHyphen}_GastosDiretos.csv"
output="${path}/${dateWithoutHyphen}.csv"

# About this command:
# - Grep removes everyone data thas is not from Ministerio da Saude.
# - Tr removes null characters (ctrl + @).

cat "$input" | egrep -w --binary-files=text "$filter" | tr -d '\000' > "$output"
