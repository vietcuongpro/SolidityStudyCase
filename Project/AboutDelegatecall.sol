/*
    What is delegatecall
        - a low level function similar to call
        - when contract A delegatecall contract B, 
            it runs B's code inside A's context (storage, msg.sender, msg.value)
                -> storage of contract A
                -> msg.sender & msg.value which call to contract A
        - Can upgrade contract A without changing any code inside it

    Remember to have same order of state variable of both contract
        in order for delegatecall to work
        => must not overlap storage layout, meaning can add change, but don't overlap

A calls B, sends 100 wei
        B calls C, send 50 wei

A ---> B ---> C
              msg.sender = B
              msg.value = 50
              execute code on C's state variables
              use ETH in C

A calls B, sends 100 wei
        B deletegatecall C
A ---> B ---> C
              msg.sender = A
              msg.value = 100
              execute code on B's state value
              use ETH in B

We demonstrate the above, the num & sender & value in B's will be change
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract C {
    uint public num;
    address public sender;
    uint public value;

    event Receive(address caller, uint amount, string message);

    function setVars(uint _num, string memory _st) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;

        emit Receive(msg.sender, msg.value, "C.setVars is called!");
    }
}

contract B {
    uint public num;
    address public sender;
    uint public value;

    event Receive(address caller, uint amount, string message);

    fallback() external payable {   // in case other contract call non-exist function
        emit Receive(msg.sender, msg.value, "fallback is called!");
    }

    function setVars(address _contractC, uint _num, string memory _st) public payable {
        // 2 way to call using deletegatecall, by using 'encodeWithSignature' or 'encodeWithSelector'
        /*(bool sent, bytes memory data) = _B.delegatecall(
            abi.encodeWithSignature("setVars(uint256,string)", _num, _st) 
            //no space between args; must be uint256 not uint
        );*/
        (bool success, bytes memory data) = _contractC.delegatecall(
            abi.encodeWithSelector(C.setVars.selector, _num, _st)
        );

        emit Receive(msg.sender, msg.value, "B's setVars is called!");
    }
}

contract A {
    function setVars(address _contractB, address _contractC, uint _num, string memory _st) public payable {
        (bool sent, bytes memory data) = _contractB.call{value: msg.value}(
            abi.encodeWithSignature("setVars(address,uint256,string)", _contractC, _num, _st) 
            //no space between args; must be uint256 not uint
        );
    }
}