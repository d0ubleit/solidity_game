pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

abstract contract AWarGameWarrior {

    int32 static warriorID;

    constructor(uint256 playerPubkey) public {
    }
}