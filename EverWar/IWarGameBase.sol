pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameStructs.sol";

interface IWarGameBase {
    function getInfo() external returns(Information);
}
