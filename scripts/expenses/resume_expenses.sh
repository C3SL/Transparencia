#!/bin/bash

# WARNING: This script should not be called directly. Look at 'insert_expenses.sh' before calling this script.

# Input: First parameter is the path to data files and the second one is the date in the name of the files. Data files can be found in: http://transparencia.gov.br/downloads/mensal.asp?c=GastosDiretos
# Example: ./resume_expenses.sh ../../data/expenses/ 2016-11

# Output: A CSV file in folder processed, filtering the data to get only relevant data (in our case, from UFPR).

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <path> <date> <filter>"
	exit
fi

# Path example: ../../data/expenses/
path=$1
# Date example: 2016-11
date=$2
# Filter example: UNIVERSIDADE FEDERAL DO PARANA
filter=$3
# dateWithoutHyphen example: 201611
dateWithoutHyphen=${date//-}

echo "Processing data with args = $path and ${date}"

input="${path}${date}/${dateWithoutHyphen}_GastosDiretos.csv"
output="${path}processed/${dateWithoutHyphen}.csv"

# About this command:
# - Grep removes everyone that does not work in UFPR.
# - Tr removes null characters (ctrl + @).

cat $input | egrep --binary-files=text "$filter" | tr -d '\000' > $output
rm $input
