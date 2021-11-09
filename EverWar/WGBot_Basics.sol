pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
    
import "WGBot_Init.sol";
 
// SL = Shopping List
contract WGBot_Basics is WGBot_Init {
    
    function goKingdomMenu() public override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Kingdoms alive: {}",
                    gameStat.basesAlive
                    
            ),
            sep,
            [
                MenuItem("Show INFO","",tvm.functionId(requestBaseInformation))
               // MenuItem("My kingdom","",tvm.functionId(goKingdomMenu))
               // MenuItem("Delete from shopping list","",tvm.functionId(deleteListItem))
            ]
        );
    }   

    function requestBaseInformation(uint32 index) public view {
        index = index;
        optional(uint256) none;
        IWarGameBase(Base_Addr).getInfo{
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showBaseInfo),
            onErrorId: 0
        }();
    }

    function showBaseInfo(Information BaseInfo) public {
        Terminal.print(0, format(" ID: {} || Type: \"{}\" || Address: {} || Owner PubKey: {} || Health: {} || Attack power: {} || Defence power: {}", 
                        BaseInfo.itemID,
                        BaseInfo.itemType,
                        BaseInfo.itemAddr,
                        BaseInfo.itemOwnerPubkey,
                        BaseInfo.itemHealth,
                        BaseInfo.itemAttack, 
                        BaseInfo.itemDefence));
        goKingdomMenu();
        
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
        
    }

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
