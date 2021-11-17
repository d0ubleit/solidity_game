pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "WarGameStructs.sol";
import "IWarGame_interfaces.sol";


contract test {
    
    // struct GameStat {
    // int32 basesAlive;
    Status public status;
    GameStat Stat;
    mapping(uint => address) playersAlive;
    
    // function getMap(address Storage) public {
    //     tvm.accept();
    //     playersAlive = IWarGameStorage(Storage).getPlayersAliveList();
    // } 
    function getStatus() public returns(Status){
        tvm.accept();
        return status;
    }

    function setStatus() public {
        tvm.accept();
        status = Status.Success;
    }

} 