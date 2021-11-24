pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_initial.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_infos is WGBot_initial { 
    
    int32 UnitsAliveCnt;
    address reqObjInfo_Addr;
    bool showUInfo = true;
    mapping(int32 => Information) UnitsInfo;

    
    // function getBaseObjInfo() public override {  
    //     //callerFuncID = tvm.functionId(getBaseObjInfo);
    //     checkAccStatus(Base_Addr); 
    // }

    function checkAccStatus(address _Obj_Addr) internal override {
        reqObjInfo_Addr = _Obj_Addr;
        Sdk.getAccountType(tvm.functionId(checkAccountStatus), reqObjInfo_Addr);    
    }
    
    function checkAccountStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            req_ObjInfo(reqObjInfo_Addr);
        } else {
            Terminal.print(0, "Unit is already DEAD or it's balance too low");
            deployType = DeployType.Empty;
            requestGetPlayersList(tvm.functionId(setPlayersList));
        }
    }

    function req_ObjInfo(address _Produce_Addr) internal { 
        optional(uint256) none;
        IWarGameObj(_Produce_Addr).getInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showObjInfo),
            onErrorId: 0
        }();
    }

    // function req_ObjInfo_Success(Information ObjectInfo) public{
    //     if (showUInfo){
    //         showObjInfo(ObjectInfo);
    //     }
    //     else{
    //         showUInfo = true;
    //         goKingdomMenu(); 
    //     }
    // }
    
    function showObjInfo(Information ObjectInfo) public {
        Terminal.print(0, format(" ID: {} || Type: \"{}\" || Address: {} || Owner PubKey: {} || Health: {} || Attack power: {} || Defence power: {}", 
            ObjectInfo.itemID,
            ObjectInfo.itemType,
            ObjectInfo.itemAddr,
            ObjectInfo.itemOwnerPubkey,
            ObjectInfo.itemHealth,
            ObjectInfo.itemAttack, 
            ObjectInfo.itemDefence
            )); 
        
        showPL = false;
        if (deployType == DeployType.Base) {
            returnFuncID = tvm.functionId(goMainMenu);
        }
        else {
            returnFuncID = tvm.functionId(updateUnitsInfo);
        }
        deployType = DeployType.Empty;
        requestGetPlayersList(tvm.functionId(setPlayersList));
    }



    
    
    
    
    function getBaseUnitsInfo() public {
        req_BaseUnitsInfo(Base_Addr);
    }


    function req_BaseUnitsInfo(address _Base_Addr) internal {
        optional(uint256) none;
        IWarGameBase(_Base_Addr).getUnitsInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none, 
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(setUnitsInfo),
            onErrorId: 0
        }();
    }

    function setUnitsInfo(mapping(int32 => Information) _UnitsInfo) public {
        UnitsInfo = _UnitsInfo;
        UnitsAliveCnt = 0;
        //Information NotNeeded;
        // optional(int32, Information) MaxId = UnitsInfo.max();
        // mainUnitID = MaxId().get();
        delete Scout_Addr;
        for ((int32 ExampleID, Information InfoExample) : UnitsInfo) {
            if (InfoExample.itemType!="Base") {
                UnitsAliveCnt++;
            }
            
            //if (Scout_Addr.isStdZero()){
            if (InfoExample.itemType=="Scout") {
                Scout_Addr = InfoExample.itemAddr;
            }
            //}
            
            if (mainUnitID <= ExampleID) {
                mainUnitID = ExampleID + 1;
            }

        }

        if (showUInfo){
            returnFuncID = tvm.functionId(goKingdomMenu);
            showUnitsInfo(UnitsInfo); 
        }
        else{
            showUInfo = true;
            goKingdomMenu(); 
        }        
    }

    function showUnitsInfo(mapping(int32 => Information) _UnitsInfo) internal {
        if (_UnitsInfo.empty()) {
            Terminal.print(0, "There are no alive units. Produce some in kingdom menu.");
        }
        else {
            for ((int32 unitID , Information InfoExample) : _UnitsInfo) {    
            Terminal.print(0, format(" ID: {} || Type: \"{}\" || Health: {} || Attack power: {} || Defence power: {} || At address:", 
                unitID,
                InfoExample.itemType,
                InfoExample.itemHealth,
                InfoExample.itemAttack, 
                InfoExample.itemDefence));
            
            Terminal.print(0, format("{}", InfoExample.itemAddr));
            }
        }
        //showUnitsInfoExit();
        commutator();
    }


    // function showUnitsInfoExit() internal virtual{ 
    //     goKingdomMenu();
    // }

    // function updateUnitsInfo() public virtual{
    //     goKingdomMenu();
    // } 
    





    // function getDebotInfo() public functionID(0xDEB) virtual override view returns(
    //     string name, string version, string publisher, string key, string author,
    //     address support, string hello, string language, string dabi, bytes icon
    // ) {
    //     name = "EverWar Game Main DeBot";
    //     version = "0.0.5";
    //     publisher = "d0ubleit";
    //     key = "EverWar Game DeBot";
    //     author = "d0ubleit";
    //     support = address.makeAddrStd(0, 0x81b6312da6eaed183f9976622b5a39a90d5cff47e4d2a541bd97ee216e8300b1);
    //     hello = "Welcome to strategy blockchain game!";
    //     language = "en";
    //     dabi = m_debotAbi.get();
    //     icon = m_icon;
    // }
      
}
