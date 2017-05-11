#!/usr/bin/env python3

# Lê dois arquivos CSVs, pega as linhas únicas (ignorando diferença de separador ou de embrulhador ('wrapper')) e escreve elas em um arquivo CSV resultado, cuja formatação
# é com ';' como separador ('semicolon') e embrulhado em aspas duplas ('"').

import sys, csv
from pathlib import Path

if len(sys.argv) == 2 and (sys.argv[1] == "-help" or sys.argv[1] == "-h" or sys.argv[1] == "--help"):
    print("This script will read two CSVs and output only one, with separator being ';' and quoting all fields.")
    print("It will make a 'join' between the two CSVs, ignoring repeated rows.\n")
    print("Usage: " + sys.argv[0] + " <csv-file-1> <delimiter1> <quoting1> <csv-file-2> <delimiter2> <quoting2> <output-file>")
    print("    - Csv-file1: Name of the first file.")
    print("    - Delimiter1: Separator of the first csv (ex: ',', ';', 'tab'). If the delimiter is tab, use \"tab\" (without quotes).")
    print("    - Quoting1: 0 if fields in the first csv are wrapped in \", 1 otherwise.")
    print("    - Csv-file2: Name of the second file.")
    print("    - Delimiter2: Separator of the second csv.")
    print("    - Quoting2: 0 if fields in the first csv are wrapped in \", 1 otherwise.")
    print("    - Output-file: Name of the output file.\n")
    print("Example: ./fix_csv_separator.py csv_1.csv tab 0 csv_2.csv \";\" a output.csv\n")
    sys.exit()

if len(sys.argv) != 8:
    print("Usage: " + sys.argv[0] + " <csv-file-1> <delimiter1> <quoting1> <csv-file-2> <delimiter2> <quoting2> <output-file>")
    sys.exit()

# Get params:
file1 = sys.argv[1]
delim1 = sys.argv[2]
quoting1 = csv.QUOTE_MINIMAL

file2 = sys.argv[4]
delim2 = sys.argv[5]
quoting2 = csv.QUOTE_MINIMAL

output = sys.argv[7]

# Convert params to the right character:
if(delim1 == "tab"):
    delim1 = '\t'
if(delim2 == "tab"):
    delim2 = '\t'

if(sys.argv[3] == "0"):
    quoting1 = csv.QUOTE_NONE
if(sys.argv[6] == "0"):
    quoting2 = csv.QUOTE_NONE

# Create dialects:
csv.register_dialect('dialect1', delimiter=delim1, quoting=quoting1)
csv.register_dialect('dialect2', delimiter=delim2, quoting=quoting2)

# Check if files exist...
file_exists = Path(file1)
if not file_exists.is_file():
    print("File " + file1 + " does not exist. Aborting...")
    sys.exit()

file_exists = Path(file2)
if not file_exists.is_file():
    print("File " + file2 + " does not exist. Aborting...")
    sys.exit()

# Read data from CSV...
with open(file1, newline='', encoding="Windows-1252") as f:
    csv_1 = [ i for i in csv.reader(f, 'dialect1') ]

with open(file2, newline='', encoding="Windows-1252") as f:
    csv_2 = [ i for i in csv.reader(f, 'dialect2') ]

# Store data from both csvs in only one variable:
full_csv = csv_1 + csv_2

# Convert to tuples. It is needed to convert them to a set.
tuples = [ tuple(i) for i in full_csv ]

# Convert them to a set. This eliminates duplicate rows.
unique_rows = set(tuples)

# Change it back from tuples to a list.
full_csv = [ list(i) for i in unique_rows ]

# This is not needed, but helps to check if there is a duplicated row.
full_csv.sort()

# Save with new delimiter and quoting...
with open(output, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile, delimiter=';', quotechar="\"", quoting=csv.QUOTE_ALL)
    writer.writerows(full_csv)
