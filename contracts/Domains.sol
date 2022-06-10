// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Domains {
  // data type to store their names
  mapping(string => address) public domains;

  constructor() {
    console.log("This is a constructor");
  }
  // a register function that adds their names to our mapping
  function register(string calldata name) public { // calldata - this indicates the “location” of where the name argument should be stored
    domains[name] = msg.sender;
    console.log("%s has registered a domain!", msg.sender);
  }

  // this function will give us domain owner's address
  function getAddress(string calldata name) public view returns (address) {
    return domains[name];
  }
}