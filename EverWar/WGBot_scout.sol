pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_infos.sol";
//import "AWarGameExample.sol"; 
//import "IWarGameObj.sol";

contract WGBot_scout is WGBot_infos { 
    
    //bool scoutProcessing;
    address aimToScoutAddr;

    //mapping (int32 => address) playersIDList;
    mapping (address => mapping (int32 => Information)) ScoutedInfo;
    mapping (int32 => Information) enemyUnitsInfo;
    mapping (int32 => address) enemiesList;
    
    function sendScout_Start() public {
        //scoutProcessing = true;
        if (Scout_Addr.isStdZero()) {
            Terminal.print(0, "You don't have scout. [Produce scout] in kingdom menu");
            goKingdomMenu();
        } 
        else {
            returnFuncID = tvm.functionId(sendScout_1);
            showPlayersList_m();
        }
    }

    function sendScout_1() public{
        Terminal.input(tvm.functionId(sendScout_2),"Enter ID of kingdom to explore",false);
    }

    function sendScout_2(string value) public {
        (uint res, bool status) = stoi(value);
        if (status) {
            aimToScoutAddr = playersIDList[int32(res)]; 
            req_sendScout(); 
        }
        else {
            Terminal.input(tvm.functionId(sendScout_2),"Wrong ID. Try again!\nEnter ID of kingdom to explore",false);

        }
    }

    function req_sendScout() internal {
        //optional(uint256) none;
        IWarGameScout(Scout_Addr).getEnemyUnitsInfo{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: playerPubkey, 
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(getScoutedInfo),
            onErrorId: tvm.functionId(onError) 
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
        returnFuncID = tvm.functionId(goKingdomMenu); 
        showScoutedInfo(ScoutedInfo, aimToScoutAddr);
    }

    //////This function made in bad style//////////////////////////////// MAKE IT BETTER
    function showScoutedInfo(mapping(address => mapping (int32 => Information)) _scoutedInfo, address _kingdomAddr) internal {
        int32 ExampleID = 1;
        if (_scoutedInfo.empty()) {
            Terminal.print(0, "There are no alive units in this kingdom.");
            goKingdomMenu();
        }
        else {
            Terminal.print(0, "Your LAST SCOUTED info:");
            if (_kingdomAddr.isStdZero()) {
                for ((address addrExample, mapping (int32 => Information) unitsInfoExample) : _scoutedInfo) {
                    enemiesList[ExampleID] = addrExample;
                    Terminal.print(0, format("Units of kingdom [ID: {}]:", ExampleID)); /////Here better to write NAME of kingdom////////////////////
                    for ((int32 unitID , Information InfoExample) : unitsInfoExample) {    
                        Terminal.print(0, format("      ID: {} || Type: \"{}\" || Health: {} ", 
                        unitID, 
                        InfoExample.itemType,
                        InfoExample.itemHealth
                    )); 
                    ExampleID++;
                }
                }

            }
            else {
                for ((int32 unitID , Information InfoExample) : _scoutedInfo[_kingdomAddr]) {    
                Terminal.print(0, format(" ID: {} || Type: \"{}\" || Health: {} ", 
                    unitID, 
                    InfoExample.itemType,
                    InfoExample.itemHealth
                    )); 
                }
            }
            commutator();
        }
    }

    // function getDebotInfo() public functionID(0xDEB) virtual override view returns(
    //     string name, string version, string publisher, string key, string author,
    //     address support, string hello, string language, string dabi, bytes icon
    // ) {
    //     name = "EverWar Game DeBot";
    //     version = "0.0.2";
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
