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

    modifier isTimeToBuy() {
        require(block.timestamp < startTime + 24 hours, "Too late to buy.");
        _;
    }

    modifier isTimeToDraw() {
        require(block.timestamp >= startTime + 24 hours, "Too fast to draw.");
        _;
    }

    modifier isSufficientFunds() {
        require(msg.value == 0.1 ether, "Insufficient funds.");
        _;
    }

    modifier checkUserAlreadyBuy() {
        require(!buyList[msg.sender], "Already exists.");
        _;
    }

    modifier isDrawed() {
        require(!isDraw, "Already drawed.");
        _;
    }

    modifier isNotDrawed() {
        require(isDraw, "Draw must be conducted first.");
        _;
    }

    modifier checkTicket() {
        require(buyList[msg.sender], "No ticket found.");
        _;
    }

    constructor() {
        startTime = block.timestamp;
    }

    function buy(uint16 lotteryNum) external payable isTimeToBuy() isSufficientFunds() checkUserAlreadyBuy() {
        vault_balance += msg.value;
        lotteryList[msg.sender] = lotteryNum;
        lotteryCount[lotteryNum] += 1;
        buyList[msg.sender] = true;
    }

    function draw() external isTimeToDraw() isDrawed() {
        winNum = winningNumber();
        uint count = lotteryCount[winNum];

        if (count > 0) { // preventation divide by zero
            winnings = vault_balance / count;
        }

        isDraw = true;
    }

    function claim() external isNotDrawed() checkTicket() {
        uint16 userNum = lotteryList[msg.sender];

        if (userNum == winNum) {
            vault_balance -= winnings;
            (bool success, ) = payable(msg.sender).call{value: winnings}("");
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

    function winningNumber() public view returns (uint16) {
        return uint16(
            uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, block.prevrandao, msg.sender)
                )
            ) % 65536
        );
    }
}
