pragma solidity ^0.4.24;

interface Registry {

    // Logged when the owner of a domain assigns a new owner to a subdomain.
    event NewRegistrant(string indexed name, string indexed protocol, address owner);

    // Logged when the TTL of a node changes
    event NewTTL(string indexed name, string indexed protocol, uint64 ttl);

    // Logged when the owner of a domain transfers ownership to a new account.
    event Transfer(string indexed name, string indexed protocol, address owner);

    function setRegistrant(string name, string protocol, address owner) external;
    function setTTL(string name, string protocol, uint64 ttl) external;
    function registrant(string name, string protocol) external view returns (address);
    function ttl(string name, string protocol) external view returns (uint64);

}