#!/bin/bash
# This is API bash script for https://dtmf.io
# BTC Donate: 1MocKvtHaYVi7EYWckC7TcYnSZWoj3fzR4 
#
#  How to install:
#     root@localhost# apt-get update; apt-get -y install curl jq
#
#  How to configure:
#     Token - API key

token='api key here'
index=0;
if [[ -z $1 ]]
	then
	echo "$0 l: list all my numbers"
	echo "$0 a: all possible number groups"
	echo "$0 r: read sms"
	echo "$0 rent: rent a new number"
	echo "$0 del: del number"
	echo "$0 balance: balance in satoshi"
	echo "$0 sendsms from +1234567890 to +7234567890"
fi

function possible {
	nums=$(curl -s -H "Authorization: Bearer $token" https://dtmf.io/api/v1/groups?type=mobile)
        country=($(echo $nums | sed -e 's/ //g'| jq '.[]["name"]'))
        id=($(echo $nums | jq '.[]["id"]'))
        sms_support=($(echo $nums | jq '.[]["sms_support"]'))
        voice_support=($(echo $nums | jq '.[]["voice_support"]'))
        cost_per_inbound_message=($(echo $nums | jq '.[]["cost_per_inbound_message"]'))
        cost_per_inbound_call_minute=($(echo $nums | jq '.[]["cost_per_inbound_call_minute"]'))
        setup_cost=($(echo $nums | jq '.[]["setup_cost"]'))
        rental_cost_per_minute=($(echo $nums | jq '.[]["rental_cost_per_minute"]'))
        nc=${#id[@]}
        echo 'Country           ID              Setup   PerM    SMS     Voice   PerMsg  PerMinCall'
        echo '--------------------------------------------------------------------------------------'
        for i in $(seq 0 $nc)
        do
	echo "${country[$i]:0:12}    	${id[$i]}	${setup_cost[$i]}	${rental_cost_per_minute[$i]}	${sms_support[$i]}	${voice_support[$i]}	${cost_per_inbound_message[$i]} 	${cost_per_inbound_call_minute[$i]}" | sed -e 's/\"//g'
        done
        echo "----------------------------------------------------------------------[$nc countries]--"
}


function mynumbers {
nums=$(curl -s -H "Authorization: Bearer $token" https://dtmf.io/api/v1/numbers)
echo 'Number		ID		PerMin		PerMsg		Assignment date'
echo '---------------------------------------------------------------------------------------------------'
        number=($(echo $nums | jq '.[]["e164"]'))
        id=($(echo $nums | jq '.[]["group_id"]'))
        permin=($(echo $nums | jq '.[]["cost_per_minute"]'))
        permsg=($(echo $nums | jq '.[]["cost_per_inbound_message"]'))
        date=($(echo $nums | jq '.[]["assignment_start"]'))
        nc=${#id[@]}

	for i in $(seq 0 $nc)
        do
	echo "${number[$i]}	${id[$i]}	${permin[$i]}		${permsg[$i]}		${date[$i]}" | sed -e 's/\"//g'
	done
}

function readmessages {
	var=$1;
        nums=$(curl -s -H "Authorization: Bearer $token" https://dtmf.io/api/v1/number?e164=%2B$var)
        content=($(echo $nums | jq '.messages[]["content"]')) 
        from=($(echo $nums | jq '.messages[]["from"]')) 
        to=($(echo $nums | jq '.messages[]["to"]')) 
	nc=${#from[@]}

	for i in $(seq 0 $nc)
        	do
		echo "------------------------------------------------------------------------------"
		echo " From: ${from[$i]}					To: ${to[$i]}	" | sed -e 's/\"//g' 
                echo "                                                                            "
		echo $nums | jq '.messages['"$i"'].content'| grep -v \{ | sed -e 's/\}/\-/g' | sed -e 's/\"//g' ;
		echo ""
                echo ""
                echo ""
	done
}

if [[ $1 = 'l' ]];	then
	mynumbers;
fi

if [[ $1 = 'a' ]];      then
	possible;
fi


if [[ $1 = 'rent' ]];      then
	possible;
	echo "Which ID do you want?"
	read ID;
	post=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $token" --request POST --data '{"group_id": '\"$ID\"'}' https://dtmf.io/api/v1/numbers)
	echo "Please wait 10 sec..."
	sleep 10;
	echo "My numbers now:"
	mynumbers;

fi

if [[ $1 = 'del' ]];      then
	mynumbers | sed -e 's/\+//g';
	echo "What number do you want to delete?"
	read number;
        delete=$(curl -s -H "Authorization: Bearer $token" --request DELETE https://dtmf.io/api/v1/number?e164=%2B$number)
	echo "OK. My numbers now:"
	echo ""
        mynumbers | sed -e 's/\+//g';
fi

if [[ $1 = 'r' ]];      then
	mynumbers | sed -e 's/\+//g';
	echo "Write num:"
	read var;
	readmessages $var;
fi


if [[ $1 = 'balance' ]];	then
	balance=$(curl -s -H "Authorization: Bearer $token" https://dtmf.io/api/v1/account)
	b=$(echo $balance | jq .balance)
	echo "Balance: $b satoshi"
fi

if [[ $1 = 'sendsms' ]]
	then
	from=$3
	to=$5
	echo "Write text:"
	read content
	sms=$(curl -s -d '{"from": "'"$from"'", "to": "'"$to"'", "content": "'"$content"'"}' -H "Authorization: Bearer $token" -H "Content-Type: application/json" -X POST https://dtmf.io/api/v1/message)
	echo $sms
fi
