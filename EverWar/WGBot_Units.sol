pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_Basics.sol";
//import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_Units is WGBot_Basics { 
    
    TvmCell Scout_Code;
    TvmCell Scout_Data;
    TvmCell Scout_StateInit; 
    address Scout_Addr;         
    int32 ScoutID = 1; 

    bool scoutProcessing;
    address aimToScoutAddr;

    mapping (int32 => address) playersIDList;
    mapping (address => mapping (int32 => Information)) ScoutedInfo;
    mapping (int32 => Information) enemyUnitsInfo;

    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "EverWar Game DeBot";
        version = "0.0.2";
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
                MenuItem("Scout!","",tvm.functionId(sendScoutStart)),
                MenuItem("Attack!","",tvm.functionId(sendAttackStart)), 
                MenuItem("Produce warrior","",tvm.functionId(produceWarrior)),
                MenuItem("Produce scout","",tvm.functionId(produceScout)),
                MenuItem("<=== Back","",tvm.functionId(goMainMenu_Signed))
                
            ]
        );
    } 

       
    function setWGScoutCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101); 
        tvm.accept();
        Scout_Code = code;
        Scout_Data = data;
    }

    function produceScout() public {
        produceProcessing = true; 
        produceType = 2;
        Terminal.print(0, "Preparing...");
        Scout_StateInit = tvm.buildStateInit({code: Scout_Code, contr: AWarGameExample, varInit: {exampleID: ScoutID}});//////////////////////////////////////   
        TvmCell deployState = tvm.insertPubkey(Scout_StateInit, playerPubkey);
        Scout_Addr = address.makeAddrStd(0, tvm.hash(deployState));
        Terminal.print(0, format( "Info: your Scout address is {}", Scout_Addr));
        produceAddr = Scout_Addr;
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
            else if (produceType == 2){
                image = tvm.insertPubkey(Scout_StateInit, playerPubkey);
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
            setAddrForRequest();       
        } 
        else if (produceType == 2){
            ScoutID++;
            UnitsAliveCnt++;
            UnitsAliveList[UnitsAliveCnt] = Scout_Addr;
            Terminal.print(0, "Your Scout is ready to find enemy units!");
            //goKingdomMenu();
            setAddrForRequest();       
        }                          
    } 

       
    function setAddrForRequest() internal view {
        //index = index;
        address ExampleAddr = produceAddr;
        requestInformation(ExampleAddr);
    }

    function sendScoutStart() public {
        scoutProcessing = true;
        showListToScout();
    }

    //////////////////////////BETTER REPLACE IT WITH showPlayersList func, but how to exit from it good
    function showListToScout() internal {
        int32 showID = 0; //Here will be good to show NAME OF KINGDOM instead ID
        for ((, address addr) : playersAliveList) {
            playersIDList[showID] = addr;
            showID++;
            Terminal.print(0, format("| {} | at address {}", showID, addr));  
        }
        Terminal.input(tvm.functionId(sendScoutChooseAim),"Enter ID of kingdom to explore",false);
    }

    function sendScoutChooseAim(string value) public {
        (uint res, bool status) = stoi(value);
        if (status) {
            aimToScoutAddr = playersIDList[int32(res)]; 
            sendScoutForInfo(); 
        }
        else {
            Terminal.input(tvm.functionId(sendScoutChooseAim),"Wrong ID. Try again!\nEnter ID of kingdom to explore",false);

        }
    }

    function sendScoutForInfo() public {
        optional(uint256) none;
        IWarGameScout(Scout_Addr).getEnemyUnitsInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none, 
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(getScoutedInfo),
            onErrorId: 0
        }(aimToScoutAddr);
    }
    
    function getScoutedInfo() public {
        optional(uint256) none;
        IWarGameScout(Scout_Addr).getScoutedInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none, 
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(setScoutedInfo),  
            onErrorId: 0
        }();
    }

    function setScoutedInfo(mapping(address => mapping (int32 => Information)) _scoutedInfo) public {
        ScoutedInfo = _scoutedInfo; 
        showScoutedInfo();
    }

    function showScoutedInfo() internal {
        enemyUnitsInfo = ScoutedInfo[aimToScoutAddr];
        if (enemyUnitsInfo.empty()) {
            Terminal.print(0, "No alive units in this kingdom");
        }
        else {
            for ((int32 unitID , Information InfoExample) : enemyUnitsInfo) {    
            Terminal.print(0, format(" ID: {} || Type: \"{}\" || Health: {} || Attack power: {} || Defence power: {}", 
                unitID, 
                InfoExample.itemType,
                InfoExample.itemHealth,
                InfoExample.itemAttack, 
                InfoExample.itemDefence)); 
            }
        }
        goKingdomMenu();
    }

    // function setAddrForRequest_Warrior(uint32 index) public view {
    //     index = index;
    //     address ExampleAddr = Warrior_Addr; ////////////////////////////////////////////////// JUST FOR TEST! SET IN ANOTHER WAY!
    //     requestInformation(ExampleAddr);
    // }

    // function requestInformation(address ExampleAddr) public view {
    //     optional(uint256) none;
    //     IWarGameObj(ExampleAddr).getInfo{
    //         abiVer: 2,
    //         extMsg: true,
    //         sign: false,
    //         pubkey: none,
    //         time: uint64(now),
    //         expire: 0,
    //         callbackId: tvm.functionId(showObjInfo),
    //         onErrorId: 0
    //     }(); 
    // } 

    // function showObjInfo(Information ObjectInfo) public {
    //     Terminal.print(0, format(" ID: {} || Type: \"{}\" || Address: {} || Owner PubKey: {} || Health: {} || Attack power: {} || Defence power: {}", 
    //         ObjectInfo.itemID,
    //         ObjectInfo.itemType,
    //         ObjectInfo.itemAddr,
    //         ObjectInfo.itemOwnerPubkey,
    //         ObjectInfo.itemHealth,
    //         ObjectInfo.itemAttack, 
    //         ObjectInfo.itemDefence)); 
    //     goKingdomMenu();
    // }

    // function getBaseUnitsInfo() public {
    //     optional(uint256) none;
    //     IWarGameBase(Base_Addr).getUnitsInfo{
    //         abiVer: 2,
    //         extMsg: true,
    //         sign: false,
    //         pubkey: none, 
    //         time: uint64(now),
    //         expire: 0,
    //         callbackId: tvm.functionId(setUnitsInfo),
    //         onErrorId: 0
    //     }();
    // }

    // function setUnitsInfo(mapping(int32 => Information) newUnitsInfo) public {
    //     UnitsInfo = newUnitsInfo;
    //     showUnitsInfo();
        
    // }

    // function showUnitsInfo() internal {
    //     if (UnitsInfo.empty()) {
    //         Terminal.print(0, "You have no alive units. Produce some in kingdom menu.");
    //     }
    //     else {
    //         for ((int32 unitID , Information InfoExample) : UnitsInfo) {    
    //         Terminal.print(0, format(" ID: {} || Type: \"{}\" || Address: {} || Owner PubKey: {} || Health: {} || Attack power: {} || Defence power: {}", 
    //             unitID, 
    //             InfoExample.itemType,
    //             InfoExample.itemAddr,
    //             InfoExample.itemOwnerPubkey,
    //             InfoExample.itemHealth,
    //             InfoExample.itemAttack, 
    //             InfoExample.itemDefence)); 
    //         }
    //     }
    //     showUnitsInfoExit();
    // }

    // function showUnitsInfoExit() internal{
    //     if (attackProcessing) {
    //         Terminal.input(tvm.functionId(sendAttackChooseAim),"Enter ID of unit who will attack",false);
            
    //     }
    //     else {
    //         goKingdomMenu();
    //     }
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
    
}
