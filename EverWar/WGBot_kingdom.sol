pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

//import "WGBot_infos.sol";    
import "WGBot_infos.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_kingdom is WGBot_infos {  
    
    
    
    // !!!!!!!!!BETTER TO UPDATE stats and info on every press Button, which lead to choose unit/kingdom menu!!!!!!!!!!!!!!!!!!! 
    
    function updateUnitsInfo() public override{ 
        showUInfo = false;
        req_BaseUnitsInfo(Base_Addr);
    }


    function goKingdomMenu() public override{ 
        //attackProcessing = false; 
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Kingdoms alive: {}, My units alive: {}, Incoming attacks: {}",
                    gameStat.basesAlive,
                    UnitsAliveCnt,
                    AttackHistoryCnt        
            ),
            sep,
            [
                MenuItem("Kingdom info","",tvm.functionId(WGBot_infos.getBaseUnitsInfo)),
                MenuItem("Attack!","",tvm.functionId(reqWGB_sendAttack)),
                MenuItem("Scout!","",tvm.functionId(reqWGB_sendScout)),
                MenuItem("Produce menu","",tvm.functionId(reqWGB_deployMenu)),
                MenuItem("Incoming attacks","",tvm.functionId(showRxAttacks)), 
                MenuItem("<=== Back","",tvm.functionId(goMainMenu))   
            ]
        );
    } 


    function reqWGB_sendAttack() public {
        uint256 _playerPubkey = playerPubkey;
        mapping(int32 => Information) _UnitsInfo = UnitsInfo;
        IWGBot_Units(WGBot_UnitsAddr).invokeSendAttack(_playerPubkey, _UnitsInfo);
    }


    function reqWGB_sendScout() public {
        uint256 _playerPubkey = playerPubkey;
        mapping (int32 => address) _playersIDList = playersIDList;
        address _Scout_Addr = Scout_Addr;
        IWGBot_Units(WGBot_UnitsAddr).invokeSendScout(_playerPubkey, _playersIDList, _Scout_Addr);
    }

    
    function reqWGB_deployMenu() public {
        uint _playerPubkey = playerPubkey;
        deployType = DeployType.Empty;
        DeployType _deployType = deployType;
        address _Storage_Addr = StorageAddr;
        address _Base_Addr = Base_Addr;
        int32 _mainUnitID = mainUnitID;
        IWGBot_deployer(WGBot_deployerAddr).invokeDeployer_start(_playerPubkey, _deployType, _Base_Addr, _Storage_Addr, _mainUnitID); 
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
    
    function commutator() internal virtual override {
        if (returnFuncID == tvm.functionId(goMainMenu)) {
            returnFuncID = 0; 
            goMainMenu();
        }
        else if (returnFuncID == tvm.functionId(this.goKingdomMenu)) { 
            returnFuncID = 0;
            goKingdomMenu();
        }
        else if (returnFuncID == tvm.functionId(this.updateUnitsInfo)) { 
            returnFuncID = 0;
            updateUnitsInfo();
        }
        // else if (returnFuncID == tvm.functionId(sendScout_1)) {
        //     returnFuncID = 0;
        //     sendScout_1();
        // }
        // else if (returnFuncID == tvm.functionId(sendAttack_3)) {
        //     returnFuncID = 0;
        //     sendAttack_3();
        // }
        // else if (returnFuncID == tvm.functionId(sendAttack_5)) {
        //     returnFuncID = 0;
        //     sendAttack_5();
        // }
        else {
            returnFuncID = 0;
            goMainMenu();
        }
    }

    // function showUnitsInfoExit() internal virtual override{ 
    //     goKingdomMenu();
    // }


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
