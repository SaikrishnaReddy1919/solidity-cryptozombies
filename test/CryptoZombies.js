const CryptoZombies = artifacts.require("CryptoZombies");
const zombieNames = ["Zombie 1", "Zombie 2"];
contract("CryptoZombies", (accounts) => {
  let [alice, bob] = accounts;

  let contractInstance;

  //   this function will run before each test gets executed
  beforeEach(async () => {
    contractInstance = await CryptoZombies.new();
  });
  it("should be able to create a new zombie", async () => {
    const contractInstance = await CryptoZombies.new();
    // this will create a zombie by talking to the blockchain
    const result = await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
    assert.equal(result.receipt.status, true);
    assert.equal(result.logs[0].args.name, zombieNames[0]);
  });

  it("should not allow two zombies", async () => {
    await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
    await utils.shouldThrow(contractInstance.createRandomZombie(zombieNames[1], { from: alice }));
  });
});
