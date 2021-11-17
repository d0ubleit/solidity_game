pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_initial.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_kingdom is WGBot_initial { 
    
    mapping(int32 => Information) UnitsInfo;
    mapping(int32 => address) UnitsAliveList;
    int32 UnitsAliveCnt;
    
    
    bool attackProcessing = false;
    int32 attackerUnitID;
    address attackerUnitAddr;
    address _aimAddr;

    
    function goKingdomMenu() public virtual override {
        attackProcessing = false;
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Kingdoms alive: {}, My units alive: {}",
                    gameStat.basesAlive,
                    UnitsAliveCnt
                    
            ),
            sep,
            [
                MenuItem("Base info","",tvm.functionId(setAddrForRequest_Base)),
                MenuItem("Units info","",tvm.functionId(getBaseUnitsInfo)),
                MenuItem("Attack!","",tvm.functionId(sendAttackStart)),
                MenuItem("Produce warrior","",tvm.functionId(req_produceWarrior)),
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

    
    function getObjInfo() internal override {
        req_ObjInfo();
    }

    // function setAddrForRequest_Base(uint32 index) public view {
    //     index = index;
    //     address ExampleAddr = playersAliveList[playerPubkey];
    //     requestInformation(ExampleAddr);
    // }

    // function setAddrForRequest_Warrior(uint32 index) public view {
    //     index = index;
    //     address ExampleAddr = Warrior_Addr; ////////////////////////////////////////////////// JUST FOR TEST! SET IN ANOTHER WAY!
    //     requestInformation(ExampleAddr);
    // }

    function req_ObjInfo() public view {
        optional(uint256) none;
        IWarGameObj(Produce_Addr).getInfo{
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
        returnFuncID = tvm.functionId(goKingdomMenu);
        requestGetPlayersList(tvm.functionId(setPlayersList));
    }

    function getBaseUnitsInfo() public {
        optional(uint256) none;
        IWarGameBase(Base_Addr).getUnitsInfo{
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
        showUnitsInfo();
        
    }

    function showUnitsInfo() internal {
        if (UnitsInfo.empty()) {
            Terminal.print(0, "You have no alive units. Produce some in kingdom menu.");
        }
        else {
            for ((int32 unitID , Information InfoExample) : UnitsInfo) {    
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

    function showUnitsInfoExit() internal{
        if (attackProcessing) {
            Terminal.input(tvm.functionId(sendAttackChooseAim),"Enter ID of unit who will attack",false);
            
        }
        else {
            goKingdomMenu();
        }
    }
    
    function sendAttackStart() public{
        attackProcessing = true;
        sendAttackChooseUnit();
    }

    function sendAttackChooseUnit() internal {
        if (UnitsInfo.empty()) {
            Terminal.print(0, "You have no alive units. Produce some in kingdom menu.");
            goKingdomMenu();
        }
        else {
            showUnitsInfo();
        }
    }

    function sendAttackChooseAim(string value) public {
        (uint res, bool status) = stoi(value);
        if (status) {
            attackerUnitID = int32(res);
            attackerUnitAddr = UnitsInfo[attackerUnitID].itemAddr;
            //Terminal.print(0, format(" Attacker addr: {} ", attackerUnitAddr));
            //Terminal.input(tvm.functionId(sendAttack),"Enter address of aim",false);
            //AddressInput.get(tvm.functionId(sendAttack), "Input address of unit to attack");
            sendAttack();
        }
        else {
            Terminal.input(tvm.functionId(sendAttackChooseAim),"Wrong ID. Try again!\nEnter ID of unit who will attack",false);

        }
    }


    function sendAttack() public {
        attackProcessing = false;
        _aimAddr = Base_Addr;//address.makeAddrStd(0,value);
        optional(uint256) pubkey = 0;
        IWarGameUnit(attackerUnitAddr).attackEnemy{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now), 
                expire: 0,
                callbackId: tvm.functionId(onSuccessFunc),
                onErrorId: tvm.functionId(onError)
            }(_aimAddr); 
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
