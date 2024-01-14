## Token Swap Smart Contract

A solidity smart contract to facilitate swapping of one ERC-20 token for another at a 
predefined exchange rate. The contract consists of the following features:
- Users can swap Token A for Token B and vice versa.
- The exchange rate between Token A and Token B is fixed.
- The swap will always adhere to the exchange rate.


### About the Contract
Both the tokens follow ERC20 standard and have differnet owners. <br />
#### How does the Swap take place ?
Now, the first requirement of the swap is that the owner should have set an exchange rate for TokenA to TokenB transfer.<br>
Next condition is that both the users involved in the swap should actually have the token balance (including exchange rate) they wish to swap. <br>
So for a fair swap, we need to make sure that no user can backout once he has received the token from the other party. To make sure of this, our TokenSale contract acts as a mediator. Both the users need to approve our TokenSale contract to swap their respective contracts. If either of the user has not provided the required allowance (including exchange rate) to the TokenSale contract, the swap will be reverted. This won't be done in the TokenSwap contract and needs to be done manually. We have done this in our tests. <br>

Let's take an example:
Say we have 2 users - userA and userB. userA has TokenA worth 100 ETH and userB has TokenB worth 100 ETH and both don't have the other token at all i.e. 0 ETH.
The exchange rate from TokenAtoB is 2x. How much amount will both users have once they have met all conditions and carried out the swap correctly? <br> So lets assume user1 wants to trade TokenA worth 20 ETH from his side. Now as per the exchange, he will in exchange get TokenB worth 2*20 ETH = 40ETH. And similarly, userB will get 1/2 * 20ETH i.e.10ETH worth TokenA. <br>
This is same example we have used in one of our tests with the following results : 

    ////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    //
    // -------------------BALANCE IN ETH---------------------
    // TokenA Balance ---------------------------------------
    // User 1 :  100
    // User 2 :  0
    // TokenB Balance --------------------------------------
    // User 1 :  0
    // User 2 :  100
    // -------------------EXCHANGE RATE : 2-----------------
    // ---------------------AFTER SWAP----------------------
    // TokenA Balance --------------------------------------
    // User 1 :  60
    // User 2 :  40
    // TokenB Balance -------------------------------------
    // User 1 :  10
    // User 2 :  90
    //
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////



Check the test/ folder for more details.
The contract is tested using the *Foundry Framework*.


## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/DeployTokenSwap.s.sol --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
