# This script will call every script needed to insert data.

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <year> <month> <user> <password>"
    echo "Example: $0 2016 12 myuser mypass"
    exit
fi

# First, insert Expenses data.
(cd expenses && ./insert_expenses.sh $1 $2 $3 $4)

# We should now insert Travel allowance data.
(cd travel_allowances && ./insert_travel_allowances.sh $1 $2 $3 $4)

# Now, insert Workers data.
(cd workers && ./insert_register_payment.sh $1 $2 $3 $4)
