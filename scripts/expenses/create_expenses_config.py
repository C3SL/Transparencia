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
    , "encoding1": "Windows-1252"
    , "encoding2": "Windows-1252"
    , "idColumn1": 0
    , "idColumn2": 19 # 19 because it starts counting from 0.
    , "ignoreColumns1": [0, 1, 2]
    , "ignoreColumns2": []
    , "quotechar": "\""
    , "delimiter": "\t"
    , "lineterminator": "\n"
    , "outputFile": sys.argv[9] + '/' + sys.argv[1] + sys.argv[2] + "_merged_by_cnpj.csv"
}

with open(sys.argv[9] + '/config-cnpj-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

# Generate JSON CNAE merge config file:
data = {
    "path": sys.argv[9]
    , "date": sys.argv[1] + sys.argv[2]
    , "file1": "_CNAE.csv"
    , "file2": "_merged_by_cnpj.csv"
    , "encoding1": "Windows-1252"
    , "encoding2": "utf8"
    , "idColumn1": 2
    , "idColumn2": 25
    , "ignoreColumns1": [0,2]
    , "ignoreColumns2": []
    , "quotechar": "\""
    , "delimiter": "\t"
    , "lineterminator": "\n"
    , "outputFile": sys.argv[9] + '/' + sys.argv[1] + sys.argv[2] + "_merged_by_cnae.csv"
}

with open(sys.argv[9] + '/config-cnae-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
    json.dump(data, outfile, indent=4, sort_keys=True)

# Generate JSON config file to get data from Natureza Juridica:
data = {
    "path": sys.argv[9]
    , "date": sys.argv[1] + sys.argv[2]
    , "file1": "_NaturezaJuridica.csv"
    , "file2": "_merged_by_cnae.csv"
    , "encoding1": "Windows-1252"
    , "encoding2": "utf8"
    , "idColumn1": 0
    , "idColumn2": 26
    , "ignoreColumns1": [0]
    , "ignoreColumns2": []
    , "quotechar": "\""
    , "delimiter": "\t"
    , "lineterminator": "\n"
    , "outputFile": sys.argv[9] + '/' + sys.argv[1] + sys.argv[2] + ".csv"
}

with open(sys.argv[9] + '/config-natjur-' + sys.argv[1] + '-' + sys.argv[2] + '.json', 'w') as outfile:
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
