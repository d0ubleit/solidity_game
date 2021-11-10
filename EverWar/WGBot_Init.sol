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

import "AWarGameExample.sol";
import "WarGameStructs.sol";
import "Itransactable.sol";


abstract contract WGBot_Init is Debot, Upgradable {
    bytes m_icon;

    TvmCell Base_Code;
    TvmCell Base_Data;
    TvmCell Base_StateInit; 
    address Base_Addr;  
    GameStat gameStat;        
    int32 BaseID = 1;    
    uint256 playerPubkey; 
    address playerWalletAddr;
    mapping(uint => address) playersAliveList; 
    uint32 INITIAL_BALANCE =  200000000;

    // Don't like to use it this way //
    // Find a way to set parameters for callback functions or another //
    address produceAddr;
    int32 produceType = 0;
        //produceType means what type of contract will be deployed:
        //  0 = WarGameBase
        //  1 = WarGameWarrior
        //  ...


    function setWGBaseCode(TvmCell code, TvmCell data) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        Base_Code = code;
        Base_Data = data;
        //Base_StateInit = tvm.buildStateInit(Base_Code, Base_Data);
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
            //Terminal.print(0, "Checking if you already have kingdom and it's alive...");
            // TvmCell deployState = tvm.insertPubkey(Base_StateInit, playerPubkey);
            // Base_Addr = address.makeAddrStd(0, tvm.hash(deployState));
            // Terminal.print(0, format( "Info: your Shopping List contract address is {}", Base_Addr));
            // Sdk.getAccountType(tvm.functionId(checkAccountStatus), Base_Addr);
            checkIfBaseExists();
            
        } else {
            Terminal.input(tvm.functionId(savePublicKey),"Wrong public key. Try again!\nPlease enter your public key",false);
        }
    }

    function checkIfBaseExists() internal{
        if (playersAliveList.exists(playerPubkey)) { 
            Terminal.print(0, "You already have kingdom, enjoy the game!");
            goMainMenu_Signed();
            }
        else {
            Terminal.print(0, "To start game press button [Create KINGDOM!]");
            goMainMenu_UnSigned();
            //produceBase(); 

        } 
    }

    function goMainMenu_Signed() public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Kingdoms alive: {}",
                    gameStat.basesAlive
                    
            ),
            sep,
            [
                //MenuItem("Create KINGDOM!","",tvm.functionId(savePublicKey)),
                MenuItem("My kingdom","",tvm.functionId(goKingdomMenu))
                // MenuItem("Delete from shopping list","",tvm.functionId(deleteListItem))
            ]
        );
    } 

    function goMainMenu_UnSigned() public {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Kingdoms alive: {}",
                    gameStat.basesAlive
                    
            ),
            sep,
            [
                MenuItem("Create KINGDOM!","",tvm.functionId(produceBase)) 
                //MenuItem("My kingdom","",tvm.functionId(goKingdomMenu))
                //MenuItem("Delete from shopping list","",tvm.functionId(deleteListItem))
            ]
        );
    }     
        
    function produceBase() public {
        produceType = 0;
        Terminal.print(0, "Preparing...");
        Base_StateInit = tvm.buildStateInit({code: Base_Code, contr: AWarGameExample, varInit: {exampleID: BaseID}});//////////////////////////////////////   
        TvmCell deployState = tvm.insertPubkey(Base_StateInit, playerPubkey);
        Base_Addr = address.makeAddrStd(0, tvm.hash(deployState));
        Terminal.print(0, format( "Info: your Kingdom address is {}", Base_Addr));
        produceAddr = Base_Addr;
        Sdk.getAccountType(tvm.functionId(checkAccountStatus), produceAddr);
    }
    
    function checkAccountStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            Terminal.print(0, "Dont know how you get here, but you already have this contract");
            goMainMenu_Signed();
            //requestGetSummary(tvm.functionId(setSummary));  


        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "Contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your kingdom contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", produceAddr)); 
        }
    }

    function creditAccount(address value) public {
        playerWalletAddr = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        Itransactable(playerWalletAddr).sendTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitBeforeDeploy),
            onErrorId: tvm.functionId(onErrorRepeatCredit)  // Just repeat if something went wrong
        }(produceAddr, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        //check errors if needed.
        sdkError;
        exitCode;
        creditAccount(playerWalletAddr);
    }

    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkContractDeployed), produceAddr);
    }

    function checkContractDeployed(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }

    function deploy() internal virtual view { 
            TvmCell image = tvm.insertPubkey(Base_StateInit, playerPubkey);
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: produceAddr,
                callbackId: tvm.functionId(onSuccess),
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {AWarGameExample, playerPubkey, produceAddr} 
            });
            tvm.sendrawmsg(deployMsg, 1);
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }   
     
    function onSuccess() public virtual  {       //view{
        //requestGetSummary(tvm.functionId(setSummary));
        BaseID++;
        playersAliveList[playerPubkey] = produceAddr;
        gameStat.basesAlive++;
        Terminal.print(0, "Your kingdom is ready! Have a nice game!");
        goMainMenu_Signed(); 
    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        goMainMenu_UnSigned();
    }

    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    // function requestGetSummary(uint32 answerId) private view {
    //     optional(uint256) none;
    //     IshoppingList(Base_Addr).getShoppinngSummary{
    //         abiVer: 2,
    //         extMsg: true,
    //         sign: false,
    //         pubkey: none,
    //         time: uint64(now),
    //         expire: 0,
    //         callbackId: answerId,
    //         onErrorId: 0
    //     }();
    // }

    // function setSummary(GameStat summary) public {
    //     SL_Summary = summary;
    //     openMenu();
    // }
    
    function goKingdomMenu() public virtual{

    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    function getDebotInfo() public functionID(0xDEB) virtual override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {   
    }

}
