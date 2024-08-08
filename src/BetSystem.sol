// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import '../lib/openzeppelin-contracts/contracts/access/Ownable.sol';

contract BetSystem is Ownable {

    enum BetResult {
        WinTeam0,
        WinTeam1,
        Draw
    }
    
    enum BetStatus {
        Created,
        Accepted,
        Cancelled,
        Completed
    }

    mapping(bytes32 => BetStatus) public betStatus;
    mapping(bytes32 => address) public betCreatorAddress;
    mapping(bytes32 => address) public betRivalAddress;
    mapping(bytes32 => uint256) public betCreatorAmount;
    mapping(bytes32 => uint256) public betRivalAmount;
    mapping(bytes32 => BetResult) public betCreatorResult;
    mapping(bytes32 => BetResult) public betRivalResult;
    mapping(bytes32 => uint256) public betEndTime;
    
    constructor() Ownable(msg.sender) {}  

    function designBet(uint256 betAmount, uint256 allowedGameNumber, BetResult gameResult, uint256 endTime) public payable returns(bytes32 betId) {
        require(msg.value == betAmount);

        betId = keccak256(
            abi.encodePacked(block.timestamp, msg.sender, allowedGameNumber, endTime)
        );

        betCreatorAddress[betId] = msg.sender;
        betStatus[betId] = BetStatus.Created;
        betCreatorAmount[betId] += betAmount;
        betCreatorResult[betId] = gameResult;
        betEndTime[betId] = endTime;
    }

    function betAgaisnt(bytes32 betId, BetResult gameResult) public payable {
        require(betStatus[betId] == BetStatus.Created, "Bet is not active");
        require(betRivalAddress[betId] == address(0), "Bet is in progress");
        require(betCreatorAddress[betId] != msg.sender, "Incorrect better");
        require(gameResult != betCreatorResult[betId], "You can not bet the same result");

        uint256 rivalAmount = betCreatorAmount[betId];
        require(msg.value == rivalAmount);

        betRivalAddress[betId] = msg.sender;
        betRivalAmount[betId] = rivalAmount;
        betRivalResult[betId] = gameResult;
        betStatus[betId] == BetStatus.Accepted;
    }

    function resolvedBet(bytes32 betId, BetResult finalGameResult) public onlyOwner() {
        require(block.timestamp >= betEndTime[betId], "Game not finished yet");

        uint256 totalBetAmount = betCreatorAmount[betId] + betRivalAmount[betId];

        if (betCreatorResult[betId] == finalGameResult) {
            (bool success, ) = betCreatorAddress[betId].call{value: totalBetAmount}("");
            require(success, "Transfer failed");
        } else if (betRivalResult[betId] == finalGameResult) {
            (bool success, ) = betRivalAddress[betId].call{value: totalBetAmount}("");
            require(success, "Transfer failed");
        } else {
            (bool success, ) = betCreatorAddress[betId].call{value:  betCreatorAmount[betId]}("");
            require(success, "Transfer failed");
            (bool success2, ) = betRivalAddress[betId].call{value: betRivalAmount[betId]}("");
            require(success2, "Transfer failed");
        }
        betStatus[betId] == BetStatus.Completed;
    }

    function cancelBet(bytes32 betId) public {
        require(betCreatorAddress[betId] == msg.sender, "Only creator can cancel");
        require(betStatus[betId] == BetStatus.Created, "Bet already accepted");

        (bool success, ) = betCreatorAddress[betId].call{value:  betCreatorAmount[betId]}("");
        require(success, "Transfer failed");
        
        betStatus[betId] == BetStatus.Cancelled;
    }
}
