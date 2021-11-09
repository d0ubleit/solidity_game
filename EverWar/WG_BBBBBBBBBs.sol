pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "DeBotSL_Init.sol";

// SL = Shopping List
contract DeBotSL_Manager is DeBotSL_BaseMethods {

    string _itemName;
    
    function openMenu() public override {
        string sep = '----------------------------------------';
        Menu.select(
            format(
                "Shopping list: Not paid: {} | Paid: {} | Total: {}",
                    SL_Summary.numItemsNotPaid,
                    SL_Summary.numItemsPaid,
                    SL_Summary.numItemsNotPaid + SL_Summary.numItemsPaid
            ),
            sep,
            [
                MenuItem("Add to shopping list","",tvm.functionId(addToList_name)),
                MenuItem("Show shopping list","",tvm.functionId(requestShowShoppingList)),
                MenuItem("Delete from shopping list","",tvm.functionId(deleteListItem))
            ]
        );
    }

    function addToList_name(uint32 index) public {
        index = index;
        Terminal.input(tvm.functionId(addToList_num), "Name of item you want to buy:", false);
    }

    function addToList_num(string value) public {
        _itemName = value;
        Terminal.input(tvm.functionId(requestAddToList), "How many items you need:", false);
    }

    function requestAddToList(string value) public view {
        (uint256 _itemNum,) = stoi(value);
        optional(uint256) pubkey = 0;
        IshoppingList(SL_address).addItemToList{
                abiVer: 2,
                extMsg: true,
                sign: true,
                pubkey: pubkey,
                time: uint64(now), 
                expire: 0,
                callbackId: tvm.functionId(onSuccess),
                onErrorId: tvm.functionId(onError)
            }(_itemName, int32(_itemNum)); 
    }  

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Shopping List Manager DeBot";
        version = "0.1";
        publisher = "d0ubleit";
        key = "Shopping List Manager";
        author = "d0ubleit";
        support = address.makeAddrStd(0, 0x81b6312da6eaed183f9976622b5a39a90d5cff47e4d2a541bd97ee216e8300b1);
        hello = "This is Shopping List Manager DeBot. Here you can manage your shopping list (add, delete, show list)";
        language = "en";
        dabi = m_debotAbi.get(); //Not changed to left base files untouched
        icon = Icon; 
    }
}
