pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameObj.sol";
import "WarGameStructs.sol";
import "AWarGameExample.sol";
//import "WarGameUnit.sol" as WGUnit;
//import "WarGameWarrior.sol" as WGW;
    

contract WarGameBase is WarGameObj {
    
    int32 static exampleID;
    int32 public warriorID = 1; 
    //address rootWarrior;
    
    mapping(address => bool) public UnitsMap; 
    uint public thisPubkey;
    

    //constructor(address _rootWarrior) public {
    constructor(uint playerPubkey, address playerBaseAddr) public { 
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        //rootWarrior = _rootWarrior;
        tvm.accept();
        objInfo = Information( 
            exampleID,
            "Base",
            address(this),
            playerPubkey,
            25,
            0,
            3);
        
        thisPubkey = tvm.pubkey();
        
    } 

    // function addWarrior(address _warriorAddr) internal {
    //     tvm.accept();
    //     UnitsMap.add(_warriorAddr, true); 
    // }

    function removeWarUnit() external {
        require(UnitsMap.exists(msg.sender), 102, "Error: This unit not associated with this base");
        tvm.accept();
        delete UnitsMap[msg.sender];   
    } 

    function deathProcessing(address _enemyAddr) internal override { 
        tvm.accept(); 
        mapping(address => bool) TempMap = UnitsMap;
        // for ((address UnitAddr, ) : TempMap) {
        //     WGUnit.WarGameUnit(UnitAddr).deathOfBase(_enemyAddr);
        // }
        destroyAndTransfer(_enemyAddr);   
    }  

    // function produceWarrior() public {
    //     require(tvm.pubkey() == msg.pubkey(), 102, "Error: You already have base!");
    //     tvm.accept();         
    //     address newWarrior;
    //     //newWarrior = WGW.WarGameWarrior(rootWarrior).selfProduceWarrior(warriorID, tvm.pubkey()).await;
    //     addWarrior(newWarrior);
    //     warriorID++;
    // }
    
    // function selfProduceBase(uint _baseID, uint senderPubkey) external responsible returns(address) {
    //     tvm.accept();
    //     TvmCell code = tvm.code();
    //     address newBase = new WarGameBase{
    //         value: 2 ton,
    //         code: code,
    //         pubkey: senderPubkey,
    //         bounce: false,
    //         varInit: {
    //             baseID: _baseID
    //         }
    //     }(rootWarrior);
    //     tvm.accept();
    //     return newBase; 
    // } 

    
}
