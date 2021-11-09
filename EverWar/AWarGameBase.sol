pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

abstract contract AWarGameBase {

    int32 static baseID;

    constructor(uint256 playerPubkey) public {
    }
}