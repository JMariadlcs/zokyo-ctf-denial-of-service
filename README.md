# ZOKYO-CTF: DENIAL OF SERVICE (DOS)

## Introduction 

Welcome to this internal Zokyo CTF. When talking about CTFs, most of them are designed with a focus on smart contract attacks, where an attacker steals the victim's funds, as this is one of the most critical scenarios that could occur in a protocol. However, there are other situations that can lead to critical scenarios, such as Denial of Service (DoS). If a protocol can be manipulated in such a way that it reaches a state where a user cannot withdraw their funds (they get locked forever), even if the attacker does not directly benefit, it can still be considered a critical vulnerability or attack, as the user will lose all their money.

## Inspiration

This CTF was inspired by one of our previous audits, where the exploit scenario was not initially present in the audit itself. However, it led me to consider an edge case that could have resulted in a critical scenario, which may also arise in future audits the team will conduct. I am confident that, after completing this workshop, we will all be better equipped to detect such vulnerabilities.

## CTF description

Regarding the scenario itself, it consists of a single smart contract, BetSystem.sol, which is a system that allows users to create new bets, and other users to bet against the created bets.

From a user's perspective, two main actions are possible: 

1. designBet: A user can create a new bet by specifying certain parameters, which generates a unique betId with its information stored in mappings. 
2. betAgainst: A user can choose to bet against a bet that has already been created by another user (10 minutes after bet creation should be passed).

Once the bet is finished, the protocol owner is responsible for submitting the bet result by executing resolvedBet, ensuring that the funds are correctly distributed to the winner. This action is centralized for the purpose of simplifying the CTF.

## CTF goal
The goal of the CTF is to manipulate the current protocol to create a scenario where users' funds are lost. 

To achieve this, an exploit script has been created in the test folder: ExploitPoc.t.sol. 

You will find: 
1. test_CorrectWorkingOfBetSystem: This is a complete test case demonstrating the correct functioning of the protocol, allowing you to understand how the bet system works and which actors are involved in the operation of a bet resolution. 
2. test_POCExploit: This is the test case where you should write your solution. The final conditions have already been added to provide context on which action should be reverted.

Remember to keep your answers private so that everyone can complete the CTF individually. Feel free to submit them if you’d like to have them checked. I'll also push the solution in a few days. Don't forget to enjoy this cool CTF, paying close attention to edge case scenarios, and developing your hacker mindset. 

The goal is to think not like a developer, but like an attacker trying to identify the weak points of a protocol. I'm sure this will help us enhance our skills for future audits! 🚀🚀🚀

# SOLUTION

The vulnerability arises from the improper handling of the `betCreatorAmount` mapping when creating bets. The line:

```solidity
betCreatorAmount[betId] += betAmount;
```

Which should be replaced with: 

```solidity
betCreatorAmount[betId] = betAmount;
```

This incorrect use of the += operator allows an attacker to exploit the contract by creating multiple bets with the same betId, which results in an unintended accumulation of the bet amount.

## Vulnerability Flow
1. Initial Bet Creation:

- An attacker (bet creator) creates a bet by calling designBet with a specified amount (e.g., 1 ether). The contract assigns a betId based on the parameters, and the betCreatorAmount[betId] is incremented by the bet amount (1 ether).

```solidity
bytes32 betId = betSystem.designBet{value: betAmount}(betAmount, allowedGameNumber, gameResult, endTime);
```

2. Canceling the Bet:

- The attacker then cancels the bet using the cancelBet function, which refunds the original bet amount back to the attacker. This effectively allows the attacker to retrieve their funds.

```solidity
betSystem.cancelBet(betId);
```

3. Creating a New Bet:

- The attacker creates a new bet with the same betId but with a zero ether amount:

```solidity
bytes32 betId2 = betSystem.designBet{value: 0}(0, allowedGameNumber, gameResult, endTime);
```

- Due to the nature of how betId is generated, the new bet will have the same betId as the original bet, thus:

```
assert(betId2 == betId); // betId remains unchanged
```

4. Accidental Accumulation:

- Since the original bet amount of 1 ether remains in betCreatorAmount[betId], the total amount for the new bet is still considered to be 1 ether, even though no funds were sent in the latest transaction. This leads to a situation where:

```solidity
betCreatorAmount[betId] += betAmount; // now contains the total of 1 ether.
```

5. Bet Rival Participation:

- Another participant (bet rival) then bets against the attacker, transferring the expected amount (1 ether) to the contract.

```solidity
betSystem.betAgaisnt{value: betAmount}(betId, rivalGameResult);
```

6. Resolving the Bet:

- Finally, when the bet is resolved, the contract attempts to distribute the funds based on the results. However, since the attacker's original bet was effectively canceled and recreated, and they sent 0 ether in the second transaction, the contract only has the 1 ether from the rival's bet, leading to an execution failure when trying to distribute the funds. The expected revert message is:

```solidity
vm.expectRevert("Transfer failed");
```

## Conclusion
This vulnerability allows an attacker to exploit the bet system by creating, canceling, and recreating a bet within the same block. By manipulating the bet amount, they can cause the contract to fail during fund distribution, leading to a loss of funds for the contract.