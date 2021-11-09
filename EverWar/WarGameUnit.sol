pragma ton-solidity >= 0.6;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "WarGameObj.sol";
import "WarGameBase.sol";

contract WarGameUnit is WarGameObj {

    address public BaseAddr; 
    uint objAttackVal;

    constructor(address yourBaseAddr) public {
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        BaseAddr = yourBaseAddr;
        //WarGameBase(BaseAddr).addWarUnit();
    }  

    function setAttackVal(uint _objAttackVal) public checkOwnerAndAccept {
        objAttackVal = _objAttackVal;
    }

    function attackEnemy(address _aimAddr) public checkOwnerAndAccept{
        IWarGameObj(_aimAddr).acceptAttack(_aimAddr, objAttackVal);  
    }

    function deathOfBase(address _enemyAddr) external {
        require(msg.sender == BaseAddr, 102, "Error: Call from base, which is not owner of this unit");
        tvm.accept();
        deathProcessing(_enemyAddr);
    }

    function deathProcessing(address _enemyAddr) internal override {
        tvm.accept();
        WarGameBase(BaseAddr).removeWarUnit();
        destroyAndTransfer(_enemyAddr);  
    }  



}
