// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Domains {
  // data type to store their names
  mapping(string => address) public domains;
  constructor() {
    console.log("This is a constructor");
  }
}