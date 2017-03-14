#!/bin/bash

# This scripts gets a zip file in ~/Downloads, moves it to a folder in path (probably transparencia/data/travel_allowance), unzips it and removes the zip file.

# Input: Date (year and month, separated by hyphen).
# Ex: ./unzip.sh 2015-12

if [ "$#" -ne 2 ]; then
	echo "Usage $0 <date>"
	exit
fi

date=$1
path="../../data/travel_allowance/"
dateWithoutHyphen=${date//-}

mkdir $path$date
mv ~/Downloads/${dateWithoutHyphen}_Diarias.zip $path$date
unzip $path$date/${dateWithoutHyphen}_Diarias.zip
mv $path${dateWithoutHyphen}_Diarias.csv $path$date
rm $path$date/${dateWithoutHyphen}_Diarias.zip
