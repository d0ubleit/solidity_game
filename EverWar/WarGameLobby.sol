pragma ton-solidity >= 0.6;
pragma AbiHeader expire;
pragma AbiHeader pubkey;
import "WarGameBase.sol";

contract WarGameLobby {

    uint public adminPubkey;
    //mapping (address => uint) public playersBaseAddrMap;
    mapping (uint => address) public playersPubkeysMap;
    uint baseID = 1;
    address rootBase;     

    constructor(address _rootBase) public {
    //    require(tvm.pubkey() != 0, 101);
    //    require(msg.pubkey() == tvm.pubkey(), 102);
        tvm.accept();
        adminPubkey = msg.pubkey();
        rootBase = _rootBase;
    }

    // modifier checkOwnerAndAccept {
    //     require(msg.pubkey() == adminPubkey, 102);
    //     tvm.accept();
    //     _;
    // }    

    function startGame() public {   //returns(string ans){
        //require(!(playersPubkeysMap.exists(msg.pubkey())), 102, "Error: You already have base!");
        tvm.accept();        
        address newBaseA;
        newBaseA = WarGameBase(rootBase).selfProduceBase(baseID, msg.pubkey()).await;
        tvm.accept();
        playersPubkeysMap[msg.pubkey()] = newBaseA;
        //playersBaseAddrMap[newBaseA] = baseID; 
        baseID++;
        tvm.accept();
        // ans = "Welcome to WarGame! Call getMyBaseAddr method to check your Base address";
        // return ans;          
    } 

    function getMyBaseAddr() public view returns(address) {
        /*!!!*///require(playersPubkeysMap.exists(msg.pubkey()), 102, "Error: There is no base match your pubkey!"); 
        tvm.accept();
        return playersPubkeysMap[msg.pubkey()];  
    } 

    function getPlayersAlive() public view returns(mapping (uint => address)) {
        tvm.accept();
        return playersPubkeysMap;
    }





}  