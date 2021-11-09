pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

interface IWarGameObj {
    function acceptAttack(address aimAddr, int32 _objAttackVal) external;
}
