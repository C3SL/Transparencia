
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <index-name>"
    exit
fi

indexName=$1

curl -XDELETE "localhost:9200/$indexName?pretty"
