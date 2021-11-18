pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

//import "WGBot_infos.sol";    
import "WGBot_attack.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_kingdom is WGBot_attack {  
    
    int32 UnitsAliveCnt = 404;
    
    
    // bool attackProcessing = false;
    // int32 attackerUnitID;
    // address attackerUnitAddr;
    // address _aimAddr;
    


    // !!!!!!!!!ON BUTTON PRESS [My KINGDOM] need to update units info and set Scout_Addr!!!!!!!!!!!!!!!!!!! 
    
    function goKingdomMenu() public override {
        //attackProcessing = false; 
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Kingdoms alive: {}, My units alive: {}",
                    gameStat.basesAlive,
                    UnitsAliveCnt
                    
            ),
            sep,
            [
                MenuItem("Base info","",tvm.functionId(WGBot_infos.getBaseObjInfo)),
                MenuItem("Units info","",tvm.functionId(WGBot_infos.getBaseUnitsInfo)),
                MenuItem("Attack!","",tvm.functionId(sendAttack_Start)),
                MenuItem("Scout!","",tvm.functionId(sendScout_Start)),
                MenuItem("Produce warrior","",tvm.functionId(req_produceWarrior)),
                MenuItem("Produce scout","",tvm.functionId(req_produceScout)),
                MenuItem("<=== Back","",tvm.functionId(goMainMenu))
                
            ]
        );
    } 

    
    function req_produceWarrior() public {
        uint _playerPubkey = playerPubkey;
        deployType = DeployType.Warrior;
        DeployType _deployType = deployType;
        IWGBot_deployer(WGBot_deployerAddr).invokeProduce(_playerPubkey, _deployType);
    }

    function req_produceScout() public {
        uint _playerPubkey = playerPubkey;
        deployType = DeployType.Scout;
        DeployType _deployType = deployType;
        IWGBot_deployer(WGBot_deployerAddr).invokeProduce(_playerPubkey, _deployType);
    }

    
    
    // function commutator() public virtual override {
    //     if (returnFuncID == tvm.functionId(goMainMenu)) {
    //         returnFuncID = 0; 
    //         goMainMenu();
    //     }
    //     else if (returnFuncID == tvm.functionId(this.goKingdomMenu)) { 
    //         returnFuncID = 0;
    //         goKingdomMenu();
    //     }
    //     else if (returnFuncID == tvm.functionId(sendScout_1)) {
    //         sendScout_1();
    //     }
    //     else {
    //         returnFuncID = 0;
    //         goMainMenu();
    //     }
    // }
    
    function commutator() public virtual override {
        if (returnFuncID == tvm.functionId(goMainMenu)) {
            returnFuncID = 0; 
            goMainMenu();
        }
        else if (returnFuncID == tvm.functionId(this.goKingdomMenu)) { 
            returnFuncID = 0;
            goKingdomMenu();
        }
        else if (returnFuncID == tvm.functionId(sendScout_1)) {
            returnFuncID = 0;
            sendScout_1();
        }
        else if (returnFuncID == tvm.functionId(sendAttack_3)) {
            returnFuncID = 0;
            sendAttack_3();
        }
        else if (returnFuncID == tvm.functionId(sendAttack_5)) {
            returnFuncID = 0;
            sendAttack_5();
        }
        else {
            returnFuncID = 0;
            goMainMenu();
        }
    }



    function getDebotInfo() public functionID(0xDEB) virtual override view returns( 
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "EverWar Game Main DeBot";
        version = "0.0.5";
        publisher = "d0ubleit";
        key = "EverWar Game DeBot";
        author = "d0ubleit";
        support = address.makeAddrStd(0, 0x81b6312da6eaed183f9976622b5a39a90d5cff47e4d2a541bd97ee216e8300b1);
        hello = "Welcome to strategy blockchain game!";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
    
}
