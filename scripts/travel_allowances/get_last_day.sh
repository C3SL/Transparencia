ym=$(date +%Y%m -d "$(date +%Y%m15) next month")
temp=$(date -d "${ym}01")
d=$(date -d "$temp - 1 day" "+%d")

echo $d
