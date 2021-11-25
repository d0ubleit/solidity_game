pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameUnit.sol";
import "IWarGame_interfaces.sol";

contract WarGameScout is WarGameUnit {

    int32 static exampleID;
    string UnitName = "Scout";
    address public nowEnemy;

    uint public store;
    //mapping (int32 => Information) public UnitsInfo; 
    mapping (address => mapping ( int32 => Information )) public ScoutedInfo; 



    constructor(uint playerPubkey, address yourBaseAddr, address Storage_Addr) public {
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
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

    function getEnemyUnitsInfo(address enemyAddr) external {
        tvm.accept();
        nowEnemy = enemyAddr;
        optional(uint256) none;
        IWarGameBase(enemyAddr).getInfos{ 
        //    value: 1 ton, 
            callback: WarGameScout.setEnemyUnitsInfo 
        }();
        // IWarGameBase(nowEnemy).getUnitsInfo{
        //     abiVer: 2,
        //     extMsg: true,
        //     sign: false,
        //     pubkey: none, 
        //     time: uint64(now),
        //     expire: 0,
        //     callbackId: tvm.functionId(setEnemyUnitsInfo), 
        //     onErrorId: 0
        // }();
    }

    function setEnemyUnitsInfo(mapping(int32 => Information) _UnitsInfo, mapping(int32 => RecievedAttacksHistory) _RxAttacksInfo) public {
        tvm.accept();
        //UnitsInfo = _UnitsInfo;
        ScoutedInfo[nowEnemy] = _UnitsInfo; 
    }

    // function setA() public {
    //     tvm.accept();
    //     ScoutedInfo[nowEnemy] = UnitsInfo;
    // }

    
    // function setB() public {
    //     tvm.accept();
    //     for ((int32 key, Information Uinfo) : UnitsInfo) {
    //         ScoutedInfo[nowEnemy][key]=Uinfo;
    //     } 
    // }
    // function setEnemyUnitsInfo(uint incstore) public {
    //     tvm.accept();
    //     store = incstore; 
    // }

    function getScoutedInfo() public returns(mapping(address => mapping (int32 => Information))) {
        tvm.accept();
        return (ScoutedInfo); 
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

