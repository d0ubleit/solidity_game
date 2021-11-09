pragma ton-solidity >= 0.6;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "IWarGameObj.sol";

contract WarGameObj is IWarGameObj {

    int public objHealth = 10;
    uint objDefenceVal = 0;
    address[] public attackersArr;
    
    constructor() public {
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        
    } 

    modifier checkOwnerAndAccept {
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        _;
    }

    function acceptAttack(address aimAddr, uint enemyAttackVal) external override {
        tvm.accept();
        address enemyAddr = msg.sender;
        attackersArr.push(msg.sender);
        if (enemyAttackVal > objDefenceVal) {
            objHealth -= int(enemyAttackVal) - int(objDefenceVal);
        }
        if (checkObjIsDead()) {
            deathProcessing(enemyAddr);
        }
    }

    function setDefenceVal(uint _objDefenceVal) public checkOwnerAndAccept {
        objDefenceVal = _objDefenceVal;
    }

    function checkObjIsDead() private returns(bool) {
        tvm.accept();
        if (objHealth <= 0) {
            return true;
        }
        else {
            return false;
        }
    }

    function deathProcessing(address _enemyAddr) internal virtual {
        tvm.accept();
        destroyAndTransfer(_enemyAddr);  
    } 

    function destroyAndTransfer(address _enemyAddr) internal {
        tvm.accept();
        _enemyAddr.transfer(1, true, 160); 
    }


} 

