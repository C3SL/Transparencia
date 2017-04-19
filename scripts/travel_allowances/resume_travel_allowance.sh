#!/bin/bash

input="201612_GastosDiretos.csv"

if [ "$#" -ne 4 ]; then
    echo "Usage $0 <path> <date> <filter> <column-id>"
    echo "Example: $0 ./tmp_201612 201612 MEC 2"
    exit
fi

path=$1
date=$2
filter=$3
columnId=$4

dateWithoutHyphen=${date//-}
cmd="\$$columnId == \"${filter}\""

# Input will probably look like: ./tmp_201612/201612_GastosDiretos.csv
input="${path}/${dateWithoutHyphen}_Diarias.csv"
# Output will probably look like: ./tmp_201612/201612.csv
output="${path}/${dateWithoutHyphen}.csv"

cat "${input}" | awk -F $'\t' "$cmd" > "$output"
