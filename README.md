# ZOKYO-CTF: DENIAL OF SERVICE (DOS)

## Introduction 

Welcome to this internal Zokyo CTF. When talking about CTFs, most of them are designed with a focus on smart contract attacks, where an attacker steals the victim's funds, as this is one of the most critical scenarios that could occur in a protocol. However, there are other situations that can lead to critical scenarios, such as Denial of Service (DoS). If a protocol can be manipulated in such a way that it reaches a state where a user cannot withdraw their funds (they get locked forever), even if the attacker does not directly benefit, it can still be considered a critical vulnerability or attack, as the user will lose all their money.

## Inspiration

This CTF was inspired by one of our previous audits, where the exploit scenario was not initially identified in the audit itself. However, it led me to consider an edge case that could have resulted in a critical scenario, which may also arise in future audits the team will conduct. I am confident that, after completing this workshop, we will all be better equipped to detect such vulnerabilities.

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