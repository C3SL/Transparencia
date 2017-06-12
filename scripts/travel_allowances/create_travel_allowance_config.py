#!/usr/bin/env python3

# WARNING: This script should not be called directly. Look at 'insert_travel_allowance.sh' before calling this script.

# This script is used to create a Logstash Config file.

# Input: year, month and day, ElasticSearch's username and password.

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

with open('logstash_config.example') as infile:
    example = infile.read()

output = example % { "timestamp": day + '/' + month + '/' + year + ' 00:00:00'
                     , "date": year + '-' + month
                     , "index": index + '-' + entity
                     , "host": host
                     , "user": username
                     , "password": passwd }

date = year + '-' + month
with open(path + '/config-' + date, 'w') as outfile:
    outfile.write(output)
