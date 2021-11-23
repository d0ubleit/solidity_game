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
    
    int32 static exampleID;
    
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
        
        UnitsInfo[0] = objInfo;
    } 

    function updateUnitsInfo(Information _objInfo) external {
        tvm.accept();
        require(UnitsMap.exists(msg.sender), 105, "Error: This unit not associated with this base");
        UnitsInfo[UnitsMap[msg.sender]] = _objInfo;
    } 

    function getUnitsInfo() external responsible returns(mapping(int32 => Information) _UnitsInfo) {
        tvm.accept();
        //mapping(int32 => Information) _UnitsInfo = UnitsInfo;
        //return _UnitsInfo; 
        _UnitsInfo = UnitsInfo;
    } 

    // function getUnitInfoByAddr(address _unitAddr) external returns(Information _unitInfo) {
    //     require(UnitsMap.exists(_unitAddr), 107, "Error: There are no unit with such ID");
    //     tvm.accept();
    //     //mapping(int32 => Information) _UnitsInfo = UnitsInfo;
    //     //return _UnitsInfo; 
    //     Information _unitInfo = UnitsInfo[UnitsMap[_unitAddr]];
    //     return _unitInfo;
    // }

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
        //mapping(address => int32) TempMap = UnitsMap;
        for ((address unitAddr, ) : UnitsMap) {
            IWarGameUnit(unitAddr).deathOfBase(_enemyAddr);
        }
        unitID = 1;
        delete UnitsMap;
        delete UnitsInfo;
        delete thisPubkey;
        destroyAndTransfer(_enemyAddr);   
    }  

    function onAcceptAttack() internal override{
        UnitsInfo[0].itemHealth = objInfo.itemHealth;
    }
    
}
