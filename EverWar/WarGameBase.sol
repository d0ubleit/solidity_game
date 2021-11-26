pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameObj.sol";
import "AWarGameExample.sol";
    

contract WarGameBase is WarGameObj { 
    
    int32 static exampleID;
    
    address Storage_Addr_;
    address WGBot_Addr;

    mapping(address => int32) public UnitsMap;
    mapping(int32 => Information) public UnitsInfo;
    mapping(int32 => RecievedAttacksHistory) RxAttacksInfo;
    int32 AttacksCnt;    
        
    constructor(uint playerPubkey, address playerBaseAddr, address Storage_Addr) public { 
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
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
        require(UnitsMap.exists(msg.sender), 105, "Error: This unit not associated with this base");
        tvm.accept();
        UnitsInfo[UnitsMap[msg.sender]] = _objInfo;
        AttacksCnt++;
        RxAttacksInfo[AttacksCnt] = RecievedAttacksHistory(enemyPubkey, damage, UnitsMap[msg.sender], UnitsInfo[UnitsMap[msg.sender]].itemType, true);
        
    } 

    function getInfos() external view responsible returns(mapping(int32 => Information) _UnitsInfo, mapping(int32 => RecievedAttacksHistory) _RxAttacksInfo ) {
        tvm.accept();
        _UnitsInfo = UnitsInfo;
        _RxAttacksInfo = RxAttacksInfo;
    } 

    
    function addUnit(Information _objInfo) external {
        tvm.accept();
        UnitsMap.add(msg.sender, _objInfo.itemID);
        UnitsInfo[_objInfo.itemID] = _objInfo;
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
        for ((address unitAddr, ) : UnitsMap) {
            IWarGameUnit(unitAddr).deathOfBase(_enemyAddr);
        }
        uint playerPubkey = objInfo.itemOwnerPubkey;
        IWarGameStorage(Storage_Addr_).removeFromPlayersAliveList(playerPubkey);
        
        delete UnitsMap;
        delete UnitsInfo;

        destroyAndTransfer(_enemyAddr);   
    }  

    function onAcceptAttack(uint enemyPubkey, int32 damage) internal override{
        UnitsInfo[objInfo.itemID].itemHealth = objInfo.itemHealth;
        AttacksCnt++;
        RxAttacksInfo[AttacksCnt] = RecievedAttacksHistory(enemyPubkey, damage, objInfo.itemID, objInfo.itemType, true); 
        
    }
    
}
