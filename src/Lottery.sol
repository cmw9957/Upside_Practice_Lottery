// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

contract Lottery {

    mapping(address => uint) lotteryList;
    mapping(address => bool) buyList;
    mapping(uint16 => uint) lotteryCount;

    uint public vault_balance;

    uint public startTime;

    bool isDraw = false;

    uint16 winNum;
    uint winnings = 0;

    constructor () {
        startTime = block.timestamp;
    }

    function buy(uint16 lotteryNum) payable external {
        require(block.timestamp < startTime + 24 hours, "Too late to buy.");
        require(msg.value == 0.1 ether, "Insufficient funds.");
        require(buyList[msg.sender] != true, "Already exists.");

        vault_balance += msg.value;
        lotteryList[msg.sender] = lotteryNum;
        lotteryCount[lotteryNum] += 1;
        buyList[msg.sender] = true;
    }

    function draw() external {
        require(block.timestamp >= startTime + 24 hours, "Too fast to draw.");
        winNum = winningNumber();

        uint count = lotteryCount[winNum];
        if (count != 0) {
            winnings = vault_balance / count;
        }
        isDraw = true;
    }
    
    function claim() external {
        require(block.timestamp >= startTime + 24 hours, "Too fast to claim.");
        require(isDraw == true, "Draw must be conducted first.");

        address recipient = msg.sender;
        (bool success, ) = payable(recipient).call{value: winnings}("");
        require(success, "Transfer failed.");
        
        vault_balance -= winnings;
    }


    function winningNumber() public returns (uint16){
        uint256 randomHash = uint256(
            keccak256(
                abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
            )
        );
        return uint16(randomHash % 65536);
    }
}