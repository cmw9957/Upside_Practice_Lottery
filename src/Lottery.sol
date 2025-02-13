// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery {
    mapping(address => uint16) private lotteryList;
    mapping(address => bool) private buyList;
    mapping(uint16 => uint) private lotteryCount;

    uint public vault_balance;
    uint public startTime;
    bool public isDraw = false;

    uint16 private winNum;
    uint private winnings = 0;

    constructor() {
        startTime = block.timestamp;
    }

    function buy(uint16 lotteryNum) external payable {
        require(block.timestamp < startTime + 24 hours, "Too late to buy.");
        require(msg.value == 0.1 ether, "Insufficient funds.");
        require(!buyList[msg.sender], "Already exists.");

        vault_balance += msg.value;
        lotteryList[msg.sender] = lotteryNum;
        lotteryCount[lotteryNum] += 1;
        buyList[msg.sender] = true;
    }

    function draw() external {
        require(block.timestamp >= startTime + 24 hours, "Too fast to draw.");
        require(!isDraw, "Already draw.");

        winNum = winningNumber();
        uint count = lotteryCount[winNum];

        if (count > 0) {
            winnings = vault_balance / count;
        }

        isDraw = true;
    }

    function claim() external {
        require(isDraw, "Draw must be conducted first.");
        require(buyList[msg.sender], "No ticket found.");

        uint16 userNum = lotteryList[msg.sender];

        if (userNum == winNum) {
            uint winningAmount = winnings;
            vault_balance -= winningAmount;

            (bool success, ) = payable(msg.sender).call{value: winningAmount}("");
            require(success, "Transfer failed.");
        }

        // 사용자 정보 초기화
        buyList[msg.sender] = false;
        lotteryCount[userNum] -= 1;

        // 모든 당첨자가 돈을 수령하면 자동으로 새 라운드 시작
        if (vault_balance == 0 || lotteryCount[winNum] == 0) {
            isDraw = false;
            startTime = block.timestamp;
            lotteryCount[winNum] = 0;
        }
    }

    function winningNumber() public returns (uint16) {
        return uint16(
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
                )
            ) % 65536
        );
    }
}
