pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameUnit.sol";


contract WarGameWarrior is WarGameUnit {

    int32 static exampleID;

    constructor(uint playerPubkey, address yourBaseAddr, address Storage_Addr) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        Storage_Addr;
        BaseAddr = yourBaseAddr;
        objInfo = Information( 
            exampleID,
            "Warrior",
            address(this),
            playerPubkey,
            10,
            6,
            2);
          
        IWarGameBase(BaseAddr).addUnit(objInfo);   
    }
    
      
}

