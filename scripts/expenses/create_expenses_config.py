#!/usr/bin/env python3

import sys, csv, json, math, subprocess
from pathlib import Path
from subprocess import call

if len(sys.argv) != 6:
    print("Usage: " + sys.argv[0] + " <year (2016)> <month (01)> <day (31)> <username> <password>")
    sys.exit()

with open('logstash_config.example') as infile:
	example = infile.read()

output = example % { "timestamp": sys.argv[3] + '/' + sys.argv[2] + '/' + sys.argv[1] + ' 00:00:00'
					 , "date": sys.argv[1] + '-' + sys.argv[2]
					 , "user": sys.argv[4]
					 , "password": sys.argv[5] }

with open('logstash_configs/config-' + sys.argv[1] + '-' + sys.argv[2], 'w') as outfile:
	outfile.write(output)