# solidity-cryptozombies

## Internal and External

In addition to public and private, Solidity has two more types of visibility for functions: internal and external.

internal is the same as private, except that it's also accessible to contracts that inherit from this contract. (Hey, that sounds like what we want here!).

external is similar to public, except that these functions can ONLY be called outside the contract — they can't be called by other functions inside that contract. We'll talk about why you might want to use external vs public later.

<hr>

## Gas — the fuel Ethereum DApps run on

In Solidity, your users have to pay every time they execute a function on your DApp using a currency called gas. Users buy gas with Ether (the currency on Ethereum), so your users have to spend ETH in order to execute functions on your DApp.

How much gas is required to execute a function depends on how complex that function's logic is. Each individual operation has a gas cost based roughly on how much computing resources will be required to perform that operation (e.g. writing to storage is much more expensive than adding two integers). The total gas cost of your function is the sum of the gas costs of all its individual operations.

Because running functions costs real money for your users, code optimization is much more important in Ethereum than in other programming languages. If your code is sloppy, your users are going to have to pay a premium to execute your functions — and this could add up to millions of dollars in unnecessary fees across thousands of users.

## Why is gas necessary?

Ethereum is like a big, slow, but extremely secure computer. When you execute a function, every single node on the network needs to run that same function to verify its output — thousands of nodes verifying every function execution is what makes Ethereum decentralized, and its data immutable and censorship-resistant.

The creators of Ethereum wanted to make sure someone couldn't clog up the network with an infinite loop, or hog all the network resources with really intensive computations. So they made it so transactions aren't free, and users have to pay for computation time as well as storage.

<hr>

## View functions don't cost gas

view functions don't cost any gas when they're called externally by a user.

This is because view functions don't actually change anything on the blockchain – they only read the data. So marking a function with view tells web3.js that it only needs to query your local Ethereum node to run the function, and it doesn't actually have to create a transaction on the blockchain (which would need to be run on every single node, and cost gas).

We'll cover setting up web3.js with your own node later. But for now the big takeaway is that you can optimize your DApp's gas usage for your users by using read-only external view functions wherever possible.

Note: If a view function is called internally from another function in the same contract that is not a view function, it will still cost gas. This is because the other function creates a transaction on Ethereum, and will still need to be verified from every node. So view functions are only free when they're called externally.

<hr>

## MODIFIERS:

We have visibility modifiers that control when and where the function can be called from: private means it's only callable from other functions inside the contract; internal is like private but can also be called by contracts that inherit from this one; external can only be called outside the contract; and finally public can be called anywhere, both internally and externally.

We also have state modifiers, which tell us how the function interacts with the BlockChain: view tells us that by running the function, no data will be saved/changed. pure tells us that not only does the function not save any data to the blockchain, but it also doesn't read any data from the blockchain. Both of these don't cost any gas to call if they're called externally from outside the contract (but they do cost gas if called internally by another function).

Then we have custom modifiers, which we learned about in Lesson 3: onlyOwner and aboveLevel, for example. For these we can define custom logic to determine how they affect a function.

## The payable Modifier

payable functions are part of what makes Solidity and Ethereum so cool — they are a special type of function that can receive Ether.

Let that sink in for a minute. When you call an API function on a normal web server, you can't send US dollars along with your function call — nor can you send Bitcoin.

But in Ethereum, because both the money (Ether), the data (transaction payload), and the contract code itself all live on Ethereum, it's possible for you to call a function and pay money to the contract at the same time.

This allows for some really interesting logic, like requiring a certain payment to the contract in order to execute a function.

<hr>


## Random number generation via keccak256
The best source of randomness we have in Solidity is the keccak256 hash function.

We could do something like the following to generate a random number:

### Generate a random number between 1 and 100:
```uint randNonce = 0;
uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
randNonce++;
uint random2 = uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
```

