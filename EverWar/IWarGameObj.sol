pragma ton-solidity >= 0.6;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

interface IWarGameObj {
    function acceptAttack(address aimAddr, uint _objAttackVal) external;
}
