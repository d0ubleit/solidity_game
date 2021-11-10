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
CONTRACT2=${3%.*} # filename without extension
NETWORK="${4:-http://net.ton.dev}"


echo $DEBOT_NAME
echo $CONTRACT1
echo $CONTRACT2
echo $NETWORK
#
# This is TON OS SE giver address, correct it if you use another giver
#
#GIVER_ADDRESS=0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5

# net.ton.dev 
GIVER_ADDRESS=0:a532822fe755b19792cca1c26c705984ba18786d8048bd36d50c7664ec9089c0


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
        --abi ../debotBase/Mygiver.abi.json \
        --sign ../debotBase/Mygiver.keys.json \
        $GIVER_ADDRESS \
        sendTransactionSimple "{\"dest\":\"$1\",\"value\":2000000000}" \
        1>/dev/null
}

# tonos-cli --url https://net.ton.dev call 
# --abi ../Mygiver.abi.json 
# --sign ../Mygiver.keys.json 
# 0:a532822fe755b19792cca1c26c705984ba18786d8048bd36d50c7664ec9089c0 
# sendTransactionSimple "{\"dest\":\"0:6fe3571b2e6505f58d0237a3fd4cd090d62f0e86ce9c31a7b387cde89888b0b2\",\"value\":1000000000}"



function get_address {
    echo $(cat $1.log | grep "Raw address:" | cut -d ' ' -f 3)
}

function genaddr {
    $tos genaddr $1.tvc $1.abi.json --genkey $1.keys.json > $1.log
}

echo "Step 0. Compiling"
tondev sol compile $DEBOT_NAME.sol
tondev sol compile $CONTRACT1.sol
tondev sol compile $CONTRACT2.sol


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

echo "Success"
echo "Step 4. Set code for WGBase contract"

#todo_code=$(base64 -w 0 todo.tvc)
$tos decode stateinit $CONTRACT1.tvc --tvc > $CONTRACT1.decodeToCut.json
#tail -12 $CONTRACT1.decodeToCut.json > $CONTRACT1.decode.json
tail -12 $CONTRACT1.decodeToCut.json > $CONTRACT1.decodeToCut2.json
head -12 $CONTRACT1.decodeToCut2.json > $CONTRACT1.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS setWGBaseCode $CONTRACT1.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json  1>/dev/null

echo "Success"
echo "Step 5. Set code for WGWarrior contract"


$tos decode stateinit $CONTRACT2.tvc --tvc > $CONTRACT2.decodeToCut.json
#tail -12 $CONTRACT1.decodeToCut.json > $CONTRACT1.decode.json
tail -12 $CONTRACT2.decodeToCut.json > $CONTRACT2.decodeToCut2.json
head -12 $CONTRACT2.decodeToCut2.json > $CONTRACT2.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS setWGWarriorCode $CONTRACT2.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json  1>/dev/null

echo "Success"
echo "Done! Deployed debot with address: $DEBOT_ADDRESS"
