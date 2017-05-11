# Try to download the CSV file with inidone data. It is usually updated dialy, but, just to make sure, we will try to download for the last 31 days (1 month).

d=$(date +%Y%m%d) # Get today.
i=0

while [ "$i" != 31 ]; do
    day=$(date +%d -d "$d")
    month=$(date +%m -d "$d")
    year=$(date +%Y -d "$d")
    echo "Checking day: $day-$month-$year"

    # Get file:
    request='http://arquivos.portaldatransparencia.gov.br/downloads.asp?a='$year'&m='$month'&d='$day'&consulta=CEIS'
    curl --fail $request -H 'Accept-Encoding: gzip, deflate, sdch' -H 'Accept-Language: en-US,en;q=0.8' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.76 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -H 'Referer: http://portaltransparencia.gov.br/downloads/snapshot.asp?c=CEIS' -H 'Connection: keep-alive' --compressed > output.zip
    content=$(cat output.zip)
    if [ "$content" == "Erro ao processar o arquivo." ]; then
        echo "Fail"
    else
        echo "Success"
        if unzip output.zip; then
            filename=$year$month${day}_CEIS.csv
            cat $filename | tr -d '\000' > tmp
            mv tmp $filename
            break
        fi
    fi

    i=`expr $i + 1`
    d=$(date --utc +%Y%m%d -d "$d + 1 day")
done

if [ "$i" == 31 ]; then
    echo "I processed the $i days and did not find any CSV. Please, check Curl's request in script get_inidone.sh"
    exit 1
fi

echo "$i days processed."
