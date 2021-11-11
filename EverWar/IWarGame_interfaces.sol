pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameStructs.sol";

interface IWarGameObj {
    function acceptAttack(address aimAddr, int32 _objAttackVal) external;

    function getInfo() external returns(Information);
} 

interface IWarGameStorage {
    function addToPlayersAliveList(uint playerPubkey, address Base_Addr) external;

    function removeFromPlayersAliveList(uint playerPubkey) external; 
    
    function getStat() external view returns(GameStat);

    function getPlayersAliveList() external view returns(mapping(uint => address));
} 