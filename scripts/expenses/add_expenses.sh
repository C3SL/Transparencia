#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <user> <password>"
	echo "Example: $0 myuser mypass"
	exit
fi

./insert_expenses.sh 2016 11 30 $1 $2
./insert_expenses.sh 2016 10 31 $1 $2
./insert_expenses.sh 2016 09 30 $1 $2
./insert_expenses.sh 2016 08 31 $1 $2
./insert_expenses.sh 2016 07 31 $1 $2
./insert_expenses.sh 2016 06 30 $1 $2
./insert_expenses.sh 2016 05 31 $1 $2
./insert_expenses.sh 2016 04 30 $1 $2
./insert_expenses.sh 2016 03 31 $1 $2
./insert_expenses.sh 2016 02 29 $1 $2
./insert_expenses.sh 2016 01 31 $1 $2

./insert_expenses.sh 2015 12 31 $1 $2
./insert_expenses.sh 2015 11 30 $1 $2
./insert_expenses.sh 2015 10 31 $1 $2
./insert_expenses.sh 2015 09 30 $1 $2
./insert_expenses.sh 2015 08 31 $1 $2
./insert_expenses.sh 2015 07 31 $1 $2
./insert_expenses.sh 2015 06 30 $1 $2
./insert_expenses.sh 2015 05 31 $1 $2
./insert_expenses.sh 2015 04 30 $1 $2
./insert_expenses.sh 2015 03 31 $1 $2
./insert_expenses.sh 2015 02 28 $1 $2
./insert_expenses.sh 2015 01 31 $1 $2

./insert_expenses.sh 2014 12 31 $1 $2
./insert_expenses.sh 2014 11 30 $1 $2
./insert_expenses.sh 2014 10 31 $1 $2
./insert_expenses.sh 2014 09 30 $1 $2
./insert_expenses.sh 2014 08 31 $1 $2
./insert_expenses.sh 2014 07 31 $1 $2
./insert_expenses.sh 2014 06 30 $1 $2
./insert_expenses.sh 2014 05 31 $1 $2
./insert_expenses.sh 2014 04 30 $1 $2
./insert_expenses.sh 2014 03 31 $1 $2
./insert_expenses.sh 2014 02 28 $1 $2
./insert_expenses.sh 2014 01 31 $1 $2

./insert_expenses.sh 2013 12 31 $1 $2
./insert_expenses.sh 2013 11 30 $1 $2
./insert_expenses.sh 2013 10 31 $1 $2
./insert_expenses.sh 2013 09 30 $1 $2
./insert_expenses.sh 2013 08 31 $1 $2
./insert_expenses.sh 2013 07 31 $1 $2
./insert_expenses.sh 2013 06 30 $1 $2
./insert_expenses.sh 2013 05 31 $1 $2
./insert_expenses.sh 2013 04 30 $1 $2
./insert_expenses.sh 2013 03 31 $1 $2
./insert_expenses.sh 2013 02 28 $1 $2
./insert_expenses.sh 2013 01 31 $1 $2