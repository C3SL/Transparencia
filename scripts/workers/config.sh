# This file only contains some config variables:

# Index prefix: The prefix of the index in elasticsearch. Ex: gastos

index="servidores"

# ColumnName: The name of the column from the CSV that we will use to filter data.

columnName="ORGSUP_LOTACAO"

# Filter: An associative array that will be used to filter data. The key should be the initials, and they will be used to generate the index name.
# The value should be the same as in the CSV, since it will be used to match data.

declare -A filter
filter=(
    [mec]="MINISTERIO DA EDUCACAO"
)

# Host: ElasticSearch's host. Examples: "localhost"

host="localhost"
