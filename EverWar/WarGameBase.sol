pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameObj.sol";
//import "WarGameStructs.sol";
import "AWarGameExample.sol";
//import "WarGameUnit.sol" as WGUnit;
//import "WarGameWarrior.sol" as WGW;
    

contract WarGameBase is WarGameObj { 
    
    //FOR DEBUG ONLY
    uint SomeSalt = 1234;
    uint SomeSalt2 = 1234;
    uint SomeSalt3 = 1234;
    uint SomeSalt4 = 1234;


    int32 static exampleID;
    int32 public warriorID = 1; 
    //address rootWarrior;
    int32 unitID = 1;

    mapping(address => int32) public UnitsMap;
    mapping (int32 => Information) public UnitsInfo;
        
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

    function updateUnitsInfo(Information unitInform) external {
        tvm.accept();
        require(UnitsMap.exists(msg.sender), 105, "Error: This unit not associated with this base");
        UnitsInfo[UnitsMap[msg.sender]] = unitInform;
    } 

    function getUnitsInfo() external responsible returns(mapping(int32 => Information) _UnitsInfo) {
        tvm.accept();
        //mapping(int32 => Information) _UnitsInfo = UnitsInfo;
        //return _UnitsInfo; 
        _UnitsInfo = UnitsInfo;
    } 

    // function getUnitsInfo() external responsible returns(uint incstore) {
    //     tvm.accept();
    //     return 777; 
    // }

    function addUnit(Information _objInfo) external {
        tvm.accept();
        UnitsMap.add(msg.sender, unitID);
        UnitsInfo[unitID] = _objInfo;
        unitID++;
    }

    function removeWarUnit() external {
        require(UnitsMap.exists(msg.sender), 102, "Error: This unit not associated with this base");
        tvm.accept();
        delete UnitsInfo[UnitsMap[msg.sender]];
        delete UnitsMap[msg.sender];   
    } 

    function deathProcessing(address _enemyAddr) internal override { 
        tvm.accept(); 
        //mapping(address => bool) TempMap = UnitsMap;
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
    function onAcceptAttack() internal override{
    }
    
}
