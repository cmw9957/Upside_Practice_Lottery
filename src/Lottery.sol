// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";

// interface ILottery {
//     function buy(uint lotteryNum) payable external;
//     function draw() external;
//     function claim() external;
//     function winningNumber() public returns (uint16);
// }

contract Lottery {

    mapping(address => uint) lotteryList;
    mapping(address => bool) buyList;
    
    uint public vault_balance;

    function buy(uint lotteryNum) payable external {
        require(block.timestamp < block.timestamp + 24, "Too late to buy.");
        require(msg.value == 0.1 ether, "Insufficient funds.");
        require(buyList[msg.sender] != true, "Already exists.");

        vault_balance += msg.value;
        lotteryList[msg.sender] = lotteryNum;
        buyList[msg.sender] = true;
    }

    function draw() external {

    }
    
    function claim() external {

    }

    function winningNumber() public returns (uint16){
        return 0;
    }
}