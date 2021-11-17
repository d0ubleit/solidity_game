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
DEBOT_NAME2=${2%.*} # filename without extension
STORAGE_NAME=${3%.*} # filename without extension
BASE=${4%.*} # filename without extension
WARRIOR=${5%.*} # filename without extension
SCOUT=${6%.*} # filename without extension
NETWORK="${7:-http://net.ton.dev}"


echo $DEBOT_NAME
echo $DEBOT_NAME2
echo $STORAGE_NAME
echo $BASE
echo $WARRIOR
echo $SCOUT
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

function genaddr_setkey {
    $tos genaddr $1.tvc $1.abi.json --setkey $2.keys.json > $1.log
}

echo "Step 0. Compiling"
tondev sol compile $DEBOT_NAME.sol
tondev sol compile $DEBOT_NAME2.sol
tondev sol compile $STORAGE_NAME.sol
tondev sol compile $BASE.sol
tondev sol compile $WARRIOR.sol
tondev sol compile $SCOUT.sol


echo "Step 1. Calculating debots address"
genaddr $DEBOT_NAME
DEBOT_ADDRESS=$(get_address $DEBOT_NAME)

genaddr_setkey $DEBOT_NAME2 $DEBOT_NAME
DEBOT_ADDRESS2=$(get_address $DEBOT_NAME2)


echo "Step 2. Calculating storage address"
genaddr_setkey $STORAGE_NAME $DEBOT_NAME
STORAGE_ADDRESS=$(get_address $STORAGE_NAME)


echo "Step 3. Sending tokens to storage address: $STORAGE_ADDRESS"
giver $STORAGE_ADDRESS


echo "Step 4. Deploying storage contract"
$tos --url $NETWORK deploy $STORAGE_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $STORAGE_NAME.abi.json 1>/dev/null


echo "Step 5. Sending tokens to debot1 address: $DEBOT_ADDRESS"
giver $DEBOT_ADDRESS


echo "Step 6. Deploying debot1"
$tos --url $NETWORK deploy $DEBOT_NAME.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null

echo "Creating ABI"
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)
echo "Success"

echo "Set ABI"
$tos --url $NETWORK call $DEBOT_ADDRESS setABI "{\"dabi\":\"$DEBOT_ABI\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null
echo "Success"

echo "Set storage address and debot2 address to debot1"
$tos --url $NETWORK call $DEBOT_ADDRESS setAddreses "{\"storageAddress\":\"$STORAGE_ADDRESS\",\"wgBot_deployerAddr\":\"$DEBOT_ADDRESS2\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME.abi.json 1>/dev/null
echo "Success"


echo "Step 7. Sending tokens to debot2 address: $DEBOT_ADDRESS2"
giver $DEBOT_ADDRESS2


echo "Step 8. Deploying debot2"
$tos --url $NETWORK deploy $DEBOT_NAME2.tvc "{}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME2.abi.json 1>/dev/null

echo "Creating ABI"
DEBOT_ABI2=$(cat $DEBOT_NAME2.abi.json | xxd -ps -c 20000)
echo "Success"

echo "Set ABI"
$tos --url $NETWORK call $DEBOT_ADDRESS2 setABI "{\"dabi\":\"$DEBOT_ABI2\"}" \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME2.abi.json 1>/dev/null
echo "Success"


echo "Step 9. Setting conracts codes"
echo "Set code for WGBase contract"
#todo_code=$(base64 -w 0 todo.tvc)
$tos decode stateinit $BASE.tvc --tvc > $BASE.decodeToCut.json
#tail -12 $BASE.decodeToCut.json > $BASE.decode.json
tail -12 $BASE.decodeToCut.json > $BASE.decodeToCut2.json
head -12 $BASE.decodeToCut2.json > $BASE.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS2 setWGBaseCode $BASE.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME2.abi.json  1>/dev/null
echo "Success"

echo "Set code for WGWarrior contract"
$tos decode stateinit $WARRIOR.tvc --tvc > $WARRIOR.decodeToCut.json
#tail -12 $BASE.decodeToCut.json > $BASE.decode.json
tail -12 $WARRIOR.decodeToCut.json > $WARRIOR.decodeToCut2.json
head -12 $WARRIOR.decodeToCut2.json > $WARRIOR.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS2 setWGWarriorCode $WARRIOR.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME2.abi.json  1>/dev/null
echo "Success"

echo "Set code for WGScout contract"
$tos decode stateinit $SCOUT.tvc --tvc > $SCOUT.decodeToCut.json
#tail -12 $BASE.decodeToCut.json > $BASE.decode.json
tail -12 $SCOUT.decodeToCut.json > $SCOUT.decodeToCut2.json
head -12 $SCOUT.decodeToCut2.json > $SCOUT.decode.json

$tos --url $NETWORK call $DEBOT_ADDRESS2 setWGScoutCode $SCOUT.decode.json \
    --sign $DEBOT_NAME.keys.json \
    --abi $DEBOT_NAME2.abi.json  1>/dev/null
echo "Success"
echo "Done! Deployed storage with address: $STORAGE_ADDRESS"
echo "Done! Deployed debot1 with address: $DEBOT_ADDRESS"
echo "Done! Deployed debot2 with address: $DEBOT_ADDRESS2"

#tonos-cli --url http://net.ton.dev call 0:6d9ac12edc0aaded6562aacf11be38e1158e867396ab20d57193faf851a0abad getUnitsInfo '{}' --sign WGBot_Basics.keys.json --abi WarGameBase.abi.json