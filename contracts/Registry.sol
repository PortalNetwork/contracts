pragma solidity ^0.4.24;

contract Registry {

    // Logged when the owner of a domain assigns a new owner to a subdomain.
    event NewOwner(string indexed name, string indexed protocol, address owner);

    // Logged when the owner of a domain transfers ownership to a new account.
    event Transfer(string indexed name, string indexed protocol, address owner);

    function setOwner(string name, string protocol, address owner) public;
    function owner(string name, string protocol) public view returns (address);

}