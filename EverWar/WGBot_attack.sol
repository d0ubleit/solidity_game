pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_scout.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_attack is WGBot_scout { 
    
    // mapping(int32 => Information) UnitsInfo;
    // mapping(int32 => address) UnitsAliveList;
    // int32 UnitsAliveCnt;
    
    
    //bool attackProcessing = false; 
    int32 attackerUnitID;
    address attackerUnitAddr;
    address aimKingdomAddr;
    address aimUnitAddr;
   
    
    // function sendAttack_Start() public{
    //     attackProcessing = true;
    //     sendAttack_1();
    // }

    function sendAttack_Start() public {
        if (UnitsInfo.empty()) {
            Terminal.print(0, "You have no alive units. Produce some in kingdom menu.");
            goKingdomMenu();
        }
        else {
            if (ScoutedInfo.empty()) {
                Terminal.print(0, "You didn't explore any kingdom. Send scout.");
                goKingdomMenu();
            }
            else {
            returnFuncID = tvm.functionId(sendAttack_1);
            showUnitsInfo(UnitsInfo);
            }
        }
    }

    function showUnitsInfoExit() internal override{ 
        if (returnFuncID == tvm.functionId(sendAttack_1)) {
            returnFuncID = 0;
            sendAttack_1();
        }
        else {
            returnFuncID = 0;
            goKingdomMenu();
        }
    }

    function sendAttack_1() public {
        Terminal.input(tvm.functionId(sendAttack_2),"Enter ID of unit who will attack",false);
    }


    function sendAttack_2(string value) public {
        address EmptyAddr;
        (uint res, bool status) = stoi(value);
        if (status) {
            attackerUnitID = int32(res);
            attackerUnitAddr = UnitsInfo[attackerUnitID].itemAddr;
            returnFuncID = tvm.functionId(sendAttack_3);
            showScoutedInfo(ScoutedInfo, EmptyAddr); 
        }
        else {
            Terminal.input(tvm.functionId(sendAttack_2),"Wrong ID. Try again!\nEnter ID of unit who will attack",false);

        }
    }

    function commutator() internal virtual override {
        if (returnFuncID == tvm.functionId(goMainMenu)) {
            returnFuncID = 0; 
            goMainMenu();
        }
        else if (returnFuncID == tvm.functionId(goKingdomMenu)) { 
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

    function sendAttack_3() public {
        Terminal.input(tvm.functionId(sendAttack_4),"Enter ID of kingdom",false);
    }


    function sendAttack_4(string value) public {
        (uint res, bool status) = stoi(value);
        if (status) {
            aimKingdomAddr = enemiesList[int32(res)];
            returnFuncID = tvm.functionId(sendAttack_5);
            showScoutedInfo(ScoutedInfo, aimKingdomAddr);
        }
        else {
            Terminal.input(tvm.functionId(sendAttack_4),"Wrong ID. Try again!\nEnter ID of kingdom",false);

        }
    }

    function sendAttack_5() public {
        Terminal.input(tvm.functionId(sendAttack_6),"Enter ID of aim unit",false);
    }

    function sendAttack_6(string value) public {
        (uint res, bool status) = stoi(value);
        if (status) {
            aimUnitAddr = ScoutedInfo[aimKingdomAddr][int32(res)].itemAddr;
            req_sendAttack();
        }
        else {
            Terminal.input(tvm.functionId(sendAttack_6),"Wrong ID. Try again!\nEnter ID of aim unit",false);

        }
    }


    function req_sendAttack() public {
        //attackProcessing = false;
        //_aimAddr = Base_Addr;//address.makeAddrStd(0,value); 
        optional(uint256) pubkey = 0;
        IWarGameUnit(attackerUnitAddr).attackEnemy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now), 
                expire: 0,
                callbackId: tvm.functionId(onSuccessAttack),
                onErrorId: tvm.functionId(onError)
            }(aimUnitAddr); 
    }


    function onSuccessAttack() public {
        Terminal.print(0, "Attack successfully done");
        checkAccStatus(aimUnitAddr);
        //goKingdomMenu();
    } 

    //getUnitInfoByAddr(address _unitAddr) external returns(Information _unitInfo);
    // function req_attackedUnitInfo() internal {
    //     optional(uint256) none;
    //     address _unitAddr = aimUnitAddr;
    //     IWarGameBase(aimKingdomAddr).getUnitInfoByAddr{
    //         abiVer: 2,
    //         extMsg: true,
    //         sign: false,
    //         pubkey: none, 
    //         time: uint64(now),
    //         expire: 0,
    //         callbackId: tvm.functionId(showAttackResult),  
    //         onErrorId: 0
    //     }(_unitAddr);
    // }

    // function showAttackResult(Information _unitInfo) public {
    //     Terminal.print(0, "Result of attack:");
    //     showObjInfo(_unitInfo);
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
