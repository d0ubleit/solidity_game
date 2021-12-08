pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

contract Wallet {

    uint m_ownerKey;

    constructor(uint pubKey) public {
        tvm.accept();
        m_ownerKey = pubKey;
    } 

 function sendTransaction(
        address dest,
        uint128 value,
        bool bounce,
        uint8 flags,
        TvmCell payload) public
    {
        //require(m_custodianCount == 1, 108);
        require(msg.pubkey() == m_ownerKey, 100);
        tvm.accept();
        dest.transfer(value, bounce, flags, payload);
    }
}