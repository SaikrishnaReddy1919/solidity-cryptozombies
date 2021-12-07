pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {

    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    // To store zombie ownership, we're going to use two mappings:
    // one that keeps track of the address that owns a zombie, and another
    // that keeps track of how many zombies an owner has.

    // Create a mapping called zombieToOwner. The key will be a uint
    // (we'll store and look up the zombie based on its id) and the value an address.
    // Let's make this mapping public.

    // Create a mapping called ownerZombieCount, where the key is an address and the value a uint.

    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;


    // private funtion : can be called only from this contract.
    function _createZombie(string memory _name, uint _dna) private {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;

        // Declare an event called NewZombie. It should pass zombieId (a uint), name (a string), and dna (a uint).

        // Modify the _createZombie function to fire the NewZombie event after adding the new Zombie to our zombies array.

        // You're going to need the zombie's id. array.push() returns a uint of the new length of the array -
        // and since the first item in an array has index 0, array.push() - 1
        // will be the index of the zombie we just added. Store the result of zombies.push() - 1 in a uint called id,
        // so you can use this in the NewZombie event in the next line.

        emit NewZombie(id, _name, _dna);
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


    // Create a public function named createRandomZombie. It will take one parameter named
    // _name (a string with the data location set to memory).
    // (Note: Declare this function public just as you declared previous functions private)

    // The first line of the function should run the _generateRandomDna function on _name,
    // and store it in a uint named randDna.

    // The second line should run the _createZombie function and pass it _name and randDna.
    function createRandomZombie(string memory _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }


}
