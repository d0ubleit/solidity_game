#!/bin/bash
set -e

if [[ $1 != *".sol"  ]] ; then 
    echo "ERROR: contract file name .sol required!"
    echo ""
    echo "USAGE:"
    echo "  ${0} <debot>.sol <BASE>.sol <network>"
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
    echo "  ${0} <debot>.sol <BASE>.sol <network>"
    echo "      NETWORK  - optional, network endpoint, default is http://127.0.0.1"
    echo ""
    echo "PRIMER:"
    echo "  ${0} mydebot.sol mycontract.sol https://net.ton.dev"
    exit 1
fi

DEBOT_NAME=${1%.*} # filename without extension
BASE=${2%.*} # filename without extension
WARRIOR=${3%.*} # filename without extension
STORAGE_NAME=${4%.*} # filename without extension
NETWORK="${5:-http://127.0.0.1}"


echo $DEBOT_NAME
echo $BASE
echo $WARRIOR
echo $NETWORK
echo $STORAGE_NAME
#
# This is TON OS SE giver address, correct it if you use another giver
#
GIVER_ADDRESS=0:b5e9240fc2d2f1ff8cbb1d1dee7fb7cae155e5f6320e585fcc685698994a19a5

# net.ton.dev 
#GIVER_ADDRESS=0:a532822fe755b19792cca1c26c705984ba18786d8048bd36d50c7664ec9089c0


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

function genaddrStorage {
    $tos genaddr $1.tvc $1.abi.json --setkey $2.keys.json > $1.log
}

echo "Step 0. Compiling"
tondev sol compile $DEBOT_NAME.sol
tondev sol compile $BASE.sol
tondev sol compile $WARRIOR.sol
tondev sol compile $STORAGE_NAME.sol

echo "Step 1. Calculating debot address"
genaddr $DEBOT_NAME
DEBOT_ADDRESS=$(get_address $DEBOT_NAME)

echo "Step 2. Calculating storage address"
genaddrStorage $STORAGE_NAME $DEBOT_NAME
STORAGE_ADDRESS=$(get_address $STORAGE_NAME)

echo "Step 3. Sending tokens to storage address: $STORAGE_ADDRESS"
giver $STORAGE_ADDRESS
echo success

echo "Step 4. Deploying storage contract"
$tos --url $NETWORK deploy $STORAGE_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $STORAGE_NAME.abi.json 1>/dev/null

echo "Step 5. Sending tokens to address: $DEBOT_ADDRESS"
giver $DEBOT_ADDRESS
echo success
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)

echo "Step 6. Deploying debot"
$tos --url $NETWORK deploy $DEBOT_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null

echo "Set ABI"
$tos --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null
echo "Success"

echo "Set storage address to debot"
$tos --url $NETWORK call $DEBOT_ADDRESS setStorageAddr "{\"storageAddress\":\"$STORAGE_ADDRESS\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null
echo "Success"

echo "Step 7. Set code for WGBase contract"
#todo_code=$(base64 -w 0 todo.tvc)
$tos decode stateinit $BASE.tvc --tvc > $BASE.decodeToCut.json
#tail -12 $BASE.decodeToCut.json > $BASE.decode.json
tail -12 $BASE.decodeToCut.json > $BASE.decodeToCut2.json
head -12 $BASE.decodeToCut2.json > $BASE.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS setWGBaseCode $BASE.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json  1>/dev/null
echo "Success"

echo "Step 8. Set code for WGWarrior contract"
$tos decode stateinit $WARRIOR.tvc --tvc > $WARRIOR.decodeToCut.json
#tail -12 $BASE.decodeToCut.json > $BASE.decode.json
tail -12 $WARRIOR.decodeToCut.json > $WARRIOR.decodeToCut2.json
head -12 $WARRIOR.decodeToCut2.json > $WARRIOR.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS setWGWarriorCode $WARRIOR.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json  1>/dev/null
echo "Success"
echo "Done! Deployed storage with address: $STORAGE_ADDRESS"
echo "Done! Deployed debot with address: $DEBOT_ADDRESS"

#$tos --url $NETWORK debot fetch $DEBOT_ADDRESS
#tonos-cli --url http://127.0.0.1 debot fetch 0:69a7a3d7c28c7fb5c8895cd8398fe65dbc468b29c0153b7602ae9e6126e07f9d

#  "pubkey" : "99c84f920c299b5d80e4fcce2d2054b05466ec9df19532a688c10eb6dd8d6b33",
#  "address" : "0:d5f5cfc4b52d2eb1bd9d3a8e51707872c7ce0c174facddd0e06ae5ffd17d2fcd",
#  "seed phrase" : "fan harsh baby section father problem person void depth already powder chicken"
