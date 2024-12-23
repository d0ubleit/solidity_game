# EverWar multiplayer game

This is a game where you can create your own kingdom, produce warriors and scout.
Explore other players' kingdoms, kill enemy units and destroy whole kingdom!!!

## Consists of

Main game contracts:
-   WarGameStorage.sol, WarGameBase.sol, WarGameWarrior.sol, WarGameScout.sol

Main debots:
-   WGBot_kingdom.sol, WGBot_deployer.sol, WGBot_units.sol

## How to try DeBot in the Surf

This DeBot is already deployed on net.ton.dev

DeBot address: 0:c5e19961a82825ccac3a1f94a5694ba5b6a2c624f33b1da1f3f522aac628c130

Open the link: https://uri.ton.surf/debot?address=0%3Ac5e19961a82825ccac3a1f94a5694ba5b6a2c624f33b1da1f3f522aac628c130&net=devnet

-   You need to have a Surf wallet with balance at least 8 rubies to try all functions.

-   DeBot will ask for your public key every time you launch it.

## How to build

### Prerequisites

npm, node.js ver>=14

Install tondev globally

```
$ npm i tondev -g
$ tondev tonos-cli install
```

### Compile and deploy using script

Move to EverWar directory

if you use TON OS SE:

```
$ tondev se start

$ ./deploy_3debotsSE.sh WGBot_kingdom.sol WGBot_deployer.sol WGBot_Units.sol WarGameStorage.sol WarGameBase.sol WarGameWarrior.sol WarGameScout.sol
```

if you use TON DEV NET:

```
$ ./deploy_3debotsDEV.sh WGBot_kingdom.sol WGBot_deployer.sol WGBot_Units.sol WarGameStorage.sol WarGameBase.sol WarGameWarrior.sol WarGameScout.sol
```

You will see result like:
Done! Deployed storage with address: 0:xxx.  
Done! Deployed debot1 with address: 0:xxx.   
Done! Deployed debot2 with address: 0:xxx.   
Done! Deployed debot3 with address: 0:xxx.   

Debot1 address - is main debot address. 
Use it to run debot with surf in dev net or use tonos-cli in SE:

```
$tonos-cli --url http://127.0.0.1 debot fetch <debot1 address>

```
*http://127.0.0.1 - is default SE endpoint

In SE you will need a local wallet with seed and keys.

Or you can use default SE wallet:
- Public: 99c84f920c299b5d80e4fcce2d2054b05466ec9df19532a688c10eb6dd8d6b33
- Secret: 73b60dc6a5b1d30a56a81ea85e0e453f6957dbfbeefb57325ca9f7be96d3fe1a
- Seed Phrase: "fan harsh baby section father problem person void depth already powder chicken"



