#/bin/bash

input="201612_GastosDiretos"

# Pega header do CSV:
head -n1 ${input}.csv > header.csv
iconv -f WINDOWS-1252 -t UTF-8 -o header_utf-8.csv header.csv

# Conta número total de colunas no CSV:
#echo $(sed s/\t/\r/ header_utf-8.csv)
ncolumns=$(cat header_utf-8.csv | sed -e 's/\t/\n/g' | wc -l)
echo "Colunas: $ncolumns"

# Conta número de colunas até a coluna desejada:
# Primeiro, cortamos o header a partir do título da coluna desejada (Nome Órgão)
cut=$(sed s/Nome\ Órgao.*$/Nome\ Órgao/ header_utf-8.csv)
cut_columns=$(echo "$cut" | sed -e 's/\t/\n/g' | wc -l)
echo "Coluna pra corte: $cut_columns"

other_columns=`expr $ncolumns - $cut_columns`
other_columns=`expr $other_columns - 1`
echo "Numero restante de colunas: $other_columns"

cut_columns=`expr $cut_columns - 1`
echo $cut_columns

#iconv -f WINDOWS-1252 -t UTF-8 -o ${input}_utf-8.csv ${input}.csv

cat ${input}.csv |  awk -F $'\t' '$4 == "UNIVERSIDADE FEDERAL DO PARANA"' > resultado_esperto.csv
