#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: $0 <year> <month> <day> <user> <password>"
	echo "Example: $0 2016 12 31 myuser mypass"
	exit
fi

./create_expenses_config.py $1 $2 $3 $4 $5
logstash -f logstash_configs/config-${1}-${2} < ~/transparencia/Favorecidos/Processados/${1}${2}.csv
