filter=("UNIVERSIDADE FEDERAL DO PARANA" "UNIVERSIDADE FEDERAL DE MINAS GERAIS" "UNIVERSIDADE FEDERAL DE SANTA CATARINA" "UNIVERSIDADE FEDERAL DE PERNAMBUCO" "UNIVERSIDADE FEDERAL DE SANTA MARIA")
university=("ufpr" "ufmg" "ufsc" "ufpe" "ufsm")

length=${#filter[@]}

for (( i=0; i<${length}; i++ ));
do
    echo $i
    echo ${filter[$i]}
    echo ${university[$i]}
done
