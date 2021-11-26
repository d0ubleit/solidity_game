pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameUnit.sol";
import "IWarGame_interfaces.sol";


contract WarGameScout is WarGameUnit {

    int32 static exampleID;
    address nowEnemy;
 
    mapping (address => mapping ( int32 => Information )) public ScoutedInfo; 


    constructor(uint playerPubkey, address yourBaseAddr, address Storage_Addr) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        Storage_Addr;
        BaseAddr = yourBaseAddr;
        objInfo = Information( 
            exampleID,
            "Scout",
            address(this),
            playerPubkey,
            5,
            1,
            0);
          
        IWarGameBase(BaseAddr).addUnit(objInfo);   
    }


    function getEnemyUnitsInfo(address enemyAddr) onlyOwner external {
        tvm.accept();
        nowEnemy = enemyAddr;
        optional(uint256) none;
        IWarGameBase(enemyAddr).getInfos{ 
            callback: WarGameScout.setEnemyUnitsInfo 
        }();
        
    }


    function setEnemyUnitsInfo(mapping(int32 => Information) _UnitsInfo, mapping(int32 => RecievedAttacksHistory) _RxAttacksInfo) public {
        require(msg.sender == nowEnemy, 121, "Error: request not from enemy addr");
        tvm.accept();
        ScoutedInfo[nowEnemy] = _UnitsInfo; 
        _RxAttacksInfo;
    }

    
    function getScoutedInfo() public view returns(mapping(address => mapping (int32 => Information))) {
        tvm.accept();
        return (ScoutedInfo); 
    }
  
}

