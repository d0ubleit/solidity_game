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

//import "AWarGameExample.sol";
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
          
    uint256 playerPubkey; 

    DeployType deployType;
    Status deployStatus;

    GameStat gameStat;
    
    mapping(uint => int32) playersAliveList; 
    mapping (int32 => address) playersIDList;
    
    address Base_Addr;
    address Scout_Addr;

    address Produce_Addr;


    function setAddreses(address storageAddress, address wgBot_deployerAddr) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        StorageAddr = storageAddress; 
        WGBot_deployerAddr = wgBot_deployerAddr;
    }

    
    function start() public override {
        Terminal.print(0, "Welcome to EverWar! Prepare to battle!");
        //goMainMenu(); 
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
        //Terminal.print(0, "Stat updated");
        if (showPL) {
            showPlayersList_m();
        }
        else {
            commutator();
        }
    }

    function showPlayersList_m() internal { 
        //Here will be good to show NAME OF KINGDOM instead ID
        for ((, int32 itemID) : playersAliveList) {
            Terminal.print(0, format("| {} | at address {}", itemID, playersIDList[itemID]));  
        }
        showPL = false; 
        commutator();
    }

    function commutator() public virtual {
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
                "Kingdoms alive: {}",
                    gameStat.basesAlive
                    
            ),
            sep,
            [
                MenuItem("Create KINGDOM!","",tvm.functionId(req_produceBase)) 
                //MenuItem("My kingdom","",tvm.functionId(goKingdomMenu))
                //MenuItem("Delete from shopping list","",tvm.functionId(deleteListItem))
            ]
        );
        }
        else {
            Base_Addr = playersIDList[playersAliveList[playerPubkey]];       
            Menu.select(
                format(
                    "Kingdoms alive: {}",
                        gameStat.basesAlive
                        
                ),
                sep,
                [
                    //MenuItem("Create KINGDOM!","",tvm.functionId(savePublicKey)),
                    MenuItem("My kingdom","",tvm.functionId(goKingdomMenu)),
                    MenuItem("Show players list","",tvm.functionId(showPlayersList_1)) 
                ]
            );
        }
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
        IWGBot_deployer(WGBot_deployerAddr).invokeProduce(_playerPubkey, _deployType);
    }

    function deployResult(Status _status, DeployType _deployType, address _Produce_Addr) virtual external {
        ////////////////Maybe also check playerPubkey?
        require(deployType == _deployType, 111);
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
                req_ObjInfo(Produce_Addr);
            }
            else {
                req_ObjInfo(Produce_Addr);
                // showPL = false;
                // returnFuncID = tvm.functionId(goMainMenu);
                // requestGetPlayersList(tvm.functionId(setPlayersList));
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

    function onSuccessFunc() public {        //view{
        getBaseObjInfo();
        // showPL = false;
        // returnFuncID = tvm.functionId(goMainMenu);
        // requestGetPlayersList(tvm.functionId(setPlayersList)); 
    } 
    
    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        goMainMenu(); 
    }

    
    //
    // Child necessary functions
    //
    function goKingdomMenu() public virtual{ 
        goMainMenu();
    }

    function getBaseObjInfo() public virtual{
        showPL = false;
        returnFuncID = tvm.functionId(goMainMenu);
        requestGetPlayersList(tvm.functionId(setPlayersList)); 
    }

    function req_ObjInfo(address _Produce_Addr) internal virtual {
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
