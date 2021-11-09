pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct Information {
        int32 itemID;
        string itemType;
        address itemAddr;
        uint itemOwnerPubkey;
        uint32 itemHealth;
        int32 itemAttack; 
        int32 itemDefence;
    }

struct GameStat {
    int32 basesAlive;
}


// struct ShopItem {
//     int32 itemID;
//     string itemName;
//     int32 itemNum;
//     uint64 itemCreationTime;
//     bool itemIsPurchased;
//     int32 itemTotalPrice;
// }

// struct ShopListSummary {
//     int32 numItemsPaid;
//     int32 numItemsNotPaid;
//     int32 totalPricePaid; 
// }