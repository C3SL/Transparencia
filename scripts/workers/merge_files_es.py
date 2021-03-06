#!/usr/bin/env python3

# WARNING: This script should not be called if you dont know what you're doing! Look for 'insert_register_payment.sh'.

# Script made to create a CSV that will be inserted in ElasticSearch.
# This script is being used to merge two files: a Remuneration report (ex: 20161031_Remuneracao.csv) with a file that contains the Portal ID from UFPR people
# (ex: 20161031_Cadastro_Unique.csv). This second file can be obtained filtering a Register report (ex: 20161031_Cadastro.csv) using resume_register.sh.

# Input: A configuration file, in the same format as the example. This configuration file can be generated by create_config.py.

# Documentation of config.json.example:
# - Variables ending with number 1 represent something from the first file, while the ones that end with number 2 represent the same thing in the second file.
# - File1 and File2 are the files that will be merged. File1 name is "*_Cadastro_Unique.csv", File2 name is "*_Remuneracao.csv".
# - IdColumn1 and IdColumn2 represent the common column for each CSV (Ex: an ID column).
# - Quotechar, Delimiter and LineTerminator are the CSV's quote char, delimiter and line terminator, respectively.
# - OutputFile is the name of the output file (the result CSV).

# Output: A CSV that will contain every row from the second file (*_Cadastro_Unique.csv). From the first file (*_Remuneracao.csv),
# I will get only data thats in the second file as well. This means some people in our data will not have data from Remuneracao.csv.

import sys, csv, json, math, subprocess
from pathlib import Path
from subprocess import call

def getDataFromRows(row1, row2):
    newRow = []
    for value in row2:
        newRow.append(value)
    # Append columns ANO e MES.
    newRow.append(row1[0])
    newRow.append(row1[1])
    # Start i in 5 because we want to ignore columns ID_SERVIDOR_PORTAL, CPF and NOME from Remuneracao.csv (we already have it from Cadastro.csv). We might not have data from them.
    for i in range(5, len(row1)):
        newRow.append(row1[i])
    return newRow

def getDataWithEmptyRow(columns, row):
    newRow = []
    for value in row:
        newRow.append(value)
    # Append since 3 because we want to ignore columns ID_SERVIDOR_PORTAL, CPF and NOME from Remuneracao.csv (we already have this data from Cadastro.csv).
    for i in range(3, columns):
        newRow.append('')
    return newRow

if len(sys.argv) != 4:
    print("Usage: " + sys.argv[0] + " <config.json> <filter> <columnId>")
    sys.exit()

with open(sys.argv[1]) as f:
    params = json.load(f)

# Which files should be merged?
file1 = params['path'] + '/' + params['date'] + params['file1']
file2 = params['path'] + '/' + params['date'] + params['file2']

# Which column in each file contains the common column?
idPointColumn1 = params['idColumn1']
idPointColumn2 = params['idColumn2']

csv.register_dialect('dialect', lineterminator = params['lineterminator'], delimiter=params['delimiter'], quotechar=params['quotechar'])

with open(file1, newline='', encoding='Windows-1252') as f:
    csv_1 = [ i for i in csv.reader(f, 'dialect') ]
title1 = csv_1.pop(0)

file_exists = Path(file2)
if not file_exists.is_file():
    print("File2 does not exist. Calling script resume_register to create it...")
    call(["./resume_register.sh " +  params['path'] + " " + params['date'] + " " + sys.argv[2] + " " + sys.argv[3]], shell=True)

with open(file2, newline='', encoding='Windows-1252') as f:
    csv_2 = [ i for i in csv.reader(f, 'dialect') ]
title2 = csv_2.pop(0)

# Having data from both files, I have to merge them.

result = []
hits = 0
errors = 0

# Get number of columns in file 1
columns1 = len(csv_1[0])

# Create dictionary...
data = {}
for row in csv_1:
    data[row[idPointColumn1]] = row

for row2 in csv_2:
    if row2[idPointColumn2] in data:
        newRow = getDataFromRows(data[row2[idPointColumn2]], row2)
        # To make sure we wont get the same point twice.
        del data[row2[idPointColumn2]]
        row2[idPointColumn2] = -1;
        result.append(newRow)
        hits += 1
    else:
        # This guy was in the second file, but not in the first one. Add him, but with null values in the second file.
        newRow = getDataWithEmptyRow(columns1, row2)
        result.append(newRow)
        errors += 1

with open(params['outputFile'], 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter='\t')
    writer.writerow(getDataFromRows(title1, title2))
    writer.writerows(result)
