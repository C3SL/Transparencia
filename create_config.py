#!/usr/bin/env python3

import sys, csv, json, math, subprocess
from pathlib import Path
from subprocess import call

if len(sys.argv) != 6:
    print("Usage: " + sys.argv[0] + " <year (2016)> <month (01)> <day (31)> <username> <password>")
    sys.exit()

data = {
	"path": "Dados_Servidores/" + sys.argv[1] + "-" + sys.argv[2] + "/"
	, "date": sys.argv[1] + sys.argv[2] + sys.argv[3]
	, "file1": "_Remuneracao.csv"
	, "file2": "_Cadastro_Ufpr_Unique.csv"
	, "idColumn1": 2
	, "idColumn2": 0
	, "quotechar": "\""
	, "delimiter": "\t"
	, "lineterminator": "\n"
	, "outputFile": "Dados_Servidores/Processados/" + sys.argv[1] + sys.argv[2] + ".csv"
}

with open('configs/config-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

if int(sys.argv[1]) <= 2014 or (int(sys.argv[1]) == 2015 and int(sys.argv[2]) <= 3):
	with open('logstash_config_2013.example') as infile:
		example = infile.read()
else:
	with open('logstash_config.example') as infile:
		example = infile.read()

output = example % { "timestamp": sys.argv[3] + '/' + sys.argv[2] + '/' + sys.argv[1] + ' 00:00:00'
					 , "date": sys.argv[1] + '-' + sys.argv[2]
					 , "user": sys.argv[4]
					 , "password": sys.argv[5] }

with open('logstash_configs/config-' + sys.argv[1] + '-' + sys.argv[2], 'w') as outfile:
	outfile.write(output)
