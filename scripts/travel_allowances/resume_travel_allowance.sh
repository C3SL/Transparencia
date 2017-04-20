#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage $0 <path> <date> <filter> <column-name>"
    echo "Example: $0 ./tmp_201612 201612 MEC 2"
    exit
fi

path=$1
date=$2
filter=$3
dateWithoutHyphen=${date//-}

input="${path}/${dateWithoutHyphen}_Diarias.csv"
output="${path}/${dateWithoutHyphen}.csv"

head -n1 ${input} > $path/header.csv
iconv -f WINDOWS-1252 -t UTF-8 -o $path/tmp.csv $path/header.csv
columnId=$(sed s/"${4}".*$/"${4}"/ $path/tmp.csv | sed -e 's/\t/\n/g' | wc -l)
rm -f $path/tmp.csv $path/header.csv

cmd="\$$columnId == \"${filter}\""

# Print selected column's name:
# cmd2="{ print \$$columnId }"
# head -n1 "${input}" | awk -F $'\t' "$cmd2"

cat "${input}" | awk -F $'\t' "$cmd" > "$output"
