# Setembro 2016
path=$1
date=$2

echo "Processing data with args = ${path} and ${date}"

input="${path}${date}_Cadastro.csv"
output="${path}${date}_Cadastro_Ufpr_Unique.csv"

# Outubro 2016
# input="Dados_Servidores/2016-10/20161031_Cadastro.csv"
# output="Dados_Servidores/2016-10/cadastro_2016-10-31_filters_ufpr_unique.csv"

# For now, this does not work. It does not create a properly CSV.
columns="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42"
#columns="1,2,23,24"
#columns="1"

#cat $input | grep --binary-files=text "UNIVERSIDADE FEDERAL DO PARANA" | cut -f $columns | sort | uniq > $output

# The same as above, but wrap fields in double quotes.
#cat $input | grep --binary-files=text "UNIVERSIDADE FEDERAL DO PARANA" | cut -f $columns | sort | uniq | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' > $output
# Sed wraps fields in double quotes. Grep removes everyone that does not work in UFPR. Cut selects the important columns. Uniq removes repeated values. Tr removes null characters (ctrl + @).
#cat $input | grep --binary-files=text "UNIVERSIDADE FEDERAL DO PARANA" | cut -f $columns | sort | uniq | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' | tr -d '\000' > $output

# Parece funcionar, mas pra todas as Universidades
#cat $input | egrep --binary-files=text "(UNIVERSIDADE FED*|Id_SERVIDOR_PORTAL	NOME)" | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' | tr -d '\000' > $output

#cat $input | egrep --binary-files=text "(UNIVERSIDADE FEDERAL DO PARANA|Id_SERVIDOR_PORTAL	NOME)" | sed -e 's/"//g' -e 's/^\|$/"/g' -e 's/\t/"\t"/g' | tr -d '\000' > $output
#Mesmo que de cima, mas sem wrapar com "
cat $input | egrep --binary-files=text "(UNIVERSIDADE FEDERAL DO PARANA|Id_SERVIDOR_PORTAL	NOME)" | tr -d '\000' > $output

# +--------+---------------------+--------------------------------+
# | Column | Contains            | Example                        |
# +--------+---------------------+--------------------------------+
# | 1      | Id_SERVIDOR_PORTAL  | 1000021                        |
# | 2      | NOME                | MARIA AUREA DOS SANTOS RIBEIRO |
# | 24     | COD_ORG_LOTACAO     | 26241                          |
# | 25     | ORG_LOTACAO         | UNIVERSIDADE FEDERAL DO PARANA |
# | 29     | UORG_EXERCICIO      | BL - DEPARTAMENTO DE GENETICA  | Parece que é a coluna 23 na verdade...
# | 33     | JORNADA_DE_TRABALHO | 40 HORAS SEMANAIS              |
# +--------+---------------------+--------------------------------+
