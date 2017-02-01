#!/bin/bash

echo "Usage: $0 <year> <month> <day>"

./create_config.py $1 $2 $3
./merge_files_es.py configs/config-${1}-${2}.json
logstash -f logstash_configs/config-${1}-${2} < ~/transparencia/Dados_Servidores/Processados/${1}${2}.csv
