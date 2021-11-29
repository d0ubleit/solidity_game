pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../debotBase/Debot.sol";
import "../debotBase/Terminal.sol";
import "../debotBase/Menu.sol";
import "../debotBase/AddressInput.sol";
import "../debotBase/ConfirmInput.sol";
import "../debotBase/Upgradable.sol";
import "../debotBase/Sdk.sol";

import "WarGameStructs.sol";
import "IWarGame_interfaces.sol";
import "IWGBot_interfaces.sol";


contract WGBot_Units is Debot, Upgradable{  
    bytes m_icon; 

    address InitialWGB_addr;
    uint256 playerPubkey;
    
    address Scout_Addr;
    address kingdomToScoutAddr;

    bool attackProcessing = false;
    int32 attackerUnitID;
    address attackerUnitAddr;
    address aimKingdomAddr;
    address aimUnitAddr;

    mapping (int32 => address) playersIDList;
    mapping (address => mapping (int32 => Information)) ScoutedInfo;
    
    mapping(int32 => Information) UnitsInfo;
     
    mapping (int32 => address) enemiesList;
    
    function start() public override {        
    }
    

    function invokeSendScout(uint256 _playerPubkey, mapping (int32 => address) _playersIDList, address _Scout_Addr) public {
        playerPubkey = _playerPubkey;
        InitialWGB_addr = msg.sender;
        playersIDList = _playersIDList;
        Scout_Addr = _Scout_Addr;
        sendScout_Start();
    }
    

    function returnKingdomMenu() internal {
        IWGBot_initial(InitialWGB_addr).updateUnitsInfo();
    }


    function sendScout_Start() public {
        if (Scout_Addr.isStdZero()) {
            Terminal.print(0, "You don't have scout. [Produce scout] in produce menu");
            returnKingdomMenu();
        } 
        else {
            showPlayersList();
        }
    }


    function showPlayersList() internal { 
        //Here better to show NAME OF KINGDOM instead ID
        for ((int32 playerID, address playerAddr ) : playersIDList) {
            Terminal.print(0, format("| {} | at address {}", playerID, playerAddr));  
        }
        Terminal.input(tvm.functionId(sendScout_1),"Enter ID of kingdom to explore",false);
    }


    function sendScout_1(string value) public {
        (uint res, bool status) = stoi(value);
        if (status) {
            kingdomToScoutAddr = playersIDList[int32(res)]; 
            req_sendScout(); 
        }
        else {
            Terminal.input(tvm.functionId(sendScout_1),"Wrong ID. Try again!\nEnter ID of kingdom to explore",false);
        }
    }


    function req_sendScout() internal {
        IWarGameScout(Scout_Addr).getEnemyUnitsInfo{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: playerPubkey, 
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(getScoutedInfo),
            onErrorId: tvm.functionId(onError) 
        }(kingdomToScoutAddr);
    }


    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        returnKingdomMenu(); 
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
        //ScoutedInfo.add(_scoutedInfo);
        for ((address enemyAddr, mapping (int32 => Information) enemyInfo) : _scoutedInfo) {
            ScoutedInfo[enemyAddr] = enemyInfo;
        } 
        if (!attackProcessing) {
            Terminal.print(0, "Your scout got some info:");
            showScoutedInfo(kingdomToScoutAddr);
            returnKingdomMenu(); 
        }
        else{
            sendAttack_Start();
        }
    } 


    function showScoutedInfo(address _kingdomToScoutAddr) internal {
        if (ScoutedInfo.empty()) {
            Terminal.print(0, "There are no alive units in this kingdom.");
        }
        else {
            for ((int32 unitID , Information InfoExample) : ScoutedInfo[_kingdomToScoutAddr]) {    
                Terminal.print(0, format("     ID: {}  <{}> || Health: {} ", 
                    unitID, 
                    InfoExample.itemType,
                    InfoExample.itemHealth
                    )); 
                } 
        }
    }




    function invokeSendAttack(uint256 _playerPubkey, mapping(int32 => Information) _UnitsInfo) external { 
        playerPubkey = _playerPubkey;
        InitialWGB_addr = msg.sender; 
        UnitsInfo = _UnitsInfo;
        for ((int32 ExampleID, Information InfoExample) : UnitsInfo) {
            if (Scout_Addr.isStdZero()){
                if (InfoExample.itemType=="Scout") {
                    Scout_Addr = InfoExample.itemAddr;
                }
            }
        }
        if (Scout_Addr.isStdZero()){
            Terminal.print(0, "You have no scout alive, let's see for some saved scouted info..");
            if (ScoutedInfo.empty()) {
                Terminal.print(0, "There is no previous scouted info.");
                returnKingdomMenu();
            }       
            else {
                attackProcessing = true;
                sendAttack_Start();
            }
        }
        else {
            if (ScoutedInfo.empty()) {
                Terminal.print(0, "Here is info recieved from scout:");
                attackProcessing = true;
                getScoutedInfo();
            }       
            else {
                Terminal.print(0, "Here is last saved info:");
                attackProcessing = true;
                sendAttack_Start();
            }
            
        }
    } 


    function sendAttack_Start() public {
        
        if (UnitsInfo.empty()) {
            Terminal.print(0, "You have no alive units. Produce some in kingdom menu.");
            attackProcessing = false;
            returnKingdomMenu(); 
        }
        else {
            if (ScoutedInfo.empty()) {
                Terminal.print(0, "You didn't explore any kingdom. Send scout.");
                attackProcessing = false;
                returnKingdomMenu();
            }
            else {
                for ((int32 unitID , Information InfoExample) : UnitsInfo) {     
                    if (unitID > 0) {
                    Terminal.print(0, format(" ID: {} | {} || Health: {} || Attack: {} || Defence: {} || At address:\n{}", 
                        InfoExample.itemID,
                        InfoExample.itemType,
                        InfoExample.itemHealth,
                        InfoExample.itemAttack, 
                        InfoExample.itemDefence,
                        InfoExample.itemAddr)); 
                    }
                }
                Terminal.input(tvm.functionId(sendAttack_1),"Enter ID of unit who will attack",false);
            }
        }
    }

    function sendAttack_1(string value) public {
        int32 ExampleID = 1;
        (uint res, bool status) = stoi(value);
        if (status) {
            attackerUnitID = int32(res);
            if (attackerUnitID > 0 && UnitsInfo.exists(attackerUnitID)) {
                attackerUnitAddr = UnitsInfo[attackerUnitID].itemAddr;

                for ((address addrExample, mapping (int32 => Information) unitsInfoExample) : ScoutedInfo) {
                    enemiesList[ExampleID] = addrExample;
                    Terminal.print(0, format("Units of kingdom [ID: {}]:", ExampleID)); /////Here better to write NAME of kingdom////////////////////
                    showScoutedInfo(addrExample);
                    ExampleID++; 
                }

                Terminal.input(tvm.functionId(sendAttack_2),"Enter ID of kingdom",false);
            }
            else {
                Terminal.input(tvm.functionId(sendAttack_1),"No such ID. Try again!\nEnter ID of unit who will attack",false);
            }
        }
        else {
            Terminal.input(tvm.functionId(sendAttack_1),"Wrong ID. Try again!\nEnter ID of unit who will attack",false);

        }
    }


    function sendAttack_2(string value) public {
        (uint res, bool status) = stoi(value);
        if (status && enemiesList.exists(int32(res))) {
            aimKingdomAddr = enemiesList[int32(res)];
            showScoutedInfo(aimKingdomAddr);
            Terminal.input(tvm.functionId(sendAttack_3),"Enter ID of aim unit",false);
        }
        else {
            Terminal.input(tvm.functionId(sendAttack_2),"Wrong ID. Try again!\nEnter ID of kingdom",false);

        }
    }


    function sendAttack_3(string value) public {
        (uint res, bool status) = stoi(value);
        if (status && ScoutedInfo[aimKingdomAddr].exists(int32(res))) {
            aimUnitAddr = ScoutedInfo[aimKingdomAddr][int32(res)].itemAddr;
            
            Sdk.getAccountType(tvm.functionId(checkAccountStatus), aimUnitAddr);
        }
        else {
            Terminal.input(tvm.functionId(sendAttack_3),"Wrong ID. Try again!\nEnter ID of aim unit",false);

        }
    }


    function checkAccountStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            if (attackProcessing){
                req_sendAttack();
            }
            else {
                req_ObjInfo(aimUnitAddr);
            }
        } else {
            Terminal.print(0, "Unit is DEAD now or it's balance too low");
            attackProcessing = false;
            returnKingdomMenu();
        }
    }


    function req_sendAttack() public {
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
        Terminal.print(0, "Attack successfully done with result:");
        attackProcessing = false;
        Sdk.getAccountType(tvm.functionId(checkAccountStatus), aimUnitAddr);
    } 


    function req_ObjInfo(address _aimUnitAddr) internal { 
        optional(uint256) none;
        IWarGameObj(_aimUnitAddr).getInfo{
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
        Terminal.print(0, format(" Type: \"{}\" || Health: {} || Attack power: {} || Defence power: {}", 
            ObjectInfo.itemType,
            ObjectInfo.itemHealth,
            ObjectInfo.itemAttack, 
            ObjectInfo.itemDefence
            )); 
        
        updateScoutedInfo(ObjectInfo);   
    }


    function updateScoutedInfo(Information ObjectInfo) internal {
        ScoutedInfo[aimKingdomAddr][ObjectInfo.itemID] = ObjectInfo;
        returnKingdomMenu();
    }

    


    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "EverWar Game Units DeBot";
        version = "0.1.0";
        publisher = "d0ubleit";
        key = "EverWar Game DeBot";
        author = "d0ubleit";
        support = address.makeAddrStd(0, 0x81b6312da6eaed183f9976622b5a39a90d5cff47e4d2a541bd97ee216e8300b1);
        hello = "Welcome to strategy blockchain game!";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }
    
}
