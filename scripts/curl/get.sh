# Input: The name of a file containing a curl query.
# Output: The output for the curl query.

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <query-file>"
    exit
fi

query=$(cat $1)

echo curl -u cw14:123mudar -XGET node1.c3sl.ufpr.br:9200/ufpr-servidores-*/_search?pretty -d \'"$query"\'
