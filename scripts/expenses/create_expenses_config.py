#!/usr/bin/env python3

# WARNING: This script should not be called directly. Look at 'insert_expenses.sh' before calling this script.

# This script is used to create a Logstash Config file.

# Input: year, month and day, ElasticSearch's username and password.

import sys, csv, json, math, subprocess
from pathlib import Path
from subprocess import call

if len(sys.argv) != 10:
    print("Usage: " + sys.argv[0] + " <year (2016)> <month (01)> <day (31)> <index> <host> <entity> <username> <password> <path>")
    sys.exit()

# Generate JSON CNPJ merge config file:
data = {
	"path": sys.argv[9]
	, "date": sys.argv[1] + sys.argv[2]
	, "file1": "_CNPJ.csv"
	, "file2": "_GastosDiretosFiltered.csv"
	, "idColumn1": 0
	, "idColumn2": 19 # 19 começando do 0. Se começar do 1, é 20.
	, "quotechar": "\""
	, "delimiter": "\t"
	, "lineterminator": "\n"
	, "outputFile": sys.argv[9] + '/' + sys.argv[1] + sys.argv[2] + "_merged_by_cnpj.csv"
	#, "outputFile": sys.argv[9] + '/' + sys.argv[1] + sys.argv[2] + ".csv"
}

with open(sys.argv[9] + '/config-cnpj-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

# Generate JSON CNAE merge config file:
data = {
	"path": sys.argv[9]
	, "date": sys.argv[1] + sys.argv[2]
	, "file1": "_CNAE.csv"
	, "file2": "_merged_by_cnpj.csv"
	, "idColumn1": 2
	#, "idColumn2": 28 # 19 começando do 0. Se começar do 1, é 20.
    # Era 28 antes de tirar os campos. Agora eh 25.
    , "idColumn2": 25
	, "quotechar": "\""
	, "delimiter": "\t"
	, "lineterminator": "\n"
	, "outputFile": sys.argv[9] + '/' + sys.argv[1] + sys.argv[2] + ".csv"
}

with open(sys.argv[9] + '/config-cnae-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

# Generate logstash config file:
with open('logstash_config.example') as infile:
	example = infile.read()

output = example % { "timestamp": sys.argv[3] + '/' + sys.argv[2] + '/' + sys.argv[1] + ' 00:00:00'
					 , "date": sys.argv[1] + '-' + sys.argv[2]
                     , "index": sys.argv[4] + '-' + sys.argv[6]
                     , "host": sys.argv[5]
					 , "user": sys.argv[7]
					 , "password": sys.argv[8] }

date = sys.argv[1] + '-' + sys.argv[2]
with open(sys.argv[9] + '/config-' + date, 'w') as outfile:
	outfile.write(output)
