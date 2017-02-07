# Setembro 2016
# Path example: ../../Favorecidos/
path=$1
# Date example: 2016-11
date=$2
# dateWithoutHyphen example: 201611
dateWithoutHyphen=${date//-}

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <path> <date>"
	exit
fi

echo "Processing data with args = $path and ${date}"

input="${path}${date}/${dateWithoutHyphen}_GastosDiretos.csv"
output="${path}/Processados/${dateWithoutHyphen}.csv"

# About this command:
# - Grep removes everyone that does not work in UFPR.
# - Tr removes null characters (ctrl + @).
# - Head -n1 gets first line (column names). Then, I append the data.

head -n1 $input > $output
cat $input | egrep --binary-files=text "UNIVERSIDADE FEDERAL DO PARANA" | tr -d '\000' >> $output
