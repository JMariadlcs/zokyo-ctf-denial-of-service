# ZOKYO-CTF: DENIAL OF SERVICE (DOS)

## Introduction 

Welcome to this internal Zokyo CTF. When talking about CTFs, most of them are designed with a focus on smart contract attacks, where an attacker steals the victim's funds, as this is one of the most critical scenarios that could occur in a protocol. However, there are other situations that can lead to critical scenarios, such as Denial of Service (DoS). If a protocol can be manipulated in such a way that it reaches a state where a user cannot withdraw their funds (they get locked forever), even if the attacker does not directly benefit, it can still be considered a critical vulnerability or attack, as the user will lose all their money.

# Inspiration

This CTF was inspired by one of our previous audits, where the exploit scenario was not initially identified in the audit itself. However, it led me to consider an edge case that could have resulted in a critical scenario, which may also arise in future audits the team will conduct. I am confident that, after completing this workshop, we will all be better equipped to detect such vulnerabilities.

# CTF description

Regarding the scenario itself, it consists of a single smart contract, BetSystem.sol, which is a system that allows users to create new bets, and other users to bet against the created bets.

From a user's perspective, two main actions are possible: 

1. designBet: A user can create a new bet by specifying certain parameters, which generates a unique betId with its information stored in mappings. 
2. betAgainst: A user can choose to bet against a bet that has already been created by another user (10 minutes after bet creation should be passed).

Once the bet is finished, the protocol owner is responsible for submitting the bet result by executing resolvedBet, ensuring that the funds are correctly distributed to the winner. This action is centralized for the purpose of simplifying the CTF.