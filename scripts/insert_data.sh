# This script will call every script needed to insert data.
# Parameters are the year and month from the data that will be inserted, and an elasticsearch username and password.
# Also, scripts called by insert_data.sh use a config file, located in every subfolder and called 'config.sh'.
# Those config files have some variables that have to be set:
# - Index: The index prefix to be saved on ElasticSearch.
# - Host: The hostname of the machine runnning ElasticSearch.
# - Filter: An array of n values, that will create n indexes in ElasticSearch, each one filtering data from Portal Transparencia using its corresponding string. Ex: "UNIVERSIDADE FEDERAL DO PARANA"
# - University: An array of n values, with n being the same n as Filter's array. This array should contain the initials from Universities declared in Filter array, in the same order.

year=$1
month=$2
user=$3
passwd=$4
insertions=$5

if [[ "$#" -ne 5 || "$year" == "-help" || "$year" == "--help" ]]; then
    echo "  Usage: $0 <year> <month> <user> <password> <insertions>"
    echo "    Insertions must be one between: expenses, travel_allowances, workers, ministry_of_health, all"
    echo "    Example: $0 2016 12 myuser mypass all"
    exit
fi

if [[ "$insertions" == "all" || "$insertions" == "expenses" ]]; then
    # First, insert Expenses data.
    echo "Inserting Expenses from ${year}-${month}..."
    (cd expenses && ./insert_expenses.sh $year $month $user $passwd)
fi

if [[ "$insertions" == "all" || "$insertions" == "travel_allowances" ]]; then
    # We should now insert Travel allowance data.
    echo "Inserting Travel Allowances from ${year}-${month}..."
    (cd travel_allowances && ./insert_travel_allowances.sh $year $month $user $passwd)
fi

if [[ "$insertions" == "all" || "$insertions" == "workers" ]]; then
    # Now, insert Workers data.
    echo "Inserting Workers from ${year}-${month}..."
    (cd workers && ./insert_register_payment.sh $year $month $user $passwd)
fi
