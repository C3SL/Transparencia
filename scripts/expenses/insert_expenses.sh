#!/bin/bash

# This script is the one that should be called to insert data from one month.

# Input: Year, month and day from the data to be inserted, ElasticSearch's user and password.
# Example: ./insert_expenses.sh 2016 10 31 myuser mypass
# It has 3 steps:
#   1- Generate logstash config file via create_expenses_config.py.
#   2- Generate CSV with only UFPR data via resume_expenses.sh, which is stored in transparencia/data/expenses/processed/year-month.csv
#   3- Insert data in ElasticSearch via logstash, using the config file created and the CSV created by resume_expenses.sh.
# Output: The commands/scripts outputs.

if [ "$#" -ne 5 ]; then
	echo "Usage: $0 <year> <month> <day> <user> <password>"
	echo "Example: $0 2016 12 31 myuser mypass"
	exit
fi

./create_expenses_config.py $1 $2 $3 $4 $5
./resume_expenses.sh ../../data/expenses/ ${1}-${2}
logstash -f ../../configs/expenses/logstash/config-${1}-${2} < ../../data/expenses/processed/${1}${2}.csv
