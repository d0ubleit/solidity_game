pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameObj.sol";

contract WarGameUnit is WarGameObj {

    address BaseAddr; 
    
    constructor() public {
        tvm.accept(); 
    }  

    ////////Later change it to upgrade attack func
    // function setAttackVal(int32 _objAttackVal) public onlyOwner {
    //     objInfo.itemAttack = _objAttackVal;  
    // }

    function attackEnemy(address _aimAddr) external onlyOwner{
        tvm.accept();
        uint _playerPubkey = objInfo.itemOwnerPubkey;
        IWarGameObj(_aimAddr).acceptAttack(_aimAddr, objInfo.itemAttack, _playerPubkey);  
    }

    function deathOfBase(address _enemyAddr) external {
        require(msg.sender == BaseAddr, 102, "Error: Call not from owner base");
        tvm.accept();
        destroyAndTransfer(_enemyAddr);
    }

    function deathProcessing(address _enemyAddr, uint enemyPubkey, int32 damage) internal override {
        tvm.accept();
        IWarGameBase(BaseAddr).removeWarUnit(enemyPubkey, damage); 
        destroyAndTransfer(_enemyAddr);  
    }  

    function onAcceptAttack(uint enemyPubkey, int32 damage) internal override{
        tvm.accept();
        Information _objInfo = objInfo;
        IWarGameBase(BaseAddr).updateUnitsInfo(_objInfo, enemyPubkey, damage);
    } 


}
