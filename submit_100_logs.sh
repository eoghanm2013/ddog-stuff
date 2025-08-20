#!/bin/bash

# Requires $DD_API_KEY

# Check for shuf
if ! command -v shuf &> /dev/null; then
    echo "Error: 'shuf' is required but not found."
    echo "Please install it. On macOS, use: brew install coreutils"
    exit 1
fi

if [ -z "${DD_API_KEY}" ]; then
    printf "\$DD_API_KEY required\n"
    exit 1
fi

# List of IPs
ips=(
    "38.145.139.53"
    "216.181.187.245"
    "219.116.29.44"
    "158.146.109.209"
    "6.13.172.48"
    "180.125.6.223"
    "202.2.178.191"
    "174.1.19.62"
    "151.135.53.155"
    "233.58.94.254"
)

for i in {1..53}
do
    date=$(date -R)
    random_num1=$(( RANDOM % 100 ))
    random_num2=$(( RANDOM % 100 ))
    other_random_num=$(( RANDOM % 100 ))
    other_other_random_num=$(( RANDOM % 15 ))

    if [ $other_random_num -gt 90 ]; then
    # ERROR: pick a random 4XX code
    error_codes=(400 401 403 404 405 408 409 410 418 429 451)
    idx=$((RANDOM % ${#error_codes[@]}))
    status=${error_codes[$idx]}
elif [ $other_random_num -gt 80 ]; then
    status="WARNING"
elif [ $other_random_num -gt 25 ]; then
    # INFO: pick a random 2XX code
    info_codes=(200 201 202 204 205 206 207 208 226)
    idx=$((RANDOM % ${#info_codes[@]}))
    status=${info_codes[$idx]}
else
    status="DEBUG"
fi

    something_1=$(shuf -n 1 /usr/share/dict/words)
    something_2=$(shuf -n 1 /usr/share/dict/words)
    uri="https://testsite.com/$something_1?page=$other_random_num#$something_2"
    error_message="$something_2 could not be reached"

    # Pick random IP
    client_ip=$(shuf -n 1 -e "${ips[@]}")


    # --- Randomize keyvalue fields ---
    tracking_num=$((RANDOM % 5000 + 1))
    cities=("Springfield" "Riverside" "Franklin" "Greenville" "Bristol" "Clinton" "Centerville" "Fairview" "Madison" "Georgetown" "Ashland" "Oak Grove" "Pine Hill" "Lakeview" "Maplewood" "Hillcrest" "Sunnydale" "Kingston" "Milton" "Salem")
    city_idx=$((RANDOM % ${#cities[@]}))
    delivery_city="${cities[$city_idx]} Townhall"
    vendors=("Acme Corp." "Widgetworks LLC" "Globex Inc." "Initech Ltd." "Stark Industries" "Umbrella Corp." "Hooli LLC" "Wayne Enterprises" "Massive Dynamic" "Cyberdyne Systems" "Wonka Industries" "Soylent Corp." "Monarch Solutions" "Tyrell Corp." "Virtucon Ltd.")
    vendor_from_idx=$((RANDOM % ${#vendors[@]}))
    vendor_to_idx=$((RANDOM % ${#vendors[@]}))
    while [ $vendor_to_idx -eq $vendor_from_idx ]; do
        vendor_to_idx=$((RANDOM % ${#vendors[@]}))
    done
    vendor_from="${vendors[$vendor_from_idx]}"
    vendor_to="${vendors[$vendor_to_idx]}"
    keyvalue="| (tracking_num):($tracking_num)|(delivery_city):($delivery_city)|(vendor_from):($vendor_from)|(vendor_to):($vendor_to)"


    # Build one-liner JSON string
    json_block="{\"key\":\"value\",\"service\":\"eoghan-service\",\"another_key\":{\"nested_attribute\":\"subdomain-prefix.capture-me.suffix\"},\"measure_one\":$random_num1,\"measure_two\":$random_num2,\"status\":\"$status\",\"client_ip\":\"$client_ip\""

    if [ "$status" = "ERROR" ]; then
        json_block+=",\"error_message\":\"$error_message\""
    fi

    json_block+=",\"url\":\"$uri\"}"

    # Build full one-line message
    full_message="[$date] Some text here that isn't JSON. [This is my message.] $json_block [user$other_other_random_num] $keyvalue"

    # Send to Datadog
    curl -s -X POST "https://http-intake.logs.datadoghq.com/v1/input/$DD_API_KEY?ddsource=workshop&host=$(hostname)" \
        -H "Content-Type: text/plain" \
        -d "$full_message"

    echo "$i"
done
