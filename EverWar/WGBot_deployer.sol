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
import "IWGBot_interfaces.sol"; 


contract WGBot_deployer is Debot, Upgradable {

    bytes m_icon;

    address InitialWGB_addr;

    TvmCell Base_Code;

    TvmCell Warrior_Code;         

    TvmCell Scout_Code;         

    TvmCell Produce_StateInit;
    address Produce_Addr;
    address Base_Addr;
    address Storage_Addr;

    uint256 playerPubkey; 
    address playerWalletAddr;

    DeployType deployType;
    Status status;
    int32 mainUnitID;

    uint32 INITIAL_BALANCE =  2000000000; 


    ///////////////
    // Set Codes //
    ///////////////
    function setWGBaseCode(TvmCell code) public {
        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        Base_Code = code;
    }


    function setWGWarriorCode(TvmCell code) public {
        require(msg.pubkey() == tvm.pubkey(), 101); 
        tvm.accept();
        Warrior_Code = code;
    }


     function setWGScoutCode(TvmCell code) public {
        require(msg.pubkey() == tvm.pubkey(), 101); 
        tvm.accept();
        Scout_Code = code;
    }

    //
    //
    //
    function start() public override {        
    }


    function invokeDeployer_start(uint _playerPubkey, DeployType _deployType, address _Base_Addr, address _Storage_Addr, int32 _mainUnitID) external {
        InitialWGB_addr = msg.sender;
        playerPubkey = _playerPubkey;
        deployType = _deployType;
        Base_Addr = _Base_Addr;
        Storage_Addr = _Storage_Addr;
        mainUnitID = _mainUnitID;

        if (deployType == DeployType.Base) {
            prepareProduce(deployType);
        }
        else {
            goDeployMenu();
        }
    }


    function goDeployMenu() internal {   
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "What unit you need to create?"),
            sep,
            [
                MenuItem("Produce warrior","",tvm.functionId(produceWarrior)), 
                MenuItem("Produce scout","",tvm.functionId(produceScout)),
                MenuItem("<=== Back","",tvm.functionId(returnKingdomMenu))   
            ]
        );
    }


    function produceWarrior() public {
        deployType = DeployType.Warrior;
        prepareProduce(deployType);
    }
 

    function produceScout() public {
        deployType = DeployType.Scout;
        prepareProduce(deployType);     
    }


    function returnKingdomMenu() public {
        IWGBot_initial(InitialWGB_addr).updateUnitsInfo();
    } 
 

    function prepareProduce(DeployType _deployType) internal { 
        TvmBuilder salt;
        salt.store(InitialWGB_addr);

        if (deployType == DeployType.Base) {
            TvmCell Base_Code_salt = tvm.setCodeSalt(Base_Code, salt.toCell()); 
            Produce_StateInit = tvm.buildStateInit({code: Base_Code_salt, contr: AWarGameExample, varInit: {exampleID: mainUnitID}});    
            TvmCell deployState = tvm.insertPubkey(Produce_StateInit, playerPubkey);
            Produce_Addr = address.makeAddrStd(0, tvm.hash(deployState));
            Base_Addr = Produce_Addr;                                             
            Terminal.print(0, format( "Info: your Kingdom address is {}", Produce_Addr));
        }
        else if (deployType == DeployType.Warrior) {
            TvmCell Warrior_Code_salt = tvm.setCodeSalt(Warrior_Code, salt.toCell());
            Produce_StateInit = tvm.buildStateInit({code: Warrior_Code_salt, contr: AWarGameExample, varInit: {exampleID: mainUnitID}});  
            TvmCell deployState = tvm.insertPubkey(Produce_StateInit, playerPubkey);
            Produce_Addr = address.makeAddrStd(0, tvm.hash(deployState)); 
            Terminal.print(0, format( "Info: your Warrior address is {}", Produce_Addr));
        }
        else if (deployType == DeployType.Scout) {
            TvmCell Scout_Code_salt = tvm.setCodeSalt(Scout_Code, salt.toCell());
            Produce_StateInit = tvm.buildStateInit({code: Scout_Code_salt, contr: AWarGameExample, varInit: {exampleID: mainUnitID}});   
            TvmCell deployState = tvm.insertPubkey(Produce_StateInit, playerPubkey);
            Produce_Addr = address.makeAddrStd(0, tvm.hash(deployState)); 
            Terminal.print(0, format( "Info: your Scout address is {}", Produce_Addr));
        }
        Sdk.getAccountType(tvm.functionId(checkAccountStatus), Produce_Addr);    
    }
    
    function checkAccountStatus(int8 acc_type) public {
        if (acc_type == 1) { // acc is active and  contract is already deployed
            Terminal.print(0, "Dont know how you get here, but you already have this contract");
            status = Status.AlreadyDeployed;
            returnResult();

        } else if (acc_type == -1)  { // acc is inactive
            status = Status.LowFunds;
            Terminal.print(0, "Contract with an initial balance of 2 tokens will be deployed");
            AddressInput.get(tvm.functionId(creditAccount),"Select a wallet for payment. We will ask you to sign three transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your kingdom contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            status = Status.FrozenAcc;
            Terminal.print(0, format("Can not continue: account {} is frozen", Produce_Addr)); 
            returnResult(); 
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
        }(Produce_Addr, INITIAL_BALANCE, false, 3, empty);
    }


    function onErrorRepeatCredit(uint32 sdkError, uint32 exitCode) public {
        //check errors if needed.
        status = Status.Error;
        sdkError;
        exitCode;
        Terminal.print(0, format("On error repeat credit \n sdkError {} \n exitCode {} ", sdkError, exitCode));
        creditAccount(playerWalletAddr);
    }


    function waitBeforeDeploy() public  {
        Sdk.getAccountType(tvm.functionId(checkContractDeployed), Produce_Addr);
    }


    function checkContractDeployed(int8 acc_type) public {
        if (acc_type ==  0) {
            deploy();
        } else {
            waitBeforeDeploy();
        }
    }


    function deploy() internal virtual view { 
            TvmCell image = tvm.insertPubkey(Produce_StateInit, playerPubkey); 
            optional(uint256) none;
            TvmCell deployMsg = tvm.buildExtMsg({
                abiVer: 2,
                dest: Produce_Addr, 
                callbackId: tvm.functionId(onSuccessDeploy), 
                onErrorId:  tvm.functionId(onErrorRepeatDeploy),    // Just repeat if something went wrong
                time: 0,
                expire: 0,
                sign: true,
                pubkey: none,
                stateInit: image,
                call: {AWarGameExample, playerPubkey, Base_Addr, Storage_Addr} 
            });
            tvm.sendrawmsg(deployMsg, 1);
    }


    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {
        // check errors if needed.
        sdkError;
        exitCode;
        deploy();
    }   


    function onSuccessDeploy() public virtual {
        status = Status.Success;
        if (deployType == DeployType.Base) {
            //BaseID++;
            Terminal.print(0, "Your kingdom is ready! Have a nice game!\nOne more transaction to register your kingdom at storage... "); 
        }
        else if (deployType == DeployType.Warrior) {
            //WarriorID++;
            Terminal.print(0, "Your warrior is ready to attack!"); 
        }
        else if (deployType == DeployType.Scout) {
            //ScoutID++; 
            Terminal.print(0, "Your scout is ready to explore other kingdoms!");
        }     
        returnResult();     
    }

    function returnResult() internal {
        Status _status = status;
        DeployType _deployType = deployType;
        address _Produce_Addr = Produce_Addr;
        IWGBot_initial(InitialWGB_addr).deployResult(_status, _deployType, _Produce_Addr); 
    }




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
        name = "EverWar Game Deployer DeBot";
        version = "0.1.0";
        publisher = "d0ubleit";
        key = "Ever War Deployer DeBot";
        author = "d0ubleit";
        support = address.makeAddrStd(0, 0x81b6312da6eaed183f9976622b5a39a90d5cff47e4d2a541bd97ee216e8300b1);
        hello = "Welcome to strategy blockchain game!";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

}