What this would do is take the timestamp of now, the msg.sender, and an incrementing nonce (a number that is only ever used once, so we don't run the same hash function with the same input parameters twice).

It would then "pack" the inputs and use keccak to convert them to a random hash. Next, it would convert that hash to a uint, and then use % 100 to take only the last 2 digits. This will give us a totally random number between 0 and 99.

### This method is vulnerable to attack by a dishonest node
In Ethereum, when you call a function on a contract, you broadcast it to a node or nodes on the network as a transaction. The nodes on the network then collect a bunch of transactions, try to be the first to solve a computationally-intensive mathematical problem as a "Proof of Work", and then publish that group of transactions along with their Proof of Work (PoW) as a block to the rest of the network.

Once a node has solved the PoW, the other nodes stop trying to solve the PoW, verify that the other node's list of transactions are valid, and then accept the block and move on to trying to solve the next block.

This makes our random number function exploitable.

Let's say we had a coin flip contract — heads you double your money, tails you lose everything. Let's say it used the above random function to determine heads or tails. (random >= 50 is heads, random < 50 is tails).

If I were running a node, I could publish a transaction only to my own node and not share it. I could then run the coin flip function to see if I won — and if I lost, choose not to include that transaction in the next block I'm solving. I could keep doing this indefinitely until I finally won the coin flip and solved the next block, and profit.

### So how do we generate random numbers safely in Ethereum?
Because the entire contents of the blockchain are visible to all participants, this is a hard problem, and its solution is beyond the scope of this tutorial. You can read this [StackOverflow](https://ethereum.stackexchange.com/questions/191/how-can-i-securely-generate-a-random-number-in-my-smart-contract) thread for some ideas. One idea would be to use an oracle to access a random number function from outside of the Ethereum blockchain.

Of course, since tens of thousands of Ethereum nodes on the network are competing to solve the next block, my odds of solving the next block are extremely low. It would take me a lot of time or computing resources to exploit this profitably — but if the reward were high enough (like if I could bet $100,000,000 on the coin flip function), it would be worth it for me to attack.

So while this random number generation is NOT secure on Ethereum, in practice unless our random function has a lot of money on the line, the users of your game likely won't have enough resources to attack it.

Because we're just building a simple game for demo purposes in this tutorial and there's no real money on the line, we're going to accept the tradeoffs of using a random number generator that is simple to implement, knowing that it isn't totally secure.

Oracles : a secure way to pull data in from outside of Ethereum

<hr>

## Tokens on Ethereum
A token on Ethereum is basically just a smart contract that follows some common rules — namely it implements a standard set of functions that all other token contracts share, such as transferFrom(address _from, address _to, uint256 _tokenId) and balanceOf(address _owner).

Internally the smart contract usually has a mapping, mapping(address => uint256) balances, that keeps track of how much balance each address has.

So basically a token is just a contract that keeps track of who owns how much of that token, and some functions so those users can transfer their tokens to other addresses.

### Why does it matter?
Since all ERC20 tokens share the same set of functions with the same names, they can all be interacted with in the same ways.

This means if you build an application that is capable of interacting with one ERC20 token, it's also capable of interacting with any ERC20 token. That way more tokens can easily be added to your app in the future without needing to be custom coded. You could simply plug in the new token contract address, and boom, your app has another token it can use.

One example of this would be an exchange. When an exchange adds a new ERC20 token, really it just needs to add another smart contract it talks to. Users can tell that contract to send tokens to the exchange's wallet address, and the exchange can tell the contract to send the tokens back out to users when they request a withdraw.

The exchange only needs to implement this transfer logic once, then when it wants to add a new ERC20 token, it's simply a matter of adding the new contract address to its database.

### Other token standards
ERC20 tokens are really cool for tokens that act like currencies. But they're not particularly useful for representing zombies in our zombie game.

For one, zombies aren't divisible like currencies — I can send you 0.237 ETH, but transfering you 0.237 of a zombie doesn't really make sense.

Secondly, all zombies are not created equal. Your Level 2 zombie "Steve" is totally not equal to my Level 732 zombie "H4XF13LD MORRIS 💯💯😎💯💯". (Not even close, Steve).

There's another token standard that's a much better fit for crypto-collectibles like CryptoZombies — and they're called ERC721 tokens.

ERC721 tokens are not interchangeable since each one is assumed to be unique, and are not divisible. You can only trade them in whole units, and each one has a unique ID. So these are a perfect fit for making our zombies tradeable.

> Note that using a standard like ERC721 has the benefit that we don't have to implement the auction or escrow logic within our contract that determines how players can trade / sell our zombies. If we conform to the spec, someone else could build an exchange platform for crypto-tradable ERC721 assets, and our ERC721 zombies would be usable on that platform. So there are clear benefits to using a token standard instead of rolling your own trading logic.


```
contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
  function approve(address _approved, uint256 _tokenId) external payable;
}
```


<hr>

## Web3 Providers
Great! Now that we have Web3.js in our project, let's get it initialized and talking to the blockchain.

The first thing we need is a Web3 Provider.

Remember, Ethereum is made up of nodes that all share a copy of the same data. Setting a Web3 Provider in Web3.js tells our code which node we should be talking to handle our reads and writes. It's kind of like setting the URL of the remote web server for your API calls in a traditional web app.

You could host your own Ethereum node as a provider. However, there's a third-party service that makes your life easier so you don't need to maintain your own Ethereum node in order to provide a DApp for your users — Infura.

## Infura
Infura is a service that maintains a set of Ethereum nodes with a caching layer for fast reads, which you can access for free through their API. Using Infura as a provider, you can reliably send and receive messages to/from the Ethereum blockchain without needing to set up and maintain your own node.

You can set up Web3 to use Infura as your web3 provider as follows:

```javascript
var web3 = new Web3(new Web3.providers.WebsocketProvider("wss://mainnet.infura.io/ws"));
```

However, since our DApp is going to be used by many users — and these users are going to WRITE to the blockchain and not just read from it — we'll need a way for these users to sign transactions with their private key.

Note: Ethereum (and blockchains in general) use a public / private key pair to digitally sign transactions. Think of it like an extremely secure password for a digital signature. That way if I change some data on the blockchain, I can prove via my public key that I was the one who signed it — but since no one knows my private key, no one can forge a transaction for me.

Cryptography is complicated, so unless you're a security expert and you really know what you're doing, it's probably not a good idea to try to manage users' private keys yourself in our app's front-end.

But luckily you don't need to — there are already services that handle this for you. The most popular of these is Metamask.

## Metamask
Metamask is a browser extension for Chrome and Firefox that lets users securely manage their Ethereum accounts and private keys, and use these accounts to interact with websites that are using Web3.js. (If you haven't used it before, you'll definitely want to go and install it — then your browser is Web3 enabled, and you can now interact with any website that communicates with the Ethereum blockchain!).

And as a developer, if you want users to interact with your DApp through a website in their web browser (like we're doing with our CryptoZombies game), you'll definitely want to make it Metamask-compatible.

>Note: Metamask uses Infura's servers under the hood as a web3 provider, just like we did above — but it also gives the user the option to choose their own web3 provider. So by using Metamask's web3 provider, you're giving the user a choice, and it's one less thing you have to worry about in your app.

### Using Metamask's web3 provider
Metamask injects their web3 provider into the browser in the global JavaScript object web3. So your app can check to see if web3 exists, and if it does use web3.currentProvider as its provider.

Here's some template code provided by Metamask for how we can detect to see if the user has Metamask installed, and if not tell them they'll need to install it to use our app:

```javascript
window.addEventListener('load', function() {

  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    // Use Mist/MetaMask's provider
    web3js = new Web3(web3.currentProvider);
  } else {
    // Handle the case where the user doesn't have web3. Probably
    // show them a message telling them to install Metamask in
    // order to use our app.
  }

  // Now you can start your app & access web3js freely:
  startApp()

})
```

You can use this boilerplate code in all the apps you create in order to require users to have Metamask to use your DApp.

>Note: There are other private key management programs your users might be using besides MetaMask, such as the web browser Mist. However, they all implement a common pattern of injecting the variable web3, so the method we describe here for detecting the user's web3 provider will work for these as well.

<hr>

## Talking to Contracts
Now that we've initialized Web3.js with MetaMask's Web3 provider, let's set it up to talk to our smart contract.

Web3.js will need 2 things to talk to your contract: its address and its ABI.

### Contract Address
After you finish writing your smart contract, you will compile it and deploy it to Ethereum. We're going to cover deployment in the next lesson, but since that's quite a different process from writing code, we've decided to go out of order and cover Web3.js first.

After you deploy your contract, it gets a fixed address on Ethereum where it will live forever. If you recall from Lesson 2, the address of the CryptoKitties contract on Ethereum mainnet is 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d.

You'll need to copy this address after deploying in order to talk to your smart contract.

### Contract ABI
The other thing Web3.js will need to talk to your contract is its ABI.

ABI stands for Application Binary Interface. Basically it's a representation of your contracts' methods in JSON format that tells Web3.js how to format function calls in a way your contract will understand.

When you compile your contract to deploy to Ethereum (which we'll cover in Lesson 7), the Solidity compiler will give you the ABI, so you'll need to copy and save this in addition to the contract address.

### Instantiating a Web3.js Contract
Once you have your contract's address and ABI, you can instantiate it in Web3 as follows:

// Instantiate myContract
```javascript
var myContract = new web3js.eth.Contract(myABI, myContractAddress);
```

<hr>

## Calling Contract Functions
Our contract is all set up! Now we can use Web3.js to talk to it.

Web3.js has two methods we will use to call functions on our contract: call and send.

### Call
call is used for view and pure functions. It only runs on the local node, and won't create a transaction on the blockchain.

>Review: view and pure functions are read-only and don't change state on the blockchain. They also don't cost any gas, and the user won't be prompted to sign a transaction with MetaMask.

Using Web3.js, you would call a function named myMethod with the parameter 123 as follows:

myContract.methods.myMethod(123).call()
### Send
send will create a transaction and change data on the blockchain. You'll need to use send for any functions that aren't view or pure.

>Note: sending a transaction will require the user to pay gas, and will pop up their Metamask to prompt them to sign a transaction. When we use Metamask as our web3 provider, this all happens automatically when we call send(), and we don't need to do anything special in our code. Pretty cool!

Using Web3.js, you would send a transaction calling a function named myMethod with the parameter 123 as follows:

```myContract.methods.myMethod(123).send()```
The syntax is almost identical to call().

### Getting Zombie Data
Now let's look at a real example of using call to access data on our contract.

Recall that we made our array of zombies public:

```Zombie[] public zombies;```
In Solidity, when you declare a variable public, it automatically creates a public "getter" function with the same name. So if you wanted to look up the zombie with id 15, you would call it as if it were a function: zombies(15).

Here's how we would write a JavaScript function in our front-end that would take a zombie id, query our contract for that zombie, and return the result:

>Note: All the code examples we're using in this lesson are using version 1.0 of Web3.js, which uses promises instead of callbacks. Many other tutorials you'll see online are using an older version of Web3.js. The syntax changed a lot with version 1.0, so if you're copying code from other tutorials, make sure they're using the same version as you!

```javascript
function getZombieDetails(id) {
  return cryptoZombies.methods.zombies(id).call()
}
```

// Call the function and do something with the result:
```javascript
getZombieDetails(15)
.then(function(result) {
  console.log("Zombie 15: " + JSON.stringify(result));
});
```
Let's walk through what's happening here.

```cryptoZombies.methods.zombies(id).call()``` will communicate with the Web3 provider node and tell it to return the zombie with index id from Zombie[] public zombies on our contract.

Note that this is asynchronous, like an API call to an external server. So Web3 returns a promise here. (If you're not familiar with JavaScript promises... Time to do some additional homework before continuing!)

Once the promise resolves (which means we got an answer back from the web3 provider), our example code continues with the then statement, which logs result to the console.

result will be a javascript object that looks like this:
```JSON
{
  "name": "H4XF13LD MORRIS'S COOLER OLDER BROTHER",
  "dna": "1337133713371337",
  "level": "9999",
  "readyTime": "1522498671",
  "winCount": "999999999",
  "lossCount": "0" // Obviously.
}
```
We could then have some front-end logic to parse this object and display it in a meaningful way on the front-end.

<hr>

## Sending Transactions
using send functions to change data on our smart contract.

There are a few major differences from call functions:

- sending a transaction requires a from address of who's calling the function (which becomes msg.sender in your Solidity code). We'll want this to be the user of our DApp, so MetaMask will pop up to prompt them to sign the transaction.

- sending a transaction costs gas

- There will be a significant delay from when the user sends a transaction and when that transaction actually takes effect on the blockchain. This is because we have to wait for the transaction to be included in a block, and the block time for Ethereum is on average 15 seconds. If there are a lot of pending transactions on Ethereum or if the user sends too low of a gas price, our transaction may have to wait several blocks to get included, and this could take minutes.

### Example
#### Creating zombies
Let's look at an example with the first function in our contract a new user will call: createRandomZombie.

As a review, here is the Solidity code in our contract:

```javascript
function createRandomZombie(string _name) public {
  require(ownerZombieCount[msg.sender] == 0);
  uint randDna = _generateRandomDna(_name);
  randDna = randDna - randDna % 100;
  _createZombie(_name, randDna);
}
```
Here's an example of how we could call this function in Web3.js using MetaMask:

```javascript
function createRandomZombie(name) {
  // This is going to take a while, so update the UI to let the user know
  // the transaction has been sent
  $("#txStatus").text("Creating new zombie on the blockchain. This may take a while...");
  // Send the tx to our contract:
  return cryptoZombies.methods.createRandomZombie(name)
  .send({ from: userAccount })
  .on("receipt", function(receipt) {
    $("#txStatus").text("Successfully created " + name + "!");
    // Transaction was accepted into the blockchain, let's redraw the UI
    getZombiesByOwner(userAccount).then(displayZombies);
  })
  .on("error", function(error) {
    // Do something to alert the user their transaction has failed
    $("#txStatus").text(error);
  });
}
```
Our function sends a transaction to our Web3 provider, and chains some event listeners:

- receipt 
  - will fire when the transaction is included into a block on Ethereum, which means our zombie has been created and saved on our contract
- error 
  - will fire if there's an issue that prevented the transaction from being included in a block, such as the user not sending enough gas. We'll want to inform the user in our UI that the transaction didn't go through so they can try again.


>Note: You can optionally specify gas and gasPrice when you call send, e.g. .send({ from: userAccount, gas: 3000000 }). If you don't specify this, MetaMask will let the user choose these values.

<hr>

## Subscribing to Events
As you can see, interacting with your contract via Web3.js is pretty straightforward — once you have your environment set up, calling functions and sending transactions is not all that different from a normal web API.

There's one more aspect we want to cover — subscribing to events from your contract.

### Listening for New Zombies
If you recall from zombiefactory.sol, we had an event called NewZombie that we fired every time a new zombie was created:

```event NewZombie(uint zombieId, string name, uint dna);```
In Web3.js, you can subscribe to an event so your web3 provider triggers some logic in your code every time it fires:

```javascript
cryptoZombies.events.NewZombie()
.on("data", function(event) {
  let zombie = event.returnValues;
  // We can access this event's 3 return values on the `event.returnValues` object:
  console.log("A new zombie was born!", zombie.zombieId, zombie.name, zombie.dna);
}).on("error", console.error);
```

>Note that this would trigger an alert every time ANY zombie was created in our DApp — not just for the current user. What if we only wanted alerts for the current user?

### Using indexed
In order to filter events and only listen for changes related to the current user, our Solidity contract would have to use the indexed keyword, like we did in the Transfer event of our ERC721 implementation:

### event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
In this case, because _from and _to are indexed, that means we can filter for them in our event listener in our front end:

// Use `filter` to only fire this code when `_to` equals `userAccount`
```javascript
cryptoZombies.events.Transfer({ filter: { _to: userAccount } })
.on("data", function(event) {
  let data = event.returnValues;
  // The current user just received a zombie!
  // Do something here to update the UI to show it
}).on("error", console.error);
```
As you can see, using events and indexed fields can be quite a useful practice for listening to changes to your contract and reflecting them in your app's front-end.

### Querying past events
We can even query past events using getPastEvents, and use the filters fromBlock and toBlock to give Solidity a time range for the event logs ("block" in this case referring to the Ethereum block number):

```javascript
cryptoZombies.getPastEvents("NewZombie", { fromBlock: 0, toBlock: "latest" })
.then(function(events) {
  // `events` is an array of `event` objects that we can iterate, like we did above
  // This code will get us a list of every zombie that was ever created
});
```
Because you can use this method to query the event logs since the beginning of time, this presents an interesting use case: Using events as a cheaper form of storage.

If you recall, saving data to the blockchain is one of the most expensive operations in Solidity. But using events is much much cheaper in terms of gas.

The tradeoff here is that events are not readable from inside the smart contract itself. But it's an important use-case to keep in mind if you have some data you want to be historically recorded on the blockchain so you can read it from your app's front-end.

For example, we could use this as a historical record of zombie battles — we could create an event for every time one zombie attacks another and who won. The smart contract doesn't need this data to calculate any future outcomes, but it's useful data for users to be able to browse from the app's front-end.


<hr>

## Build Artifacts : (Testing Smart Contracts)
Every time you compile a smart contract, the Solidity compiler generates a JSON file (referred to as build artifacts) which contains the binary representation of that contract and saves it in the build/contracts folder.

Next, when you run a migration, Truffle updates this file with the information related to that network.

The first thing you'll need to do every time you start writing a new test suite is to load the build artifacts of the contract you want to interact with. This way, Truffle will know how to format our function calls in a way the contract will understand.

Let's look at a simple example.

Say there was a contract called myAwesomeContract. We could do something like the following to load the build artifacts:

```javascript
const myAwesomeContract = artifacts.require(“myAwesomeContract”);
```
The function returns something called a contract abstraction. In a nutshell, a contract abstraction hides the complexity of interacting with Ethereum and provides a convenient JavaScript interface to our Solidity smart contract. We'll be using it in the next chapters.

### The contract() function
Behind the scenes, Truffle adds a thin wrapper around Mocha in order to make testing simpler. Since our course focuses on Ethereum development, we won't be spending much time explaining the bits and bytes of Mocha. If you're inclined to learn more about Mocha, check out their website, once you're done with this lesson. For now, you only have to understand what we cover here - how to:

group tests by calling a function named contract(). It extends Mocha's describe() by providing a list of accounts for testing and doing some cleanup as well.

contract() takes two arguments. The first one, a string, must indicate what we’re going to test. The second parameter, a callback, is where we’re going to actually write our tests.

execute them: the way we’ll be doing this is by calling a function named it() which also takes two arguments: a string that describes what the test actually does and a callback.

Putting it together, here's a bare-bones test:

```javascript
 contract("MyAwesomeContract", (accounts) => {
   it("should be able to receive Ethers", () => {
   })
 })
 ```
>Note: A well-thought test explains what the code actually does. Make sure the description of the test suite and the test case can be read together as a coherent statement. It’s like you’re writing documentation.

### Usually, every test has the following phases:

- #### set up: in which we define the initial state and initialize the inputs.

- #### act: where we actually test the code. Always make sure you test only one thing.

- #### assert: where we check the results.

Lets look at what our test should do in some more detail.

### Set up
In Chapter 2, you learned to create a contract abstraction. However, a contract abstraction, as its name says, is just an abstraction. In order to actually interact with our smart contract, we have to create a JavaScript object that will act as an instance of the contract. Continuing our example with myAwesomeContract, we can use the contract abstraction to initialize our instance like this:

```Javascript
const contractInstance = await myAwesomeContract.new();
```


### The context function
To group tests, Truffle provides a function called context. Let me quickly show you how use it in order to better structure our code:

```javascript
context("with the single-step transfer scenario", async () => {
    it("should transfer a zombie", async () => {
      // TODO: Test the single-step transfer scenario.
    })
})

context("with the two-step transfer scenario", async () => {
    it("should approve and then transfer a zombie when the approved address calls transferFrom", async () => {
      // TODO: Test the two-step scenario.  The approved address calls transferFrom
    })
    it("should approve and then transfer a zombie when the owner calls transferFrom", async () => {
        // TODO: Test the two-step scenario.  The owner calls transferFrom
     })
})
```
If we add this to our CryptoZombies.js file and then run truffle test the output would look similar to this:

```Contract: CryptoZombies
    ✓ should be able to create a new zombie (100ms)
    ✓ should not allow two zombies (251ms)
    with the single-step transfer scenario
      ✓ should transfer a zombie
    with the two-step transfer scenario
      ✓ should approve and then transfer a zombie when the owner calls transferFrom
      ✓ should approve and then transfer a zombie when the approved address calls transferFrom


  5 passing (2s)
```
Well?

Hmm...

Take a look again - there's an issue with the above output. It looks like all tests have passed which is obviously false since we didn't even write them yet!!

Fortunately, there's an easy solution- if we just place an x in front of the context() functions as follows: xcontext(), Truffle will skip those tests.

>Note: x can be placed in front of an it() function as well. Don't forget to remove all the x's when the tests for those functions have been written!