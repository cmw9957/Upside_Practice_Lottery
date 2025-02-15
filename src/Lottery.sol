// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Lottery {
    mapping(address => uint16) private lotteryList; // 사용자별 구매한 lottery 번호를 매핑
    mapping(address => bool) private hasPurchased; // 사용자 구매 여부를 저장
    mapping(uint16 => uint) private lotteryNumCount; // 각 lottery 번호별 개수 저장

    uint public vault_balance; // 총 구입 금액
    uint public startTime; // buy, draw 함수를 위한 시간 관련 변수
    bool public isDraw = false; // draw 함수 실행 여부
    uint16 private winNum; // 당첨 숫자
    uint private winnings = 0; // 각 당첨자가 수령할 금액

    // timestamp가 startTieme 기준으로 24시간 미만인지 확인
    modifier isTimeToBuy() {
        require(block.timestamp < startTime + 24 hours, "Too late to buy.");
        _;
    }

    // timestamp가 startTieme 기준으로 24시간 이상인지 확인
    modifier isTimeToDraw() {
        require(block.timestamp >= startTime + 24 hours, "Too fast to draw.");
        _;
    }

    // msg.value가 0.1 ether인지 확인
    modifier isSufficientFunds() {
        require(msg.value == 0.1 ether, "Insufficient funds.");
        _;
    }

    // 사용자가 lottery를 구매했는지 확인
    modifier isBuy() {
        require(hasPurchased[msg.sender], "No ticket found.");
        _;
    }

    // 사용자가 lottery를 구매 안했는지 확인
    modifier isNotBuy() {
        require(!hasPurchased[msg.sender], "Already exists.");
        _;
    }

    // draw 함수가 이전에 실행됐는지 확인
    modifier isDrawed() {
        require(isDraw, "Draw must be conducted first.");
        _;
    }

    // draw 함수가 이전에 실행됐는지 확인
    modifier isNotDrawed() {
        require(!isDraw, "Already drawed.");
        _;
    }

    // buy, draw를 위한 초기 시간 설정
    constructor() {
        startTime = block.timestamp;
    }

    // lotteryNum에 대한 구매 함수
    function buy(uint16 lotteryNum) external payable isTimeToBuy() isSufficientFunds() isNotBuy() {
        vault_balance += msg.value;
        lotteryList[msg.sender] = lotteryNum;
        lotteryNumCount[lotteryNum] += 1;
        hasPurchased[msg.sender] = true;
    }

    function draw() external isTimeToDraw() isNotDrawed() {
        winNum = winningNumber();
        uint count = lotteryNumCount[winNum];

        if (count > 0) { // preventation divide by zero
            winnings = vault_balance / count;
        }

        isDraw = true;
    }

    function claim() external isDrawed() isBuy() {
        uint16 userNum = lotteryList[msg.sender];

        if (userNum == winNum) {
            vault_balance -= winnings;
            (bool success, ) = payable(msg.sender).call{value: winnings}("");
            require(success, "Transfer failed.");
        }

        // 사용자 정보 초기화
        hasPurchased[msg.sender] = false;
        lotteryNumCount[userNum] -= 1;

        // 모든 당첨자가 돈을 수령하면 자동으로 새 라운드 시작
        if (vault_balance == 0 || lotteryNumCount[winNum] == 0) {
            isDraw = false;
            startTime = block.timestamp;
            lotteryNumCount[winNum] = 0;
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
