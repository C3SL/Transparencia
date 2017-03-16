#!/usr/bin/env python3

# WARNING: This script should not be called if you dont know what you're doing! Look for 'insert_register_payment.sh'.

# Input: Year, month and day from a CSV file, username and password.
# Ex (inserting data from file 20130930_Cadastro.csv): ./create_config.py 2013 09 30 myuser mypassword
# Output: This script will create two config files:
#    - JSON: This config will be used for script merge_files_es.py, and will be stored in transparencia/configs/workers/JSON, with its name being config-year-month.
#    - Logstash: This config will be used by logstash to insert the resulting CSV from merge_files_es.py into ElasticSearch.

import sys, csv, json, math, subprocess
from pathlib import Path
from subprocess import call

if len(sys.argv) != 8:
    print("Usage: " + sys.argv[0] + " <year (2016)> <month (01)> <day (31)> <index> <host> <username> <password>")
    sys.exit()

data = {
	"path": "../../data/workers/" + sys.argv[1] + "-" + sys.argv[2] + "/"
	, "date": sys.argv[1] + sys.argv[2] + sys.argv[3]
	, "file1": "_Remuneracao.csv"
	, "file2": "_Cadastro_Ufpr_Unique.csv"
	, "idColumn1": 2
	, "idColumn2": 0
	, "quotechar": "\""
	, "delimiter": "\t"
	, "lineterminator": "\n"
	, "outputFile": "../../data/workers/processed/" + sys.argv[1] + sys.argv[2] + ".csv"
}

with open('../../configs/workers/json/config-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

if int(sys.argv[1]) <= 2014 or (int(sys.argv[1]) == 2015 and int(sys.argv[2]) <= 3):
	with open('logstash_config_2013.example') as infile:
		example = infile.read()
else:
	with open('logstash_config.example') as infile:
		example = infile.read()

output = example % { "timestamp": sys.argv[3] + '/' + sys.argv[2] + '/' + sys.argv[1] + ' 00:00:00'
					 , "date": sys.argv[1] + '-' + sys.argv[2]
                     , "index": sys.argv[4]
                     , "host": sys.argv[5]
					 , "user": sys.argv[6]
					 , "password": sys.argv[7] }

with open('../../configs/workers/logstash/config-' + sys.argv[1] + '-' + sys.argv[2], 'w') as outfile:
	outfile.write(output)
