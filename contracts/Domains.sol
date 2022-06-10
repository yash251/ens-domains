// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import { StringUtils } from "./libraries/StringUtils.sol";
import "hardhat/console.sol";

contract Domains {
  // for domain
  string public tld; // top-level domain
  // data type to store their names
  mapping(string => address) public domains;

  // mapping to store values
  mapping(string => string) public records;

  constructor(string memory _tld) payable {
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }

  // this function will give us the price of a domain based on length
  function price(string calldata name) public pure returns (uint) {
    uint len = StringUtils.strlen(name);
    require(len > 0);
    if (len == 3) {
      return 5 * 10**17; // 18 decimals, 0.5 MATIC
    }
    else if (len == 4) {
      return 3 * 10**17; // 0.3
    }
    else {
      return 1 * 10**17;
    }
  }
  // a register function that adds their names to our mapping
  function register(string calldata name) public payable { // calldata - this indicates the “location” of where the name argument should be stored
    // check that name is unregistered
    require(domains[name] == address(0));

    uint _price = price(name);

    // check if enough MATIC was paid in txn
    require(msg.value >= _price, "Not enough MATIC paid");

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