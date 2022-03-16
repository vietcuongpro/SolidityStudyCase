// SPDX-Unlicense-Identifier: MIT
pragma solidity ^0.8;

//import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract simulateWithdrawToken {
    event Approval(address from, address to, bool approved);

    mapping(uint => mapping(address => uint)) private _balance;
    mapping(uint => address) private _tokenApproval;
    mapping(address => mapping(address => bool)) private _isApproval;
    mapping(uint => mapping (address => bool)) private _isPending;

    function setApproval(address receiver, bool approved) public {
        _isApproval[msg.sender][receiver] = approved;
        emit Approval(msg.sender, receiver, approved);
    }

    function isContract(address addr) internal returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function pendingRequest(address wallet, uint tokenId) public {
        require(!isContract(wallet), "Must be a valid account address, not contract!");
        require(_balance[tokenId][msg.sender] > 0, "User does not own any token");
        require(_isApproval[msg.sender][wallet], "Wallet is not approved!");
        require(wallet != address(0), "Withdraw to address(0)!");
        require(!_isPending[tokenId][msg.sender], "Token is already pending!");
        
        _isPending[tokenId][msg.sender] = true;
    }

    function claimRequest(address wallet, uint tokenId) public {
        require(_isPending[tokenId][msg.sender], "Token is not pending to be claimed!");

        _balance[tokenId][msg.sender] -= 1;
        _balance[tokenId][wallet] += 1;
        _isPending[tokenId][msg.sender] = false;
    }
}