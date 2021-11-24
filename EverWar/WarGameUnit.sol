pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
import "WarGameObj.sol";
//import "IWarGame_interfaces.sol"; 

contract WarGameUnit is WarGameObj {

    address public BaseAddr; 
    //uint objAttackVal;

    //constructor(uint playerPubkey, address playerBaseAddr, address Storage_Addr) public {
    constructor() public {
        //require(tvm.pubkey() != 0, 101);
        //require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        // BaseAddr = playerBaseAddr; 
        // IWarGameBase(BaseAddr).addUnit(objInfo);    
    }  

    function setAttackVal(int32 _objAttackVal) public checkOwnerAndAccept {
        objInfo.itemAttack = _objAttackVal;  
    }

    function attackEnemy(address _aimAddr) external checkOwnerAndAccept{
        IWarGameObj(_aimAddr).acceptAttack(_aimAddr, objInfo.itemAttack);  
    }

    function deathOfBase(address _enemyAddr) external {
        require(msg.sender == BaseAddr, 102, "Error: Call not from owner base");
        tvm.accept();
        //deathProcessing(_enemyAddr);
        destroyAndTransfer(_enemyAddr);
    }

    function deathProcessing(address _enemyAddr) internal override {
        tvm.accept();
        IWarGameBase(BaseAddr).removeWarUnit();
        destroyAndTransfer(_enemyAddr);  
    }  

    function onAcceptAttack() internal override{
        Information _objInfo = objInfo;
        IWarGameBase(BaseAddr).updateUnitsInfo(_objInfo);
    } 


}
