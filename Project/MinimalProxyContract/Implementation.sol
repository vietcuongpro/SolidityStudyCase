pragma solidity ^0.8;

/*
    Look carefully at function initialize(), by designing like that
        1. The function is getting called ONLY ONCE <- by checking owner is address(0)
        
        2. Make implementation contract unusale, make it only purpose is to serve as logic contract
            -> by assigning isBase=true in constructor and require it =false in initialize()
                -> if someome tries to call initialize function of base contract, it revert

*/

contract Implementation {
    uint public x;
    bool public isBase;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "ERROR: Only Owner");
        _;
    }

    constructor() {
        // This ensures the base contract cannot be initialized
        isBase = true;
    }

    function initialize(address _owner) external {
        // For base contract, isBase == true. Impossible to use
        require(isBase == false, "ERROR: This is the base contract, cannot initialize!");
        // Owner address defaults to address (0). 
        // Once this function is called to set owner, no way to call it again
        require(owner == address(0), "ERROR: Contract already initialized!");
        owner = _owner;
    }

    function setX(uint _newX) external onlyOwner {
        x = _newX;
    }
}