pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameStructs.sol";

interface IWarGameObj {
    function acceptAttack(address aimAddr, int32 _objAttackVal, uint _playerPubkey) external;

    function getInfo() external returns(Information);
} 

interface IWarGameStorage {
    function addToPlayersAliveList(uint playerPubkey, address Base_Addr) external;

    function removeFromPlayersAliveList(uint playerPubkey) external; 
    
    function getStat() external view returns(GameStat);

    function getPlayersAliveList() external view returns(mapping(uint => int32), mapping (int32 => address));
} 

interface IWarGameBase {
    function addUnit(Information _objInfo) external;

    function updateUnitsInfo(Information _objInfo, uint enemyPubkey, int32 damage) external;

    function getInfos() external responsible returns(mapping(int32 => Information) _UnitsInfo, mapping(int32 => RecievedAttacksHistory) _RxAttacksInfo);

    //function getUnitInfoByAddr(address _unitAddr) external returns(Information _unitInfo);
    
    function removeWarUnit(uint enemyPubkey, int32 damage) external;
}

interface IWarGameUnit {
    function attackEnemy(address _aimAddr) external;

    function deathOfBase(address _enemyAddr) external;

} 

interface IWarGameScout {
    function getEnemyUnitsInfo(address enemyAddr) external;

     function getScoutedInfo() external returns(mapping(address => mapping (int32 => Information)));
}