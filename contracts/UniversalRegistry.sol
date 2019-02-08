pragma solidity ^0.4.24;

import "./strings.sol";
import "./regex/NameRegex.sol";
import "./regex/ProtocolRegex.sol";
import "./Owned.sol";

contract UniversalRegistry is Owned, NameRegex, ProtocolRegex {

    using strings for *;

    // Logged when the owner of a domain assigns a new owner to a subdomain.
    event NewRegistrant(string name, string protocol, address owner);

    // Logged when the TTL of a node changes
    event NewTTL(string name, string protocol, uint64 ttl);

    // Logged when the owner of a domain transfers ownership to a new account.
    event Transfer(string name, string protocol, address owner);

    // Logged when register protocol
    event RegisterProtocol(string indexed _protocol, address _registrant);

    struct Record {
        address registrant;
        uint64 ttl;
    }

    constructor() public {
    }

    mapping (string => Record) records;
    mapping (string => address) protocolOwner;
    string[] _protocols;

    modifier onlyProtocolOwner(string _protocol) {
        require(_protocol.toSlice().len() > 0);
        require(protocolOwner[_protocol] == msg.sender);
        _;
    }

    modifier onlyRegistrant(string _name, string _protocol) {
        // TODO more check on protocol and name
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        require(NameRegex.nameMatches(_name));
        require(ProtocolRegex.protocolMatches(_protocol));
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        require(records[bns].registrant == msg.sender);
        _;
    }

    /**
     * @dev Set subdomain registrant
     *
     * @param _sub Subdomain of BNS
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param _owner The owner of subdomain
     */
    function setSubdomainRegistrant(string _sub, string _name, string _protocol, address _owner) external onlyRegistrant(_name, _protocol) {
        require(_sub.toSlice().len() > 0);
        require(NameRegex.nameMatches(_sub));
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        _setSubdomainRegistrant(_sub, bns, _owner);
    }

    /**
     * @dev The internal function of setSubdomainRegistrant
     *
     * @param _sub Subdomain of BNS
     * @param _bns BNS
     * @param _owner The owner of subdomain
     */
    function _setSubdomainRegistrant(string _sub, string _bns, address _owner) internal {
        string memory bns = ".".toSlice().concat(_bns.toSlice());
        string memory sub = _sub.toSlice().concat(bns.toSlice());
        records[sub].registrant = _owner;
    }

    /**
     * @dev Set registrant of BNS
     *
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param _registrant Registrant of BNS
     */
    function setRegistrant(string _name, string _protocol, address _registrant) external onlyProtocolOwner(_protocol) {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        require(records[bns].registrant == address(0));
        emit NewRegistrant(_name, _protocol, _registrant);
        records[bns].registrant = _registrant;
    }

    /**
     * @dev Set time to leave of BNS
     * 
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param _ttl Time to leave of BNS
     */
    function setTTL(string _name, string _protocol, uint64 _ttl) external onlyRegistrant(_name, _protocol) {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        emit NewTTL(_name, _protocol, _ttl);
        records[bns].ttl = _ttl;
    }

    /**
     * @dev Get the registrant of BNS
     * 
     * @param bns BNS
     */
    function registrant(string bns) external view returns (address) {
        return records[bns].registrant;
    }

    /**
     * @dev Get the time to leave of BNS
     * 
     * @param bns BNS
     */
    function ttl(string bns) external view returns (uint64) {
        return records[bns].ttl;
    }

    /**
     * @dev Set the protocol owner
     * 
     * @param _protocol Protocol of BNS
     * @param _registrant Registrant of protocol
     */
    function registerProtocol(string _protocol, address _registrant) public onlyOwner {
        require(_protocol.toSlice().len() > 0);
        require(isProtocolAvailable(_protocol) == false);
        _protocols.push(_protocol);
        protocolOwner[_protocol] = _registrant;

        emit RegisterProtocol(_protocol, _registrant);
    }

    /**
     * @dev Check the protocol is available
     * 
     * @param _protocol protocol
     */
    function isProtocolAvailable(string _protocol) public view returns (bool) {
        for(uint i = 0; i < _protocols.length; i++) {
            if (keccak256(abi.encodePacked(_protocol)) == keccak256(abi.encodePacked(_protocols[i]))) {
                return true;
            }
        }
        return false;
    }

}
