// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import { Base64 } from "./libraries/Base64.sol";

contract Domains is ERC721URIStorage {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  address payable public owner;
  mapping(string => address) public domains;  // data type to store their names
  mapping(string => string) public records;  // mapping to store values
  mapping(uint => string) public names;  // mapping to display all domains

  error Unauthorized();  // custom errors
  error AlreadyRegistered();
  error InvalidName(string name);

  string public tld; // for domain top-level domain

  string svgPartOne = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><path fill="url(#B)" d="M0 0h270v270H0z"/><defs><filter id="A" color-interpolation-filters="sRGB" filterUnits="userSpaceOnUse" height="270" width="270"><feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity=".225" width="200%" height="200%"/></filter></defs><path d="M72.863 42.949c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-10.081 6.032-6.85 3.934-10.081 6.032c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-8.013-4.721a4.52 4.52 0 0 1-1.589-1.616c-.384-.665-.594-1.418-.608-2.187v-9.31c-.013-.775.185-1.538.572-2.208a4.25 4.25 0 0 1 1.625-1.595l7.884-4.59c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v6.032l6.85-4.065v-6.032c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595L41.456 24.59c-.668-.387-1.426-.59-2.197-.59s-1.529.204-2.197.59l-14.864 8.655a4.25 4.25 0 0 0-1.625 1.595c-.387.67-.585 1.434-.572 2.208v17.441c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l10.081-5.901 6.85-4.065 10.081-5.901c.668-.387 1.426-.59 2.197-.59s1.529.204 2.197.59l7.884 4.59a4.52 4.52 0 0 1 1.589 1.616c.384.665.594 1.418.608 2.187v9.311c.013.775-.185 1.538-.572 2.208a4.25 4.25 0 0 1-1.625 1.595l-7.884 4.721c-.668.387-1.426.59-2.197.59s-1.529-.204-2.197-.59l-7.884-4.59a4.52 4.52 0 0 1-1.589-1.616c-.385-.665-.594-1.418-.608-2.187v-6.032l-6.85 4.065v6.032c-.013.775.185 1.538.572 2.208a4.25 4.25 0 0 0 1.625 1.595l14.864 8.655c.668.387 1.426.59 2.197.59s1.529-.204 2.197-.59l14.864-8.655c.657-.394 1.204-.95 1.589-1.616s.594-1.418.609-2.187V55.538c.013-.775-.185-1.538-.572-2.208a4.25 4.25 0 0 0-1.625-1.595l-14.993-8.786z" fill="#fff"/><defs><linearGradient id="B" x1="0" y1="0" x2="270" y2="270" gradientUnits="userSpaceOnUse"><stop stop-color="#cb5eee"/><stop offset="1" stop-color="#0cd7e4" stop-opacity=".99"/></linearGradient></defs><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = '</text></svg>';  // We'll be storing our NFT images on chain as SVGs

  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  constructor(string memory _tld) 
    ERC721("Khushi Name Service", "KNS") 
    payable 
  {
    owner = payable(msg.sender);
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }

  function isOwner() public view returns (bool) {
    return msg.sender == owner;
  }

  function price(string calldata name) public pure returns (uint) {  // this function will give us the price of a domain based on length
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
  
  function register(string calldata name) public payable { // calldata - this indicates the “location” of where the name argument should be stored
    // check that name is unregistered
    if (domains[name] != address(0)) revert AlreadyRegistered();
    if (!valid(name)) revert InvalidName(name);
    require(domains[name] == address(0));

    uint _price = price(name);
    require(msg.value >= _price, "Not enough MATIC paid");  // check if enough MATIC was paid in txn

    // combining the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, ".", tld)); // encodePacked function to turn a bunch of strings into bytes and then combines them
    string memory finalSvg = string(
      abi.encodePacked(svgPartOne, _name, svgPartTwo)  // creating the SVG imagefor NFT with the name
    );  
    uint newRecordId = _tokenIds.current();
    uint length = StringUtils.strlen(name);
    string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenId %d", name, tld, newRecordId);

    string memory json = Base64.encode(  // creating json metadata of our NFT using Base64
      abi.encodePacked(
        '{"name": "',
        _name,
        '", "description": "A domain on the Khushi Name Service", "image": "data:/image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '","length":"',
        strLen,
        '"}'
      )
    );

    string memory finalTokenUri = string ( abi.encodePacked("data:application/json;base64,", json));

    console.log("\n--------------------------------------------------------");
    console.log("Final tokenURI", finalTokenUri);
    console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);

    domains[name] = msg.sender;
    console.log("%s has registered a domain!", msg.sender);

    names[newRecordId] = name;
    _tokenIds.increment();
  }

  function getAllNames() public view returns (string[] memory) {
    console.log("Getting all names from contract");
    string[] memory allNames = new string[](_tokenIds.current());
    for (uint i = 0; i < _tokenIds.current(); i++) {
      allNames[i] = names[i];
      console.log("Name for token %d is %s", i, allNames[i]);
    }

    return allNames;
  }

  function valid(string calldata name) public pure returns (bool) {
    return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 15;
  }

  function getAddress(string calldata name) public view returns (address) {  // this function will give us domain owner's address
    return domains[name];
  }

  function setRecord(string calldata name, string calldata record) public {
    if (msg.sender != domains[name]) revert Unauthorized();  // check that owner is the txn sender
    records[name] = record;
  }

  function getRecord(string calldata name) public view returns (string memory) {
    return records[name];
  }

  function withdraw() public onlyOwner {
    uint amount = address(this).balance;

    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Failed to withdraw MATIC");
  }
}