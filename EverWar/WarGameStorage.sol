pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameStructs.sol";


contract WarGameStorage {
    
    // struct GameStat {
    // int32 basesAlive;

    GameStat Stat;
    mapping(uint => address) playersAliveList; 
    
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
        playersAliveList[playerPubkey] = Base_Addr;
        Stat.basesAlive++;
    }

    function removeFromPlayersAliveList(uint playerPubkey) external {
        tvm.accept();
        if (playersAliveList.exists(playerPubkey)){
            delete playersAliveList[playerPubkey];
            Stat.basesAlive--;
        }
    } 
    
    function getStat() external view returns(GameStat){
        tvm.accept(); 
        return Stat;
    }

    function getPlayersAliveList() external view returns(mapping(uint => address)){
        tvm.accept();
        return(playersAliveList);
    }


} 

