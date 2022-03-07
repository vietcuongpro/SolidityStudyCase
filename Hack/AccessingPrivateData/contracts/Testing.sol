//SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

/*
    - Storage has 2^256 slot, each slot 32 bytes
    - Data is stored sequentially in declaration order
    - Storage is optimized to save space. If neighboring variables fit a single 32 bytes,
        they are packed into same slot, starting from the right
*/

contract Testing {
    // slot 0
    uint public count = 123; // 32 bytes
    // slot 1
    address public owner = msg.sender;  // 20 bytes
    bool public isTrue = true;  // 1 byte
    uint16 public u16 = 31;     // 2 bytes
    // slot 2
    bytes32 private password;   // 32 bytes

    // constants do not use storage
    uint public constant someConst = 123;

    // slot 3, 4, 5 (one for each array element)
    bytes32[3] public data;

    struct User {
        uint id;
        bytes32 password;
    }

    // slot 6 store length of array
    // array elements store at: slot keccak256(6) + (index * elementSize)
    // In this case, elementSize = 2 (1 uint + 1 bytes32)
    User[] private users;

    // slot 7 - empty
    // entries are stored in hash(key, slot) where slot = 7, key = map key
    mapping(uint => User) private idToUser;

    constructor(bytes32 _password) {
        password = _password;
    }

    function addUser(bytes32 _password) public {
        User memory user = User({id: users.length, password: _password});

        users.push(user);
        idToUser[user.id] = user;
    }

    function getArrayLocation(uint slot, uint index, uint elementSize) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(slot))) + (index * elementSize);
    }

    function getMapLocation(uint key, uint slot) public pure returns (uint) {
        return uint(keccak256(abi.encodePacked(key, slot)));
    }
}
