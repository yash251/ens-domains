// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Domains {
  // data type to store their names
  mapping(string => address) public domains;

  // mapping to store values
  mapping(string => string) public records;

  constructor() {
    console.log("This is a constructor");
  }
  // a register function that adds their names to our mapping
  function register(string calldata name) public { // calldata - this indicates the “location” of where the name argument should be stored
    // check that name is unregistered
    require(domains[name] == address(0));
    domains[name] = msg.sender;
    console.log("%s has registered a domain!", msg.sender);
  }

  // this function will give us domain owner's address
  function getAddress(string calldata name) public view returns (address) {
    return domains[name];
  }

  function setRecord(string calldata name, string calldata record) public {
    // check that owner is the txn sender
    require(domains[name] == msg.sender);
    records[name] = record;
  }

  function getRecord(string calldata name) public view returns (string memory) {
    return records[name];
  }
}