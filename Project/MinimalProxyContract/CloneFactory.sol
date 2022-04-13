pragma solidity ^0.8;

// https://medium.com/coinmonks/diving-into-smart-contracts-minimal-proxy-eip-1167-3c4e7f1a41b8
interface Implementation {
    function initialize(address _owner) external;
}

contract CloneFactory {
    address public implementation; // the base contract (Implementation.sol)

    mapping(address => address[]) public allClones; // keep track of all deployments

    event NewClone(address _newClone, address _owner);

    constructor(address _implementation) {
        implementation = _implementation;
    }

    // original code: https://github.com/optionality/clone-factory/blob/master/contracts/CloneFactory.sol
    function createClone(address _implementation) internal returns (address instance) {
        // convert address to 20 bytes
        bytes20 implementationBytes = bytes20(_implementation);

        // actual code 
        // 3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3

        /* creation code 
        copy runtime code into memory and return it
        3d602d80600a3d3981f3 */

        /* runtime code 
        code to delegatecall to address
        363d3d373d3d3d363d73 address 5af43d82803e903d91602b57fd5bf3 */

        assembly {
            /* read 32 bytes of memory starting at pointer stored in 0x40
                In solidity, the 0x40 slot in memory is special: it contains the "free memory pointer"
                    which points to the end of currently allocated memory
            */
            let clone := mload(0x40)
            // store 32 bytes to memory starting at "clone"
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            /*
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      pointer
            */
            // store 32 bytes to memory starting at "clone" + 20 bytes
            // 0x14 = 20
            mstore(add(clone, 0x14), implementationBytes)

            /*
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              pointer
            */
            // store 32 bytes to memory starting at "clone" + 40 bytes
            // 0x28 = 40
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            
            /*
              |               20 bytes               |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            */
            // create new contract
            // send 0 Ether
            // code starts at pointer stored in "clone"
            // code size 0x37 (55 bytes)
            instance := create(0, clone, 0x37)
        }

        require(instance != address(0), "Create clone failed!");
    }

    // whoever call _clone will be the only one has access to change x in implementation.sol
    function _clone() external {
        address identicalChild = createClone(implementation);
        allClones[msg.sender].push(identicalChild);
        Implementation(identicalChild).initialize(msg.sender); 
        emit NewClone(identicalChild, msg.sender);
    }

    function returnClones(address _owner) external view returns (address[] memory) {
        return allClones[_owner];
    }
}