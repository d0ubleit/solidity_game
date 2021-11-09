pragma ton-solidity >= 0.6;
pragma AbiHeader expire;
import "IWarGameObj.sol";

contract testAttack {

    constructor() public {
        require(tvm.pubkey() != 0, 101);
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
       
    } 

    modifier checkOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function attackEnemy(IWarGameObj IExample, address _enemyAddr, uint _objAttackVal) public {
        tvm.accept();
        IExample.acceptAttack(_enemyAddr, _objAttackVal); 
    }
} 