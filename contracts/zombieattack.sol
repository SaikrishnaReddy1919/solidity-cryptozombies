pragma solidity >=0.5.0 <0.6.0;

import "./zombiehelper.sol";

contract ZombieAttack is ZombieHelper {

  uint randNonce = 0;
  uint attackVictoryProbability = 70;

  function randMod(uint _modulus) internal returns(uint){
    randNonce++;
    return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce)))% _modulus;
  }

    /*
    * You choose one of your zombies, and choose an opponent's zombie to attack.
    * If you're the attacking zombie, you will have a 70% chance of winning.
        The defending zombie will have a 30% chance of winning.
    * All zombies (attacking and defending) will have a winCount and a lossCount that will increment
        depending on the outcome of the battle.
    * If the attacking zombie wins, it levels up and spawns a new zombie.
    * If it loses, nothing happens (except its lossCount incrementing).
    * Whether it wins or loses, the attacking zombie's cooldown time will be triggered.
    */
    function attack(uint _zombieId, uint _targetId) external ownerOf(_zombieId){
        // 2. Start function definition here
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];

        uint rand = randMod(100);

        if(rand <= attackVictoryProbability) {
            myZombie.winCount++;
            myZombie.level++;

            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        }
    }
}
