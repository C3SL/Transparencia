#!/usr/bin/env python3

"""
Versão feita visando inserção no ElasticSearch.
Isso significa que eu vou escrever TODOS os dados que eu achar do segundo arquivo, mas do primeiro arquivo só escrevo os que estiverem no segundo.


Recebe como parâmetro um arquivo de configuração, no mesmo formato que o exemplo.

Documentação do config.json.example:
file1 and file2 are the files that will be merged.
The variables that end with number 1 represent something in the first file and the ones that one with 2 represent the same thing in the second file.
idColumn represent the common column in both files.
columnsToAdd1 are the ids of the columns that will be printed in the output file.
	We might want to add columns 4, 13, 16 and 22 in columnsToAdd2, but this does not work right now.
delimiter is the CSV's delimiter.
lineterminator is the CSV's line terminator.
outputFile is the name of the output file.
notFoundFile is the name of a file with errors: they represent columns that were in one file but not in the other. In this case, notFoundFile1 are the columns that are in the second file but not in t    he first file.


Nesse momento, ele tá sendo usado pra unir dois arquivos: um relatório de Remuneração (ex: 201610_Remuneracao.csv) com um arquivo que contém o ID do portal das pessoas da UFPR.
Esse segundo arquivo pode ser obtido a partir da filtragem do arquivo de Cadastros (ex: 201610_Cadastros.csv). A filtragem é feita com o resumo_cadastro.sh.
"""

import sys, csv, json, math, subprocess
from pathlib import Path
from subprocess import call

if len(sys.argv) != 2:
    print("Usage: " + sys.argv[0] + " <config.json>")
    sys.exit()

with open(sys.argv[1]) as f:
    params = json.load(f)

# Which files should be merged?
file1 = params['path'] + params['date'] + params['file1']
file2 = params['path'] + params['date'] + params['file2']

# Which column in each file contains the common column?
idPointColumn1 = params['idColumn1']
idPointColumn2 = params['idColumn2']

# What columns are important from each file?
columnsToAdd1 = params['columnsToAdd1']
columnsToAdd2 = params['columnsToAdd2']

# In which files should we save the data not found?
notFoundFile1 = open(params['path'] + params['notFoundFile1'], 'w')
notFoundFile2 = open(params['path'] + params['notFoundFile2'], 'w')

print("Reading files...")

csv.register_dialect('dialect', lineterminator = params['lineterminator'], delimiter=params['delimiter'], quotechar=params['quotechar'])

with open(file1, newline='', encoding='Windows-1252') as f:
    csv_1 = [ i for i in csv.reader(f, 'dialect') ]
title1 = csv_1.pop(0)

file_exists = Path(file2)
if not file_exists.is_file():
	print("File2 does not exist. Calling script to create it...")
	call(["./resumo_cadastro.sh " +  params['path'] + " " + params['date']], shell=True)

with open(file2, newline='', encoding='Windows-1252') as f:
    #csv_2 = [ i for i in csv.reader(f, 'dialect') ]
    #for x in csv.reader(f, 'dialect'):
    #    print(x)
    csv_2 = [ i for i in csv.reader(f, 'dialect') ]
# I do not do csv_2.pop(0) because in this file we are not using a header.
title2 = csv_2.pop(0)

# Having data from both files, I have to merge them.

def getDataFromRows(row1, row2):
    newRow = []
    #for column in columnsToAdd1:
    #    newRow.append(row1[column])
    #for column in columnsToAdd2:
    #    newRow.append(row2[column])
    for value in row2:
        newRow.append(value)
    for value in row1:
        newRow.append(value)
    return newRow

def getDataWithEmptyRow(columns, row):
    newRow = []
    for value in row:
        newRow.append(value)
    for i in range(0, columns):
        newRow.append('')
    return newRow

result = []
count = 0
hits = 0
error1 = 0
error2 = 0
previous = 0
progress = 0
const = 50 / len(csv_2)

print("Preparing data...")

# Get number of columns in file 1
columns1 = len(csv_1[0])

# Separate id_point from useless data in file 2 and append points in result array.
# This for takes about 50% of the total time.

for row2 in csv_2:
    count += 1
    if(count % 10) == 0:
        previous = progress
        progress = math.floor(count * const)
        if(progress != previous):
            print(str(progress) + '% completed.')
        #print(count)
    # I have IdPoint. Find the correspondent one in the other csv
    # and add data from file 2 to file 2.
    found = False
    for row1 in csv_1:
        if row1[idPointColumn1] == row2[idPointColumn2]:
            newRow = getDataFromRows(row1, row2)
            # To make sure we wont get the same point twice.
            row1[idPointColumn1] = -1;
            row2[idPointColumn2] = -1;
            result.append(newRow)
            found = True
            hits += 1
            break
    if not found:
		# This guy was in the second file, but not in the first one. Add him, but with null values in the second file.
        #print("Error finding field " + row2[idPointColumn2])
        newRow = getDataWithEmptyRow(columns1, row2)
        result.append(newRow)
        notFoundFile1.write(row2[idPointColumn2] + '\n')
        error2 += 1

count = 0
const = 50 / len(csv_1)

# Check if there was a point in csv_1 but not in csv_2. This is not useful anymore. It never printed 'found one'.
"""
for row1 in csv_1:
    count += 1
    if(count % 10) == 0:
        previous = progress
        progress = math.floor(count * const) + 50
        if(progress != previous):
            print(str(progress) + '% completed.')
    if row1[idPointColumn1] != -1:
        #print(row1[idPointColumn1])
        found = False
        for row2 in csv_2:
            if row1[idPointColumn1] == row2[idPointColumn2]:
                print('found one')
                newRow = getDataFromRows(row1, row2)
                result.append(newRow)
                found = True
                break
        if not found:
            #print("Error finding field " + row1[idPointColumn1])
            error1 += 1

print("Number of rows in file 1 but not in file 2: " + str(error1))
"""
print("Number of rows in file 2 but not in file 1: " + str(error2))

print("Saving data to file result.csv...")

with open(params['path'] + params['outputFile'], 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter='\t')
    writer.writerow(getDataFromRows(title1, title2))
    writer.writerows(result)

notFoundFile1.close()
notFoundFile2.close()