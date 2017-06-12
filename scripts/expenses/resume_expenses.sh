#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage $0 <path> <date> <filter> <column-name>"
    echo "Example: $0 ./tmp_201612 201612 MEC 2"
    exit
fi

path=$1
date=$2
filter=$3
column=$4

dateWithoutHyphen=${date//-}

input="${path}/${dateWithoutHyphen}_GastosDiretos.csv"
output="${path}/${dateWithoutHyphen}_GastosDiretosFiltered.csv"

head -n1 "${input}" > "$output"
iconv -f WINDOWS-1252 -t UTF-8 -o $path/tmp.csv "$output"
columnId=$(sed s/"${column}".*$/"${column}"/ $path/tmp.csv | sed -e 's/\t/\n/g' | wc -l)
rm -f $path/tmp.csv

cmd="\$$columnId == \"${filter}\""
cat "${input}" | tr -d '\000' | awk -F $'\t' "$cmd" >> "$output"
