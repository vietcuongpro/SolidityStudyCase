//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract LazyWithdrawToken is ERC20, EIP712, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    string private constant SIGNING_DOMAIN = "LazyWithdraw-Voucher";
    string private constant SIGNATURE_VERSION = "1";

    constructor(address payable minter)
        ERC20("Lazy Withdraw Token", "LWT") 
        EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
            _setupRole(MINTER_ROLE, minter);
        }  
    
    /// @notice Represent un-minted Token, not yet recorded in blockchain. To get token, using redeem function 
    struct Voucher {
        /// @notice amount of token to redeem
        uint256 amount;
        address recipient;
        bytes signature;
    }

    function redeem(Voucher calldata voucher) public returns (bool) {
        require(msg.sender == voucher.recipient, "You are not the recipient!");

        // Get address of signer
        address signer = _verify(voucher);
        
        require(hasRole(MINTER_ROLE, signer), "Signature invalid or unauthorized!");

        _mint(signer, voucher.amount);
        _transfer(signer, msg.sender, voucher.amount);

        return true;
    }

    /// @notice Verifies the signature for a given voucher, returning the address of the signer.
    /// @dev Will revert if the signature is invalid. Does not verify that the signer is authorized to mint token.
    function _verify(Voucher calldata voucher) internal view returns (address) {
        bytes32 digest = _hash(voucher);
        return ECDSA.recover(digest, voucher.signature);
    }

    /// @notice Returns a hash of the given Voucher, prepared using EIP712 typed data hashing rules.
    function _hash(Voucher calldata voucher) internal view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Voucher(uint256 amount,address recipient)"),
            voucher.amount,
            voucher.recipient
        )));
    }
}
