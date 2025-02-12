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
    function buy(uint lotteryNum) payable external {
        
    }

    function draw() external {

    }
    
    function claim() external {

    }

    function winningNumber() external returns (uint16){
        return 0;
    }
}