pragma solidity >=0.5.0 <0.6.0;
import "./zombieFactory.sol";

contract ZombieFeeding is ZombieFactory {

    // When a zombie feeds on some other lifeform, its DNA will combine
    // with the other lifeform's DNA to create a new zombie.
    function feedAndMultiply(uint _zombieId, uint _targetDna) public view {
      require(msg.sender == zombieToOwner[_zombieId], "Sender must to equal to owner of this zombie");
      Zombie storage myZombie = zombies[_zombieId];


    // First we need to make sure that _targetDna isn't longer than 16 digits.
    // To do this, we can set _targetDna equal to _targetDna % dnaModulus to only take the last 16 digits.
      uint newTargetDna = _targetDna % dnaModulus;
      uint newDna = (myZombie.dna + newTargetDna) / 2;
      _createZombie("NoName",newDna);
  }
}