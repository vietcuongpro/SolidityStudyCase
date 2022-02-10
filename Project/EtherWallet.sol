pragma solidity ^0.8.0;

contract EtherWallet {
    address payable public owner;

    constructor() {
        owner = payable(msg.sender);
    }

    receive() external payable {}

    function withdraw(uint amount) external {
        require(owner == msg.sender, "Error: Not owner");
        payable(msg.sender).transfer(amount);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}