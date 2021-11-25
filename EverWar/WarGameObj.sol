pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "IWarGame_interfaces.sol";
//import "IWarGameObj.sol";
//import "WarGameStructs.sol";

contract WarGameObj is IWarGameObj {

    uint playerPubkey;

    Information public objInfo;
    
    //address[] public attackersArr;

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

    function acceptAttack(address aimAddr, int32 _objAttackVal, uint _playerPubkey) external override{ 
        tvm.accept();
        address enemyAddr = msg.sender;
        uint enemyPubkey = _playerPubkey;
        int32 damage = 0;
        //attackersArr.push(msg.sender);
        if (_objAttackVal > objInfo.itemDefence) {
            damage = _objAttackVal - objInfo.itemDefence;
            if (damage > objInfo.itemHealth) {
                deathProcessing(enemyAddr, enemyPubkey, damage);
            }
            else {
                objInfo.itemHealth -= damage;
                onAcceptAttack(enemyPubkey, damage);
            }
        }        
        
        // if (_objAttackVal > objInfo.itemDefence) {
        //     objInfo.itemHealth -= uint32(_objAttackVal) - uint32(objInfo.itemDefence);  
        // }
        
        // if (checkObjIsDead()) {
        //     deathProcessing(enemyAddr);
        // }
        // else{
        //     onAcceptAttack(); 
        // }
    }

    function onAcceptAttack(uint enemyPubkey, int32 damage) internal virtual{   
    }

    function setDefenceVal(int32 _objDefenceVal) public checkOwnerAndAccept {
        tvm.accept();
        objInfo.itemDefence = _objDefenceVal;
    }

    function checkObjIsDead() private returns(bool) {
        tvm.accept();
        if (objInfo.itemHealth <= 0) {
            return true;
        }
        else {
            return false;
        }
    }

    function deathProcessing(address _enemyAddr, uint enemyPubkey, int32 damage) internal virtual {
        tvm.accept();
        destroyAndTransfer(_enemyAddr);  
    } 

    function destroyAndTransfer(address _enemyAddr) internal {
        tvm.accept();
        _enemyAddr.transfer(1, true, 160); 
    }

    function getInfo() external override returns(Information){
        tvm.accept();
        return objInfo; 
    } 


} 

