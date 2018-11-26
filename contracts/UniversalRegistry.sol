pragma solidity ^0.4.24;

import "./strings.sol";
import "./Registry.sol";
import "./Owned.sol";

contract UniversalRegistry is Owned, Registry {

    using strings for *;

    event RegisterProtocol(string indexed _protocol, address _registrant);

    struct Record {
        address registrant;
        uint64 ttl;
    }

    constructor() public {
    }

    mapping (string => Record) records;
    mapping (string => address) protocols;

    modifier only_protocol_owner(string _protocol) {
        require(protocols[_protocol] == msg.sender);
        _;
    }

    modifier only_registrant(string _name, string _protocol) {
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        require(records[bns].registrant == msg.sender);
        _;
    }

    function setRegistrant(string _name, string _protocol, address _registrant) external only_protocol_owner(_protocol) {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        require(records[bns].registrant == address(0));
        emit NewRegistrant(_name, _protocol, _registrant);
        records[bns].registrant = _registrant;
    }

    function setTTL(string _name, string _protocol, uint64 _ttl) external only_registrant(_name, _protocol) {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        emit NewTTL(_name, _protocol, _ttl);
        records[bns].ttl = _ttl;
    }

    function registrant(string _name, string _protocol) external view returns (address) {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        return records[bns].registrant;
    }

    function ttl(string _name, string _protocol) external view returns (uint64) {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        return records[bns].ttl;
    }

    function registerProtocol(string _protocol, address _registrant) public onlyOwner {
        require(_protocol.toSlice().len() > 0);
        protocols[_protocol] = _registrant;

        emit RegisterProtocol(_protocol, _registrant);
    }

}
