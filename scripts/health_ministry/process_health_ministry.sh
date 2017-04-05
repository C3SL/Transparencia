#!/bin/bash

# WARNING: This script should not be called unless the database is erased. Its still here for 2 reasons:
# 1- Log: To know what months of data have been inserted.
# 2- Example: To give example of how to call script insert_health_ministry.sh.

# This script only calls insert_health_ministry for all years and months.

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <user> <password>"
	echo "Example: $0 myuser mypass"
	exit
fi

./insert_health_ministry.sh 2017 01 $1 $2
./insert_health_ministry.sh 2017 02 $1 $2

./insert_health_ministry.sh 2016 12 $1 $2
./insert_health_ministry.sh 2016 11 $1 $2
./insert_health_ministry.sh 2016 10 $1 $2
./insert_health_ministry.sh 2016 09 $1 $2
./insert_health_ministry.sh 2016 08 $1 $2
./insert_health_ministry.sh 2016 07 $1 $2
./insert_health_ministry.sh 2016 06 $1 $2
./insert_health_ministry.sh 2016 05 $1 $2
./insert_health_ministry.sh 2016 04 $1 $2
./insert_health_ministry.sh 2016 03 $1 $2
./insert_health_ministry.sh 2016 02 $1 $2
./insert_health_ministry.sh 2016 01 $1 $2

./insert_health_ministry.sh 2015 12 $1 $2
./insert_health_ministry.sh 2015 11 $1 $2
./insert_health_ministry.sh 2015 10 $1 $2
./insert_health_ministry.sh 2015 09 $1 $2
./insert_health_ministry.sh 2015 08 $1 $2
./insert_health_ministry.sh 2015 07 $1 $2
./insert_health_ministry.sh 2015 06 $1 $2
./insert_health_ministry.sh 2015 05 $1 $2
./insert_health_ministry.sh 2015 04 $1 $2
./insert_health_ministry.sh 2015 03 $1 $2
./insert_health_ministry.sh 2015 02 $1 $2
./insert_health_ministry.sh 2015 01 $1 $2

./insert_health_ministry.sh 2014 12 $1 $2
./insert_health_ministry.sh 2014 11 $1 $2
./insert_health_ministry.sh 2014 10 $1 $2
./insert_health_ministry.sh 2014 09 $1 $2
./insert_health_ministry.sh 2014 08 $1 $2
./insert_health_ministry.sh 2014 07 $1 $2
./insert_health_ministry.sh 2014 06 $1 $2
./insert_health_ministry.sh 2014 05 $1 $2
./insert_health_ministry.sh 2014 04 $1 $2
./insert_health_ministry.sh 2014 03 $1 $2
./insert_health_ministry.sh 2014 02 $1 $2
./insert_health_ministry.sh 2014 01 $1 $2

./insert_health_ministry.sh 2013 12 $1 $2
./insert_health_ministry.sh 2013 11 $1 $2
./insert_health_ministry.sh 2013 10 $1 $2
./insert_health_ministry.sh 2013 09 $1 $2
./insert_health_ministry.sh 2013 08 $1 $2
./insert_health_ministry.sh 2013 07 $1 $2
./insert_health_ministry.sh 2013 06 $1 $2
./insert_health_ministry.sh 2013 05 $1 $2
./insert_health_ministry.sh 2013 04 $1 $2
./insert_health_ministry.sh 2013 03 $1 $2
./insert_health_ministry.sh 2013 02 $1 $2
./insert_health_ministry.sh 2013 01 $1 $2
