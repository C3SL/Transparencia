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

year = sys.argv[1]
month = sys.argv[2]
day = sys.argv[3]
index = sys.argv[4]
host = sys.argv[5]
entity = sys.argv[6]
username = sys.argv[7]
passwd = sys.argv[8]
path = sys.argv[9]

if len(sys.argv) != 10:
    print("Usage: " + sys.argv[0] + " <year (2016)> <month (01)> <day (31)> <index> <host> <entity> <username> <password> <path>")
    sys.exit()

data = {
    "path": path
    , "date": year + month + day
    , "file1": "_Remuneracao.csv"
    , "file2": "_Cadastro_Unique.csv"
    , "idColumn1": 2
    , "idColumn2": 0
    , "quotechar": "\""
    , "delimiter": "\t"
    , "lineterminator": "\n"
    , "outputFile": path + '/' + year + month + day + ".csv"
}

with open(path + '/config-' + year + '-' + month + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

if int(year) <= 2014 or (int(year) == 2015 and int(month) <= 3):
    with open('previous_logstash_config.example') as infile:
        example = infile.read()
else:
    with open('logstash_config.example') as infile:
        example = infile.read()

output = example % { "timestamp": day + '/' + month + '/' + year + ' 00:00:00'
                     , "date": year + '-' + month
                     , "index": index + '-' + entity
                     , "host": host
                     , "user": username
                     , "password": passwd }

with open(path + '/config-' + year + '-' + month, 'w') as outfile:
    outfile.write(output)
