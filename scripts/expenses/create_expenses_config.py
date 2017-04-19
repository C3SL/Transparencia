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
