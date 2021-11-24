pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameStructs.sol";


contract WarGameStorage {
    
    // struct GameStat {
    // int32 basesAlive;

    GameStat Stat;
    mapping(uint => int32) playersAliveList; 
    mapping (int32 => address) playersIDList;
    int32 playerID = 1;

    constructor() public {
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();       
    } 

    // modifier checkOwnerAndAccept {
    //     //require(msg.pubkey() == tvm.pubkey(), 102);
    //     tvm.accept();
    //     _;
    // }


    function addToPlayersAliveList(uint playerPubkey, address Base_Addr) external {
        tvm.accept();
        playersAliveList[playerPubkey] = playerID;
        playersIDList[playerID] = Base_Addr;
        playerID++;
        Stat.basesAlive++;
    }

    function removeFromPlayersAliveList(uint playerPubkey) external {
        require(playersAliveList.exists(playerPubkey), 116, "This player has no kingdom in storage");
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

