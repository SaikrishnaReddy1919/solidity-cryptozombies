pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;


    // private funtion : can be called only from this contract.
    function _createZombie(string memory _name, uint _dna) private {
        zombies.push(Zombie(_name, _dna));
    }


    // chapter : 10
    // Create a private function called _generateRandomDna. It will take one parameter named _str (a string), and return a uint. Don't forget to set the data location of the _str parameter to memory.
    // This function will view some of our contract's variables but not modify them, so mark it as view.
    // The function body should be empty at this point — we'll fill it in later.
    function _generateRandomDna(string memory _str) private view returns (uint) {

        // The first line of code should take the keccak256 hash of abi.encodePacked(_str) to
        // generate a pseudo-random hexadecimal, typecast it as a uint, and finally store
        // the result in a uint called rand.
        // We want our DNA to only be 16 digits long (remember our dnaModulus?).
        // So the second line of code should return the above value modulus (%) dnaModulus.

        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

}
