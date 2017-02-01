# Setembro 2016
path=$1
date=$2

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <path> <date>"
	exit
fi

echo "Processing data with args = ${path} and ${date}"

input="${path}${date}_Cadastro.csv"
output="${path}${date}_Cadastro_Ufpr_Unique.csv"

columns="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42"

# About this command:
# - Sed wraps fields in double quotes.
# - Grep removes everyone that does not work in UFPR.
# - Cut selects the important columns.
# - Uniq removes repeated values.
# - Tr removes null characters (ctrl + @).

# Get data from all universities.
#cat $input | egrep --binary-files=text "(UNIVERSIDADE FED*|Id_SERVIDOR_PORTAL	NOME)" | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' | tr -d '\000' > $output

# Get data only from UFPR, and wraps it in double quotes (").
# cat $input | egrep --binary-files=text "(UNIVERSIDADE FEDERAL DO PARANA|Id_SERVIDOR_PORTAL	NOME)" | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' | tr -d '\000' > $output

# Same as above, but does not wrap data in double quotes (").
cat $input | egrep --binary-files=text "(UNIVERSIDADE FEDERAL DO PARANA|Id_SERVIDOR_PORTAL	NOME)" | tr -d '\000' > $output
