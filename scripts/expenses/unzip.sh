#!/bin/bash

# This scripts gets a zip file in ~/Downloads, moves it to a folder in path (probably transparencia/data/expenses), unzips it and removes the zip file.

# Input: Date (year and month, separated by hyphen).
# Ex: ./unzip.sh 2015-12 201512

if [ "$#" -ne 2 ]; then
	echo "Usage $0 <date>"
	exit
fi

date=$1
path="../../data/expenses/"
dateWithoutHyphen=${date//-}

mkdir $path$date
mv ~/Downloads/$dateWithoutHyphen_GastosDiretos.zip $path$date
unzip $path$date/$dateWithoutHyphen_GastosDiretos.zip
mv $path$dateWithoutHyphen_GastosDiretos.csv $path$date
rm $path$date/$dateWithoutHyphen_GastosDiretos.zip
