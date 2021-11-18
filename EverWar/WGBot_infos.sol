pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_initial.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_infos is WGBot_initial { 
    
    mapping(int32 => Information) UnitsInfo;

    
    function getBaseObjInfo() public override {  
        //callerFuncID = tvm.functionId(getBaseObjInfo);
        req_ObjInfo(Base_Addr); 
    }

    function req_ObjInfo(address _Produce_Addr) internal override { 
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
            returnFuncID = tvm.functionId(goKingdomMenu);
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
        showUnitsInfo(UnitsInfo);     
    }

    function showUnitsInfo(mapping(int32 => Information) _UnitsInfo) internal {
        if (_UnitsInfo.empty()) {
            Terminal.print(0, "There are no alive units. Produce some in kingdom menu.");
        }
        else {
            for ((int32 unitID , Information InfoExample) : _UnitsInfo) {    
            Terminal.print(0, format(" ID: {} || Type: \"{}\" || Address: {} || Owner PubKey: {} || Health: {} || Attack power: {} || Defence power: {}", 
                unitID, 
                InfoExample.itemType,
                InfoExample.itemAddr,
                InfoExample.itemOwnerPubkey,
                InfoExample.itemHealth,
                InfoExample.itemAttack, 
                InfoExample.itemDefence)); 
            }
        }
        showUnitsInfoExit();
    }


    function showUnitsInfoExit() internal virtual{ 
        goKingdomMenu();
    }
    





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
