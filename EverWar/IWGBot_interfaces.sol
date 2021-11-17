pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameStructs.sol";

interface IWGBot_deployer {

    function invokeProduce(uint _playerPubkey, DeployType _deployType) external;
} 

interface IWGBot_initial {
    function deployResult(Status _status, DeployType _deployType, address _Produce_Addr) external;
} 
