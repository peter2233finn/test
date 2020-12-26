toprint=""
total="0"
echo "Working of it. This may take a minuits as there are $(wc -l .crypto|awk '{print $1}') coins to be checked."
for i in $(cat .crypto); do
        id=$(echo $i|tr "," " "|awk '{print $1}')
        inacc=$(echo $i|tr "," " "|awk '{print $2}')
        price=$(curl -X GET "https://api.coingecko.com/api/v3/simple/price?ids=$id&vs_currencies=eur" -H "accept: application/json" 2> /dev/null |jq|grep "\"eur\""|awk '{print $2}')
        if [[ "$price" != *"e"* ]]; then
                ineur=$(python -c "print($inacc*$price)")
                total=$(python -c "print($ineur+$total)")
                echo "in eur: $ineur $id: $price in account: $inacc"
        fi
#echo "Total €: $total"
done #|sort -h -r |column -t -s "|"

echo ""
echo "========================="
echo "total: $total"
