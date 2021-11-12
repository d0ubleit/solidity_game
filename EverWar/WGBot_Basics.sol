pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_Init.sol";
import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

// SL = Shopping List
contract WGBot_Basics is WGBot_Init {
    
    TvmCell Warrior_Code;
    TvmCell Warrior_Data;
    TvmCell Warrior_StateInit; 
    address Warrior_Addr;         
    int32 WarriorID = 1; 
    mapping(int32 => Information) UnitsInfo;
    mapping(int32 => address) UnitsAliveList;
    int32 UnitsAliveCnt;
    
    bool attackProcessing;
    int32 attackerUnitID;
    address attackerUnitAddr;
    address _aimAddr;


    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "EverWar Game DeBot";
        version = "0.0.1";
        publisher = "d0ubleit";
        key = "EverWar Game DeBot";
        author = "d0ubleit";
        support = address.makeAddrStd(0, 0x81b6312da6eaed183f9976622b5a39a90d5cff47e4d2a541bd97ee216e8300b1);
        hello = "Welcome to strategy blockchain game!";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }
    
    function goKingdomMenu() public override {
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
                MenuItem("Produce warrior","",tvm.functionId(produceWarrior)),
                MenuItem("<=== Back","",tvm.functionId(goMainMenu_Signed))
                
            ]
        );
    } 

    // function goKingdomMenu_Units() public {
    //     string sep = '----------------------------------------';
    //     Menu.select(
    //         format(
    //             "Kingdoms alive: {}, My units alive: {}",
    //                 gameStat.basesAlive,
    //                 UnitsAliveCnt
                    
    //         ),
    //         sep,
    //         [
    //             MenuItem("Show INFO","",tvm.functionId(setAddrForRequest_Base)),
    //             MenuItem("Units","",tvm.functionId(setAddrForRequest_Warrior)),
    //             MenuItem("Produce warrior","",tvm.functionId(produceWarrior)), 
    //             MenuItem("<=== Back","",tvm.functionId(goMainMenu_Signed))

    //         ]
    //     );
    // } 

    // function goUnitsMenu() public override {
    //     string sep = '----------------------------------------';
    //     Menu.select(
    //         format(
    //             "Kingdoms alive: {}, My units alive: {}",
    //                 gameStat.basesAlive,
    //                 UnitsAliveCnt
                    
    //         ),
    //         sep,
    //         [
    //             MenuItem("Show INFO","",tvm.functionId(setAddrForRequest_Base)),
    //             MenuItem("Units","",tvm.functionId(produceWarrior)),
    //             MenuItem("Produce warrior","",tvm.functionId(produceWarrior)), 
    //             MenuItem("<=== Back","",tvm.functionId(goMainMenu_Signed))

    //         ]
    //     );
    // }        
    
    function setWGWarriorCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101); 
        tvm.accept();
        Warrior_Code = code;
        Warrior_Data = data;
        //Warrior_StateInit = tvm.buildStateInit(Warrior_Code, Warrior_Data);
    }

    function produceWarrior() public {
        produceProcessing = true; 
        produceType = 1;
        Terminal.print(0, "Preparing...");
        Warrior_StateInit = tvm.buildStateInit({code: Warrior_Code, contr: AWarGameExample, varInit: {exampleID: WarriorID}});//////////////////////////////////////   
        TvmCell deployState = tvm.insertPubkey(Warrior_StateInit, playerPubkey);
        Warrior_Addr = address.makeAddrStd(0, tvm.hash(deployState));
        Terminal.print(0, format( "Info: your Warrior address is {}", Warrior_Addr));
        produceAddr = Warrior_Addr;
        Sdk.getAccountType(tvm.functionId(checkAccountStatus), produceAddr);
    }

    function deploy() internal virtual override view { 
            TvmCell image;
            if (produceType == 0){
                image = tvm.insertPubkey(Base_StateInit, playerPubkey);
            }
            else if (produceType == 1){
                image = tvm.insertPubkey(Warrior_StateInit, playerPubkey);
            } 
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: produceAddr,
                callbackId: tvm.functionId(WGBot_Basics.onSuccessDeploy),  
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image, 
                call: {AWarGameExample, playerPubkey, playersAliveList[playerPubkey]} 
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onSuccessDeploy() public override {       //view{
        produceProcessing = false;
        if (produceType == 0) {
            BaseID++;
            Terminal.print(0, "Your kingdom is ready! Have a nice game!");
            Terminal.print(0, "One more transaction to register your kingdom at storage..");
            memPlayersList(playerPubkey, produceAddr); 
        }
        else if (produceType == 1){
            WarriorID++;
            UnitsAliveCnt++;
            UnitsAliveList[UnitsAliveCnt] = Warrior_Addr;
            Terminal.print(0, "Your Warrior is ready for battle!");
            //goKingdomMenu();
            setAddrForRequest_Warrior(0);       
        }              
    } 

    function setAddrForRequest_Base(uint32 index) public view {
        index = index;
        address ExampleAddr = playersAliveList[playerPubkey];
        requestInformation(ExampleAddr);
    }

    function setAddrForRequest_Warrior(uint32 index) public view {
        index = index;
        address ExampleAddr = Warrior_Addr; ////////////////////////////////////////////////// JUST FOR TEST! SET IN ANOTHER WAY!
        requestInformation(ExampleAddr);
    }

    function requestInformation(address ExampleAddr) public view {
        optional(uint256) none;
        IWarGameObj(ExampleAddr).getInfo{
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
            ObjectInfo.itemDefence)); 
        goKingdomMenu();
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

    function setUnitsInfo(mapping(int32 => Information) newUnitsInfo) public {
        UnitsInfo = newUnitsInfo;
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
        attackerUnitID = int32(res);
        attackerUnitAddr = UnitsInfo[attackerUnitID].itemAddr;
        AddressInput.get(tvm.functionId(sendAttack), "Input address of unit to attack");
    }

    function sendAttack(address value) public {
        attackProcessing = false;
        _aimAddr = value;
        optional(uint256) pubkey = 0;
        IWarGameUnit(attackerUnitID).attackEnemy{
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




        // uint32 i;
        // if (showShopList.length > 0 ) {
        //     Terminal.print(0, "Here is your shopping list:");
        //     for (i = 0; i < showShopList.length; i++) { 
        //         ShopItem SLexample = showShopList[i];
        //         string checkBox;
        //         if (SLexample.itemIsPurchased) {
        //             checkBox = '✓';
        //             Terminal.print(0, format(" {} || {}: \"{}\" || Amount:{} || Cost for all:{} || Created at {}", 
        //                 checkBox,
        //                 SLexample.itemID,
        //                 SLexample.itemName,
        //                 SLexample.itemNum,
        //                 SLexample.itemTotalPrice,
        //                 SLexample.itemCreationTime));
        //         } else {
        //             checkBox = '.';
        //             Terminal.print(0, format(" {} || {}: \"{}\" || Amount:{} || Created at {}", 
        //                 checkBox,
        //                 SLexample.itemID,
        //                 SLexample.itemName,
        //                 SLexample.itemNum,
        //                 SLexample.itemCreationTime
        //                 )); 
        //         } 
        //     }
        // } else {
        //     Terminal.print(0, "Your shopping list is empty. Add something ;)");
        // }
        
    

    // function deleteListItem(uint32 index) public {
    //     index = index;
    //     if (SL_Summary.numItemsPaid + SL_Summary.numItemsNotPaid > 0) {
    //         Terminal.input(tvm.functionId(requestDeleteListItem), "Enter ID of item you want to delete:", false);
    //     } else {
    //         Terminal.print(0, "Sorry, you have no items in shopping list.");
    //         openMenu();
    //     }
    // }

    // function requestDeleteListItem(string value) public view { 
    //     (uint256 _itemID,) = stoi(value); 
    //     optional(uint256) pubkey = 0;
    //     IshoppingList(SL_address).deleteItemFromList{ 
    //             abiVer: 2,
    //             extMsg: true,
    //             sign: true,
    //             pubkey: pubkey,
    //             time: uint64(now),
    //             expire: 0,
    //             callbackId: tvm.functionId(onSuccess),
    //             onErrorId: tvm.functionId(onError)
    //         }(int32(_itemID)); 
    // }

    // function openMenu() public virtual override {   
    // }
    
}
