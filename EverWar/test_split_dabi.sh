#!/bin/bash
set -e

echo "Creating ABI"
DEBOT_ABI=$(cat $DEBOT_NAME.abi.json | xxd -ps -c 20000)
#DEBOT_ABI="12345678901"
echo $DEBOT_ABI > $DEBOT_ABI.full.dabi.txt
# cat WGBot_Units.abi.json | xxd -ps -c 20000 > WGBot_Units.dabi.log
echo "Success"

echo "Splitting ABI"
ABI_LEN=$(echo -n "$DEBOT_ABI" | wc -c)
ABI_HALF1=$((($ABI_LEN/2)+($ABI_LEN%2)))
ABI_HALF2=$(($ABI_LEN/2))
echo $ABI_HALF1
echo $ABI_HALF2


DABI_PT1=${DEBOT_ABI::-$ABI_HALF1}
DABI_PT2=${DEBOT_ABI:$ABI_HALF2}
echo $DABI_PT1 
echo $DABI_PT2