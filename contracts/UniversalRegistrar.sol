pragma solidity ^0.4.24;

import "./strings.sol";
import "./regex/NameRegex.sol";
import "./regex/ProtocolRegex.sol";
import "./Registry.sol";

contract UniversalRegistrar is NameRegex, ProtocolRegex {

    using strings for *;

    Registry registry;

    constructor(Registry registryAddr) public {
        registry = registryAddr;
    }

    function register(string _name, string _protocol, address _registrant) public {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        require(NameRegex.nameMatches(_name));
        require(ProtocolRegex.protocolMatches(_protocol));

        registry.setRegistrant(_name, _protocol, _registrant);

        // TODO set metadata to PortalNetworkToken
    }

     
}