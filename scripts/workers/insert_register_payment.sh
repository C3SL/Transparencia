#!/bin/bash

# Script to help using other scripts. Note that calling it to a data that has already been inserted will DUPLICATE it (which we probably dont want).
# This scripts does 3 things:
#   1- Create config files via create_config.py
#   2- Merge CSV data and create a new CSV file via merge_files_es.py.
#   3- Insert CSV file generated in step 2 into ElasticSearch via Logstash.
# Input: Year, Month and Day from CSV file, ElasticSearch's user and password.
# Example (inserting data from file 20130930_Cadastro.csv): ./insert_register_payment.sh 2013 09 30 myuser mypassword
# Output: The same output as the scripts and commands called.

if [ "$#" -ne 5 ]; then
	echo "Usage: $0 <year> <month> <day> <user> <password>"
	echo "Example: $0 2016 12 01 myuser mypassword"
	exit
fi

./create_config.py $1 $2 $3 $4 $5
./merge_files_es.py ../../configs/workers/json/config-${1}-${2}.json
logstash -f ../../configs/workers/logstash/config-${1}-${2} < ../../data/workers/processed/${1}${2}.csv
