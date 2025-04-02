#! /bin/bash

#source ~/.sandbox.conf.sh

#requires $DD_API_KEY

# Check for shuf
if ! command -v shuf &> /dev/null; then
    echo "Error: 'shuf' is required but not found."
    echo "Please install it. On macOS, use: brew install coreutils"
    exit 1
fi

if [ -z ${DD_API_KEY} ]
then
	printf "\$DD_API_KEY required"
	exit 1
fi

for i in {1..10}
do
	date=$(date -R);
	random_num=$(( $RANDOM % 100 ));
	other_random_num=$(( $RANDOM % 100 ));
	other_other_random_num=$(( $RANDOM % 15 ));

	if [ $other_random_num -gt 90 ]
	then
		status="ERROR"
	elif [ $other_random_num -gt 80 ]
	then
		status="WARNING"
	elif [ $other_random_num -gt 25 ]
	then
		status="INFO"
	else
		status="DEBUG"
	fi

	something_1=$(shuf -n 1 /usr/share/dict/words)
	something_2=$(shuf -n 1 /usr/share/dict/words)
	uri="https://testsite.com/$something_1?page=$other_random_num#$something_2"

	error_message="$something_2 could not be reached"

	if [ $status == "ERROR" ]
	then
		full_message="[$date] Some text here that isn't JSON. [Message Begins] {\"key\": \"value\",\"service\": \"eoghan-service\", \"another_key\": \"another_value\", \"measure_one\": $random_num, \"status\": \"$status\", \"error_message\": \"$error_message\", \"url\": \"$uri\"} [user$other_other_random_num]"
	else
		full_message="[$date] Some text here that isn't JSON. [Message Begins] {\"key\": \"value\",\"service\": \"eoghan-service\", \"another_key\": \"another_value\", \"measure_one\": $random_num, \"status\": \"$status\", \"url\": \"$uri\"} [user$other_other_random_num]"
	fi

	curl -X POST "https://http-intake.logs.datadoghq.com/v1/input/$DD_API_KEY?ddsource=myapp1&host=$(hostname)" \
	     -H "Content-Type: text/plain" \
	     -d "$full_message"
		echo $i
done
