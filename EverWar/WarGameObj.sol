pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "IWarGameObj.sol";

contract WarGameObj is IWarGameObj {

    uint32 public objHealth = 10;
    int32 objDefenceVal = 2;
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

    function acceptAttack(address aimAddr, int32 _objAttackVal) external override {
        tvm.accept();
        address enemyAddr = msg.sender;
        attackersArr.push(msg.sender);
        if (_objAttackVal > objDefenceVal) {
            objHealth -= uint32(_objAttackVal) - uint32(objDefenceVal);  
        }
        if (checkObjIsDead()) {
            deathProcessing(enemyAddr);
        }
    }

    function setDefenceVal(int32 _objDefenceVal) public checkOwnerAndAccept {
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

