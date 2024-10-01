// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fundraising {
    address public organization;
    address public receiver;
    uint public totalFunds;

    event DonationReceived(address indexed donor, uint amount);
    event FundsTransferred(address indexed receiver, uint amount);
    event ReceiverUpdated(address indexed oldReceiver, address indexed newReceiver);

    // Modifier to ensure only the organization can perform certain actions
    modifier onlyOrganization() {
        require(msg.sender == organization, "Only the organization can perform this action");
        _;
    }

    // Constructor to set the organization address (deployer of the contract)
    constructor() {
        organization = msg.sender; // Organization is the one who deploys the contract
    }

    // Function to allow users to donate Ether
    function donate() public payable {
        require(msg.value > 0, "Donation amount must be greater than zero");
        totalFunds += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    // Function to transfer all collected Ether to the receiver
    function transferFunds() public onlyOrganization {
        require(receiver != address(0), "Receiver address not set");
        require(totalFunds > 0, "No funds to transfer");
        uint amount = totalFunds;
        totalFunds = 0; // Reset total funds before transferring to prevent reentrancy
        payable(receiver).transfer(amount);
        emit FundsTransferred(receiver, amount);
    }

    // Function to set or update the receiver's address (only the organization can do this)
    function setReceiver(address _newReceiver) public onlyOrganization {
        require(_newReceiver != address(0), "Invalid receiver address");
        emit ReceiverUpdated(receiver, _newReceiver);
        receiver = _newReceiver;
    }

    // Fallback function to accept any Ether sent to the contract
    receive() external payable {
        donate();
    }
}
