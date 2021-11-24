pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

abstract contract AWarGameExample {

    int32 static exampleID;

    constructor(uint256 playerPubkey, address playerBaseAddr, address Storage_Addr) public {
    }
}