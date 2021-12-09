pragma solidity >=0.5.0 <0.6.0;

import "./zombiefeeding.sol";

contract ZombieHelper is ZombieFeeding {

    uint levelUpFee = 0.001 ether;

  modifier aboveLevel(uint _level, uint _zombieId){
    require(zombies[_zombieId].level >= _level);
    _;
  }

  function levelUp(uint _zombieId) external payable{
    require(msg.value == levelUpFee, "Ether must be 0.001");
    zombies[_zombieId].level++;
  }

  function withdraw() external onlyOwner{
    address payable _owner = address(uint160(owner()));
    _owner.transfer(address(this).balance);
  }

  // if eth value goes up to some high value in future, if we have a way to
  // to set up level up fee value than game is not expensive, otherwise game is more expensive.
  function setLevelUpFee(uint _fee) external onlyOwner{
    levelUpFee = _fee;
  }

   function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) {
    require(msg.sender == zombieToOwner[_zombieId], "requires Owner");
    zombies[_zombieId].name = _newName;
  }

  function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId){
    require(msg.sender == zombieToOwner[_zombieId], "requires Owner");
    zombies[_zombieId].dna = _newDna;
  }

  function getZombiesByOwner(address _owner) external view returns(uint[] memory){
      uint[] memory result = new uint[](ownerZombieCount[_owner]);
      uint counter = 0;
      for(uint i = 0; i<zombies.length; i++){
        if(zombieToOwner[i] == _owner){
            result[counter] = i;
            counter++;
        }
      }
      return result;
  }

}
