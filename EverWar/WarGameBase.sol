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
    
    //int32 unitID = 1;
    address Storage_Addr_;
    address public WGBot_Addr;

    mapping(address => int32) public UnitsMap;
    mapping(int32 => Information) public UnitsInfo;
    mapping(int32 => RecievedAttacksHistory) RxAttacksInfo;
    int32 AttacksCnt;    
    
    
    constructor(uint playerPubkey, address playerBaseAddr, address Storage_Addr) public { 
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (WGBot_Addr) = optSalt.get().toSlice().decode(address);
        Storage_Addr_ = Storage_Addr;
        objInfo = Information(  
            exampleID,
            "Base",
            address(this),
            playerPubkey,
            15,  //25,
            0,
            3);
        
        UnitsInfo[0] = objInfo;
    } 

    function updateUnitsInfo(Information _objInfo, uint enemyPubkey, int32 damage) external { 
        tvm.accept();
        require(UnitsMap.exists(msg.sender), 105, "Error: This unit not associated with this base");
        UnitsInfo[UnitsMap[msg.sender]] = _objInfo;
        AttacksCnt++;
        RxAttacksInfo[AttacksCnt] = RecievedAttacksHistory(enemyPubkey, damage, UnitsMap[msg.sender], UnitsInfo[UnitsMap[msg.sender]].itemType, true);
        
    } 

    function getInfos() external responsible returns(mapping(int32 => Information) _UnitsInfo, mapping(int32 => RecievedAttacksHistory) _RxAttacksInfo ) {
        tvm.accept();
        //mapping(int32 => Information) _UnitsInfo = UnitsInfo;
        //return _UnitsInfo; 
        _UnitsInfo = UnitsInfo;
        _RxAttacksInfo = RxAttacksInfo;
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
        UnitsMap.add(msg.sender, _objInfo.itemID);
        UnitsInfo[_objInfo.itemID] = _objInfo;
        //unitID++;
    }

    function removeWarUnit(uint enemyPubkey, int32 damage) external {
        require(UnitsMap.exists(msg.sender), 102, "Error: This unit not associated with this base");
        tvm.accept();
        AttacksCnt++;
        RxAttacksInfo[AttacksCnt] = RecievedAttacksHistory(enemyPubkey, damage, UnitsMap[msg.sender], UnitsInfo[UnitsMap[msg.sender]].itemType, false);
        delete UnitsInfo[UnitsMap[msg.sender]]; 
        delete UnitsMap[msg.sender];   
    } 


    //What if balance is low?
    function deathProcessing(address _enemyAddr, uint enemyPubkey, int32 damage) internal override { 
        tvm.accept(); 
        //mapping(address => int32) TempMap = UnitsMap;
        for ((address unitAddr, ) : UnitsMap) {
            IWarGameUnit(unitAddr).deathOfBase(_enemyAddr);
        }
        uint playerPubkey = objInfo.itemOwnerPubkey;
        IWarGameStorage(Storage_Addr_).removeFromPlayersAliveList(playerPubkey);
        //unitID = 1;
        delete UnitsMap;
        delete UnitsInfo;
        //delete thisPubkey;
        destroyAndTransfer(_enemyAddr);   
    }  

    function onAcceptAttack(uint enemyPubkey, int32 damage) internal override{
        UnitsInfo[objInfo.itemID].itemHealth = objInfo.itemHealth;
        AttacksCnt++;
        RxAttacksInfo[AttacksCnt] = RecievedAttacksHistory(enemyPubkey, damage, objInfo.itemID, objInfo.itemType, true); 
        
    }
    
}
