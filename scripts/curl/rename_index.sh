# Input: Kibana/ElasticSearch's user and password and two index names: the script will rename the index with the first name to the second one.

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <user:password> <old-index> <new-index>"
    echo "Example: $0 myuser:mypass ufpr-csv-2016-11 ufpr-servidores-2016-11"
    exit
fi

source ./config.sh

# Copy old index to new index...
curl -XPOST -u $1 "${dbHostname}_reindex?pretty" -H 'Content-Type: application/json' -d'
  {
    "source": {
      "index": "'$2'"
    },
    "dest": {
       "index": "'$3'"
    }
  }
'

# Delete old index...
curl -XDELETE -u $1 "${dbHostname}$2?pretty"
