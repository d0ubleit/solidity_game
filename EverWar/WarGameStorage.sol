pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameStructs.sol";


contract WarGameStorage {
    
    // struct GameStat {
    // int32 basesAlive;
    address public WGBMain_Addr;

    GameStat Stat;
    mapping(uint => int32) playersAliveList; 
    mapping (int32 => address) playersIDList;
    int32 playerID = 1;

    constructor(address _WGBMain_Addr) public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        WGBMain_Addr = _WGBMain_Addr;
        tvm.accept();       
    } 

    modifier onlyWGBMain {
        //require(msg.sender == WGBMain_Addr, 103);
        _;
    }


    function addToPlayersAliveList(uint playerPubkey, address Base_Addr) onlyWGBMain external {
        tvm.accept();
        playersAliveList[playerPubkey] = playerID;
        playersIDList[playerID] = Base_Addr;
        playerID++;
        Stat.basesAlive++;
    }

    function removeFromPlayersAliveList(uint playerPubkey) external {
        require(playersAliveList.exists(playerPubkey), 116, "This player has no kingdom in storage");
        require(msg.sender == playersIDList[playersAliveList[playerPubkey]], 116, "This player has no kingdom in storage");
        tvm.accept();
        
        delete playersIDList[playersAliveList[playerPubkey]];
        delete playersAliveList[playerPubkey];
        Stat.basesAlive--;
        
    } 
    
    function getStat() external view returns(GameStat){
        tvm.accept(); 
        return Stat;
    }

    function getPlayersAliveList() external view returns(mapping(uint => int32), mapping (int32 => address)){
        tvm.accept();
        return(playersAliveList, playersIDList); 
    }


} 

