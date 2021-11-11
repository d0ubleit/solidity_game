pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameStructs.sol";
import "IWarGame_interfaces.sol";


contract WarGameStorage {
    
    // struct GameStat {
    // int32 basesAlive;

    GameStat Stat;
    mapping(uint => address) playersAlive;
    
    function getMap(address Storage) public {
        tvm.accept();
        playersAlive = IWarGameStorage(Storage).getPlayersAliveList();
    } 


} 