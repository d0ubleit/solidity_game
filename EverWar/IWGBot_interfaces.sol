pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameStructs.sol";

interface IWGBot_deployer {

    function invokeDeployer_start(uint _playerPubkey, DeployType _deployType, address _Base_Addr, address _Storage_Addr, int32 _mainUnitID) external;
} 

interface IWGBot_initial {
    function deployResult(Status _status, DeployType _deployType, address _Produce_Addr) external;

    function goKingdomMenu() external;

    function updateUnitsInfo() external;

    //function checkAccStatus(address _Produce_Addr) external; 
} 

interface IWGBot_Units {
    function invokeSendScout(uint256 _playerPubkey, mapping(int32 => address) _playersIDList, address _Scout_Addr) external;

    function invokeSendAttack(uint256 _playerPubkey, mapping(int32 => Information) _UnitsInfo) external;
}
