#!/bin/bash

# WARNING: This script should not be called if you dont know what you're doing! Look for 'merge_files_es.py'.

# This scripts purpose is to filter data and get only data related to UFPR.

# Input: Path to data files and date from data files.
# Example (inserting data from 2016-10): ./resume_register.sh ../../data/workers/2016-10/ 20161031

# Output: CSV file named YearMonthDay_Cadastro_Ufpr_Unique.csv, in the $path folder.
# Example of CSV location (using same parameters as input): ../../data/workers/2016-10/20161031_Cadastro_Ufpr_Unique.csv

if [ "$#" -ne 3 ]; then
	echo "Usage: $0 <path> <date> <filter>"
	exit
fi

path=$1
date=$2
filter=$3

echo "Processing data with args = ${path} and ${date}"

input="${path}${date}_Cadastro.csv"
output="${path}${date}_Cadastro_Ufpr_Unique.csv"

columns="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42"

# About this command:
# - Sed wraps fields in double quotes.
# - Grep removes everyone that does not work in UFPR.
# - Cut selects the important columns.
# - Uniq removes repeated values.
# - Tr removes null characters (ctrl + @).

# Get data from all universities.
# cat $input | egrep --binary-files=text "(UNIVERSIDADE FED*|Id_SERVIDOR_PORTAL	NOME)" | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' | tr -d '\000' > $output

# Get only data from UFPR.
cat $input | egrep --binary-files=text "$filter" | tr -d '\000' > $output
