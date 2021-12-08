pragma solidity >=0.5.0 <0.6.0;
import "./zombieFactory.sol";

contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
    bool isGestating,
    bool isReady,
    uint256 cooldownIndex,
    uint256 nextActionAt,
    uint256 siringWithId,
    uint256 birthTime,
    uint256 matronId,
    uint256 sireId,
    uint256 generation,
    uint256 genes
);
}

contract ZombieFeeding is ZombieFactory {

    KittyInterface kittyContract;

    // instead of hardcoding contract address, below is an option to set c_address. so
    // that even if something goes wrong other contract, we can update it to new one.

    // onlyOwner : the person who deployed first can call this contract.
    function setKittyContractAddress(address _address) external onlyOwner {
      kittyContract = KittyInterface(_address);
    }

    // When a zombie feeds on some other lifeform, its DNA will combine
    // with the other lifeform's DNA to create a new zombie.
    function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public view {
      require(msg.sender == zombieToOwner[_zombieId], "Sender must to equal to owner of this zombie");
      Zombie storage myZombie = zombies[_zombieId];


    // First we need to make sure that _targetDna isn't longer than 16 digits.
    // To do this, we can set _targetDna equal to _targetDna % dnaModulus to only take the last 16 digits.
      uint newTargetDna = _targetDna % dnaModulus;
      uint newDna = (myZombie.dna + newTargetDna) / 2;

      if(keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))){
        newDna = newDna - newDna % 100 + 99;
      }
      _createZombie("NoName",newDna);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public view {
      uint kittyDna;
      (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
      feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}