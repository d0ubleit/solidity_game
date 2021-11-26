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
import "Itransactable.sol";
 

contract WGBot_initial is Debot, Upgradable { 

    bytes m_icon;

    uint32 returnFuncID;
    uint32 callerFuncID;
    bool showPL = false;

    address StorageAddr;
    address WGBot_deployerAddr;
    address WGBot_UnitsAddr;  
          
    uint256 playerPubkey; 

    DeployType deployType;
    Status deployStatus;

    GameStat gameStat;
    
    mapping(uint => int32) playersAliveList; 
    mapping (int32 => address) playersIDList;
    
    address Base_Addr;
    address Scout_Addr;
    address Produce_Addr;

    int32 mainUnitID;


    function setAddreses(address storageAddress, address wgBot_deployerAddr, address wgBot_UnitsAddr) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        StorageAddr = storageAddress; 
        WGBot_deployerAddr = wgBot_deployerAddr;
        WGBot_UnitsAddr = wgBot_UnitsAddr;
    }

    
    function start() public override {
        Terminal.print(0, "Welcome to EverWar! Prepare to battle!");
        Terminal.input(tvm.functionId(savePublicKey),"Please enter your public key",false);   
    }
 

    function savePublicKey(string value) public {
        (uint res, bool status) = stoi("0x"+value);
        if (status) {
            playerPubkey = res;
            showPL = false;
            returnFuncID = tvm.functionId(goMainMenu);
            requestGetPlayersList(tvm.functionId(setPlayersList)); 

        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }


    //////////////////////////////////////////////////////
    // Join PlayersList and Stat later to make 1 request//
    //////////////////////////////////////////////////////
    function requestGetPlayersList(uint32 answerId) internal view {
        optional(uint256) none;
        IWarGameStorage(StorageAddr).getPlayersAliveList{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }


    function setPlayersList(mapping(uint => int32) playersList, mapping (int32 => address) _playersIDList) public { 
        playersAliveList = playersList;
        playersIDList = _playersIDList;
        requestGetStat(tvm.functionId(setStat));
    }
    

    function requestGetStat(uint32 answerId) internal view { 
        optional(uint256) none;
        IWarGameStorage(StorageAddr).getStat{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }


    function setStat(GameStat Statistics) public {
        gameStat = Statistics;
        if (showPL) {
            showPlayersList_m();
        }
        else {
            commutator();
        }
    }


    function showPlayersList_m() internal { 
        //Better to show NAME OF KINGDOM instead ID
        for ((, int32 itemID) : playersAliveList) {
            Terminal.print(0, format("| {} | at address {}", itemID, playersIDList[itemID]));  
        }
        showPL = false; 
        commutator();
    }


    function commutator() internal virtual {
        if (returnFuncID == tvm.functionId(goMainMenu)) { 
            returnFuncID = 0;
            goMainMenu();
        }
        else {
            returnFuncID = 0;
            goMainMenu();
        }
    }
   

    function goMainMenu() public { 
        string sep = '----------------------------------------';
        if (!playersAliveList.exists(playerPubkey)) {
            Terminal.print(0, "To start game you need to [Create KINGDOM!]");
            
            Menu.select(
            format(
                "Kingdoms alive: {}", gameStat.basesAlive),
            sep,
            [
                MenuItem("Create KINGDOM!","",tvm.functionId(req_produceBase)),
                MenuItem("Description","",tvm.functionId(showDescription))  
            ]);
        }
        
        else {
            Base_Addr = playersIDList[playersAliveList[playerPubkey]];       
            Menu.select(
                format(
                    "Kingdoms alive: {}", gameStat.basesAlive),
                sep,
                [
                    MenuItem("My kingdom","",tvm.functionId(updateUnitsInfo)),
                    MenuItem("Show players list","",tvm.functionId(showPlayersList_1)),
                    MenuItem("Description","",tvm.functionId(showDescription)) 
                ]);
        }
    }

    function showDescription() public {
        Terminal.print(0, "Aim of game - to kill other units and kingdoms. You can produce kingdom, warriors and scout.");
        Terminal.print(0, "Kingdom - is your home base. If it destroyed - all your units will also die.");
        Terminal.print(0, "Warrior - attacking unit. Scout - brings you info about units in other kingdoms.");
        Terminal.print(0, "Create your kingdom to start the game.\nIn main menu you can see list of other players' kingdoms.");
        Terminal.print(0, "Info about your units, attack function and scout function in kingdom menu.\nBefore attack you need to scout enemy kingdom.");
        Terminal.print(0, "Create units in produce menu.\n --- Enjoy! ---");
        goMainMenu();
    } 


    function showPlayersList_1() public {
        returnFuncID = tvm.functionId(goMainMenu);
        showPL = true;
        requestGetPlayersList(tvm.functionId(setPlayersList));
    }
    

    function req_produceBase() public {
        uint _playerPubkey = playerPubkey;
        deployType = DeployType.Base;
        DeployType _deployType = deployType;
        address _Base_Addr = Base_Addr;
        address _Storage_Addr = StorageAddr;
        //mainUnitID++;
        int32 _mainUnitID = mainUnitID;
        IWGBot_deployer(WGBot_deployerAddr).invokeDeployer_start(_playerPubkey, _deployType, _Base_Addr, _Storage_Addr, _mainUnitID);
    }


    function deployResult(Status _status, DeployType _deployType, address _Produce_Addr) virtual external {
        deployStatus = _status;
        deployType = _deployType;
        Produce_Addr = _Produce_Addr;
        // Handle errors ///////////////////////////////////////////////////////
        if (deployStatus == Status.Success) {
            if (deployType == DeployType.Base) {
                Base_Addr = Produce_Addr;
                saveToStorage(); 
            }
            else if (deployType == DeployType.Scout) {
                Scout_Addr = Produce_Addr;
                checkAccStatus(Produce_Addr);
            }
            else {
                checkAccStatus(Produce_Addr);
            }
        }
        else {
            Terminal.print(0, format("Something wrong, so sorry\n Status {} \n Deploy type {} \n Contract address {} \n{}",
                uint8(deployStatus), uint8(deployType), _Produce_Addr, uint8(Status.Success))); 
            showPL = false;
            returnFuncID = tvm.functionId(goMainMenu);
            requestGetPlayersList(tvm.functionId(setPlayersList));
        }
    }


    function saveToStorage() internal {  
        optional(uint256) pubkey = 0;
        uint _playerPubkey = playerPubkey;
        address _produceAddr = Base_Addr;
        IWarGameStorage(StorageAddr).addToPlayersAliveList{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now), 
                expire: 0,
                callbackId: tvm.functionId(onSuccessFunc),
                onErrorId: tvm.functionId(onError)
            }(_playerPubkey, _produceAddr); 
    } 


    function onSuccessFunc() public {       
        checkAccStatus(Base_Addr);
    } 
    

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        goMainMenu(); 
    }

    
    //
    // Child necessary functions
    //
    function updateUnitsInfo() public virtual{ 
        goMainMenu();
    }
    

    function goKingdomMenu() public virtual{ 
        goMainMenu();
    }


    function checkAccStatus(address _Produce_Addr) internal virtual {
        showPL = false;
        returnFuncID = tvm.functionId(goMainMenu);
        requestGetPlayersList(tvm.functionId(setPlayersList)); 
    }


    //
    // Debot engine functions
    //
    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "EverWar Game Main DeBot";
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

}
