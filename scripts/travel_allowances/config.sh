# This file only contains some config variables:

# Index prefix: The prefix of the index in elasticsearch. Ex: gastos

index="gastos-diarias"

# Filter: The string that will be used on 'egrep' to filter data to get only relevant universities.
# Ex: Getting only UFPR:
# filter="UNIVERSIDADE FEDERAL DO PARANA"
# Getting UFPR and UFMG:
# filter="UNIVERSIDADE FEDERAL DO PARANA|UNIVERSIDADE FEDERAL DE MINAS GERAIS"
# Getting all universities:
# filter="UNIVERSIDADE FEDERAL*"

filter="UNIVERSIDADE FEDERAL DO PARANA|UNIVERSIDADE FEDERAL DE MINAS GERAIS|UNIVERSIDADE FEDERAL DE SANTA CATARINA|UNIVERSIDADE FEDERAL DE PERNAMBUCO|UNIVERSIDADE FEDERAL DE SANTA MARIA"

# Host: ElasticSearch's host. Examples: "localhost"

host="localhost"
