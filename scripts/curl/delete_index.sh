if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <index-name>"
    exit
fi

curl -XDELETE "localhost:9200/$1?pretty"
