/*
    Demo a way of a contract A call another contract B's function
    'call': a low level function to interact with other contracts
        -> recommend way to sending Ether via calling 'fallback' function
        but not recommend to call existing function
            ('fallback' function: take no args, not return anything,
            executed either a function-not-exist is called or 
            Ether is sent directly to contract but 'receive()' not exist or msg.data not empty)
        

*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract B {
    event Receive(address caller, uint amount, string message);

    fallback() external payable {
        emit Receive(msg.sender, msg.value, "fallback is called!");
    }

    function someFunc(string memory _message, uint _x) public payable returns (uint) {
        emit Receive(msg.sender, msg.value, _message);

        return _x * 2;
    }
}

contract A {
    event Response(bool success, bytes data);

    function callExistFunc(address payable _addr) public payable {
        // can specify ether & custom gas amount
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas: 4306}(
            abi.encodeWithSignature("someFunc(string,uint256)", "Limbo!", 666)
        );
        require(success, "transaction failed!");
        emit Response(success, data);
    }

    function callNotExistFunc(address payable _addr) public payable {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("funcNotExist()")
        );
        require(success, "transaction failed!");
        emit Response(success, data);
    }
}