/*
    This contract show how to precompute a contract address before deploy (using 'create2' func)
    - 'create' vs 'create2'
        'create' - depends on deployer's nonce
        'create2' - depends on the salt you can set

    - This code show 2 ways of using deploy function, both apply 'create2' principle
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract SomeContract {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }
}

contract Create2Factory {
    event Deploy(address addr);

    /* 
        After deployment, check logs to see address of event Deploy(addr)
        It should be equal to result of 'getAddress' function
    */
    function deploy_way1(uint _salt) external {
        // Deploy with create2
        SomeContract _contract = new SomeContract{salt: bytes32(_salt)}(msg.sender);
        emit Deploy(address(_contract));
    }

    function deploy_way2(bytes memory bytecode, uint _salt) public payable {
        address addr;

        /* 
            create2(v, p, n, s): create new contract with code at memory p to p+n
                and send v wei
                and return new address 
                where new address = first 20 bytes of keccak256(0xff + address(this) + salt + keccak256(mem[p (p+1) ... (p+n)])
        */
        assembly {
            addr := create2(
                callvalue(),    // wei sent with current call
                add(bytecode, 0x20),    // actual code starts after skipping first 32 (=0x20) bytes, coz 1st 32 bytes store size of bytecode
                mload(bytecode), // load size of code contained in 1st 32 bytes
                _salt
            )

            // make sure contract is deployed, checking size of it, if 0 revert
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }

        emit Deploy(addr);
    }
    
    // Compute pre-deployed address of the contract
    // salt is a random number set by you to create an address
    function getAddress(bytes memory bytecode, uint _salt) public view returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff), address(this), _salt, keccak256(bytecode)
            )
        );

        // get last 20 bytes of hash to address
        return address(uint160(uint(hash)));
    }

    // get bytecode of the contract to be deployed
    function getBytecode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(SomeContract).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
        // if contract has multiple args, then we need to pass those args into abi.encode(args0, args1,...) as well
    }
}