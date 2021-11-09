#!/bin/bash
set -e

if [[ $1 != *".sol"  ]] ; then 
    echo "ERROR: contract file name .sol required!"
    echo ""
    echo "USAGE:"
    echo "  ${0} <debot>.sol <contract1>.sol <network>"
    echo "      NETWORK  - optional, network endpoint, default is http://127.0.0.1"
    echo ""
    echo "PRIMER:"
    echo "  ${0} mydebot.sol mycontract.sol https://net.ton.dev"
    exit 1
fi

if [[ $2 != *".sol"  ]] ; then 
    echo "ERROR: contract file name .sol required!"
    echo ""
    echo "USAGE:"
    echo "  ${0} <debot>.sol <contract1>.sol <network>"
    echo "      NETWORK  - optional, network endpoint, default is http://127.0.0.1"
    echo ""
    echo "PRIMER:"
    echo "  ${0} mydebot.sol mycontract.sol https://net.ton.dev"
    exit 1
fi

DEBOT_NAME=${1%.*} # filename without extension
CONTRACT1=${2%.*} # filename without extension
NETWORK="${3:-http://127.0.0.1}"

echo $DEBOT_NAME
echo $CONTRACT1
echo $NETWORK
#
# This is TON OS SE giver address, correct it if you use another giver
#
GIVER_ADDRESS=0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5

# net.ton.dev 
#GIVER_ADDRESS=0:9298e68a756590bac881e99887b73f871aeb30e88ba355b49daec742bdb39feb


# Check if tonos-cli installed 
tos=./tonos-cli
if $tos --version > /dev/null 2>&1; then
    echo "OK $tos installed locally."
else 
    tos=tonos-cli
    if $tos --version > /dev/null 2>&1; then
        echo "OK $tos installed globally."
    else 
        echo "$tos not found globally or in the current directory. Please install it and rerun script."
    fi
fi


function giver {
    $tos --url $NETWORK call \
        --abi ../debotBase/giver.abi.json \
        --sign ../debotBase/giver.keys.json \
        $GIVER_ADDRESS \
        sendTransaction "{\"dest\":\"$1\",\"value\":10000000000,\"bounce\":false}" \
        1>/dev/null
}

function get_address {
    echo $(cat $1.log | grep "Raw address:" | cut -d ' ' -f 3)
}

function genaddr {
    $tos genaddr $1.tvc $1.abi.json --genkey $1.keys.json > $1.log
}

echo "Step 0. Compiling"
tondev sol compile $DEBOT_NAME.sol
tondev sol compile $CONTRACT1.sol


echo "Step 1. Calculating debot address"
genaddr $DEBOT_NAME
DEBOT_ADDRESS=$(get_address $DEBOT_NAME)

echo "Step 2. Sending tokens to address: $DEBOT_ADDRESS"
giver $DEBOT_ADDRESS
echo success
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)


echo "Step 3. Deploying contract"
$tos --url $NETWORK deploy $DEBOT_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null

$tos --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null


#todo_code=$(base64 -w 0 todo.tvc)
$tos decode stateinit $CONTRACT1.tvc --tvc > $CONTRACT1.decodeToCut.json
#tail -12 $CONTRACT1.decodeToCut.json > $CONTRACT1.decode.json
tail -12 $CONTRACT1.decodeToCut.json > $CONTRACT1.decodeToCut2.json
head -12 $CONTRACT1.decodeToCut2.json > $CONTRACT1.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS setShoppingListCode $CONTRACT1.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json # 1>/dev/null

echo "Done! Deployed debot with address: $DEBOT_ADDRESS"
