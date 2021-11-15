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

interface IWarGameBase {
    function addUnit(Information _objInfo) external;

    function updateUnitsInfo(Information _objInfo) external;

    function getUnitsInfo() external responsible returns(mapping(int32 => Information) _UnitsInfo);

    // function getUnitsInfo() external responsible returns(uint incstore);

    function removeWarUnit() external;
}

interface IWarGameUnit {
    function attackEnemy(address _aimAddr) external;

} 

interface IWarGameScout {
    function getEnemyUnitsInfo(address enemyAddr) external;

     function getScoutedInfo() external returns(mapping(address => mapping (int32 => Information)));
}