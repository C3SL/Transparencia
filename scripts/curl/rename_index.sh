# Input: Kibana/ElasticSearch's user and password and two index names: the script will rename the index with the first name to the second one.

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <user:password> <old-index> <new-index>"
    echo "Example: $0 myuser:mypass ufpr-csv-2016-11 ufpr-servidores-2016-11"
    exit
fi

dbHostname='http://node1.c3sl.ufpr.br:9200/'

# Copy old index to new index...
curl -u $1 -XPOST "${dbHostname}_reindex?pretty" -H 'Content-Type: application/json' -d'
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
curl -u $1 -XDELETE "${dbHostname}$2?pretty"
