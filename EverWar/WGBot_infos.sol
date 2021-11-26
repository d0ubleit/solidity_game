pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_initial.sol";
import "AWarGameExample.sol"; 


contract WGBot_infos is WGBot_initial { 
    
    int32 UnitsAliveCnt;
    address reqObjInfo_Addr;
    bool showUInfo = true;
    mapping(int32 => Information) UnitsInfo;
    mapping(int32 => RecievedAttacksHistory) RxAttacksInfo;

    int32 AttackHistoryCnt;


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

    
    function showObjInfo(Information ObjectInfo) public {
        Terminal.print(0, format(" ID: {} | {} || Health: {} || Attack: {} || Defence: {} || At address:\n{}", 
            ObjectInfo.itemID,
            ObjectInfo.itemType,
            ObjectInfo.itemHealth,
            ObjectInfo.itemAttack, 
            ObjectInfo.itemDefence,
            ObjectInfo.itemAddr
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
        IWarGameBase(_Base_Addr).getInfos{ 
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none, 
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(setInfos),
            onErrorId: 0
        }();
    }


    function setInfos(mapping(int32 => Information) _UnitsInfo, mapping(int32 => RecievedAttacksHistory) _RxAttacksInfo ) public {
        UnitsInfo = _UnitsInfo;
        RxAttacksInfo = _RxAttacksInfo;
        UnitsAliveCnt = 0;
        int32 unitID_;

        optional(int32, Information) MaxUnitID = UnitsInfo.max();
        if (MaxUnitID.hasValue()) { 
            (unitID_, ) = MaxUnitID.get();
        } 
        mainUnitID = unitID_ >= mainUnitID ? unitID_+1 : mainUnitID; 

        optional(int32, RecievedAttacksHistory) MaxHistID = RxAttacksInfo.max(); 
        if (MaxHistID.hasValue()) {
            (AttackHistoryCnt, ) = MaxHistID.get();
        }

        delete Scout_Addr;
        for ((int32 ExampleID, Information InfoExample) : UnitsInfo) {
            if (InfoExample.itemType!="Base") {
                UnitsAliveCnt++;
            }
            
            if (InfoExample.itemType=="Scout") {
                Scout_Addr = InfoExample.itemAddr;
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
            Terminal.print(0, "There is no alive units. Produce some in kingdom menu.");
        }
        else {
            for ((int32 unitID , Information InfoExample) : _UnitsInfo) {    
                Terminal.print(0, format(" ID: {} <{}> || Health: {} | Attack: {} | Defence: {} || At address:", 
                    unitID,
                    InfoExample.itemType,
                    InfoExample.itemHealth,
                    InfoExample.itemAttack, 
                    InfoExample.itemDefence));
                
                Terminal.print(0, format("{}", InfoExample.itemAddr));
                Terminal.print(0, "-----");
            }
        }
        commutator();
    }

    
    function showRxAttacks() public {
        string isAlive;
        int32 HP;
        if (RxAttacksInfo.empty()) {
            Terminal.print(0, "There is no attacks in history.");
        }
        else {
            for ((int32 attackID , RecievedAttacksHistory HistExample) : RxAttacksInfo) { 
                isAlive = HistExample.alive ? "" : "! DEAD !";
                HP = HistExample.alive ? UnitsInfo[HistExample.attackedUnitID].itemHealth : 0;
                Terminal.print(0, format(" Kingdom [ID: {} ] caused {} damage to unit:\n  ID: {} || Type: {} || Health: {} {}", 
                    playersAliveList[HistExample.attackerPubkey],
                    HistExample.damage,
                    HistExample.attackedUnitID,
                    HistExample.attackedUnitType, 
                    HP,
                    isAlive));
                Terminal.print(0, "-----");
            }
        }
        goKingdomMenu(); 
    }

      
}
