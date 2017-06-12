# Input: Kibana/ElasticSearch's user and password and two index names: the script will rename the index with the first name to the second one.

userAndPasswd=$1
sourceIndex=$2
destIndex=$3

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <user:password> <old-index> <new-index>"
    echo "Example: $0 myuser:mypass ufpr-csv-2016-11 ufpr-servidores-2016-11"
    exit
fi

source ./config.sh

# Copy old index to new index...
curl -XPOST -u $userAndPasswd "${dbHostname}_reindex?pretty" -H 'Content-Type: application/json' -d'
  {
    "source": {
      "index": "'$sourceIndex'"
    },
    "dest": {
       "index": "'$destIndex'"
    }
  }
'

# Delete old index...
curl -XDELETE -u $userAndPasswd "${dbHostname}$sourceIndex?pretty"
