pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameStructs.sol";


contract WarGameStorage {
    
    address public WGBMain_Addr;

    GameStat Stat;
    mapping(uint => int32) playersAliveList; 
    mapping (int32 => address) playersIDList;
    int32 playerID = 1;
    address[] public incoming;
    uint[] public pubs;

    constructor(address _WGBMain_Addr) public {        
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        WGBMain_Addr = _WGBMain_Addr;
        tvm.accept();       
    } 

    function addToPlayersAliveList(uint playerPubkey, address Base_Addr) external {
        tvm.accept();
        playersAliveList[playerPubkey] = playerID;
        playersIDList[playerID] = Base_Addr;
        playerID++;
        Stat.basesAlive++;
        incoming.push(msg.sender);
        pubs.push(msg.pubkey());
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

