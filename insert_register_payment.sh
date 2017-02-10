#!/bin/bash

if [ "$#" -ne 5 ]; then
	echo "Usage: $0 <year> <month> <day> <user> <password>"
	echo "Example: $0 2016 12 01"
	exit
fi

./create_config.py $1 $2 $3 $4 $5
./merge_files_es.py configs/config-${1}-${2}.json
logstash -f logstash_configs/config-${1}-${2} < ~/transparencia/Dados_Servidores/Processados/${1}${2}.csv