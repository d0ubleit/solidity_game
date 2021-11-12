pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameUnit.sol";

contract WarGameWarrior is WarGameUnit {

    int32 static exampleID;
    string UnitName = "Warrior";
    uint SomeSalt = 1234;

    constructor(uint playerPubkey, address yourBaseAddr) WarGameUnit(playerPubkey, yourBaseAddr) public {
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
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
    
    // function selfProduceWarrior(uint _warriorID, uint senderPubkey) external responsible returns(address) {
    //     tvm.accept();
    //     TvmCell code = tvm.code();
    //     address newWarrior = new WarGameWarrior{
    //         value: 2 ton,
    //         code: code,
    //         pubkey: senderPubkey,
    //         bounce: false,
    //         varInit: {
    //             warriorID: _warriorID
    //         }
    //     }(msg.sender);
    //     return newWarrior; 
    // } 








    // function produceWarrior() external returns(address newWarrior) {
    //     tvm.accept();
    //     TvmCell code = tvm.code();
    //     newWarrior = new WarGameWarrior{
    //         value: 10 ton,
    //         code: code,
    //         pubkey: tvm.pubkey(),
    //         bounce: false,
    //         varInit: {
    //             warriorID: warriorID + 1
    //         }
    //     }(msg.sender);
    //    // warriorCnt++;
    //  } 


  
}

