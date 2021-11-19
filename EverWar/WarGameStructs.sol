pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

struct Information {
        int32 itemID;
        string itemType;
        address itemAddr;
        uint itemOwnerPubkey;
        int32 itemHealth;
        int32 itemAttack; 
        int32 itemDefence;
    }

struct GameStat {
    int32 basesAlive;
    
}


enum DeployType {
    Empty,
    Base,
    Warrior,
    Scout
}

enum Status {
    Error,
    Success,
    AlreadyDeployed,
    LowFunds,
    FrozenAcc
}