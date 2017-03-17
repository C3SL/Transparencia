# This file only contains some config variables:

# Index prefix: The prefix of the index in elasticsearch. Ex: gastos

index="gastos-pagamentos"

# Filter: An array of strings that will be used on 'egrep' to filter data to get only relevant universities.
# University: An array of initials, corresponding to Filter.
# Warning: Filter's length must be the same as university's!!

filter=("UNIVERSIDADE FEDERAL DO PARANA" "UNIVERSIDADE FEDERAL DE MINAS GERAIS" "UNIVERSIDADE FEDERAL DE SANTA CATARINA" "UNIVERSIDADE FEDERAL DE PERNAMBUCO" "UNIVERSIDADE FEDERAL DE SANTA MARIA")
university=("ufpr" "ufmg" "ufsc" "ufpe" "ufsm")

# Host: ElasticSearch's host. Ex: "localhost"

host="localhost"
