// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

interface ILottery {
    function buy(uint lotteryNum) payable external;
    function draw() external;
    function claim() external;
    function winningNumber() external returns (uint16);
}

contract Lottery is ILottery {

    mapping(address => uint) lotteryList;
    uint public vault_balance;

    function buy(uint lotteryNum) payable external {
        require(block.timestamp < block.timestamp + 24, "Too late to buy.");
        require(msg.value == 0.1 ether, "Insufficient funds.");
        require(lotteryList[msg.sender] != lotteryNum, "Already exists.");

        vault_balance += msg.value;
        lotteryList[msg.sender] = lotteryNum;
    }

    function draw() external {
        
    }
    
    function claim() external {

    }

    function winningNumber() external returns (uint16){
        return 0;
    }
}