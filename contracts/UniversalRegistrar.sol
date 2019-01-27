pragma solidity ^0.4.24;

import "./strings.sol";
import "./regex/NameRegex.sol";
import "./regex/ProtocolRegex.sol";
import "./Registry.sol";

contract UniversalRegistrar is NameRegex, ProtocolRegex {

    using strings for *;

    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    Registry registry;

    constructor(Registry registryAddr) public {
        registry = registryAddr;
    }

    modifier inState(string _name, string _protocol) {
        // TODO check state
        _;
    }

    modifier onlyOwner(string _name, string _protocol) {
        // TODO check the domain owner, msg.sender is the highest bidder
        _;
    }

    // TODO remove this function in production mode
    function register(string _name, string _protocol, address _registrant) public {
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        require(NameRegex.nameMatches(_name));
        require(ProtocolRegex.protocolMatches(_protocol));

        registry.setRegistrant(_name, _protocol, _registrant);

        // TODO set metadata to PortalNetworkToken
    }

    // TODO startAuction
    function startAuction(string _name, string _protocol, address _registrant, bytes32 _sealedBid) external {

    }

    // TODO revealAuction
    function revealAction(string _name, string _protocol, uint _value, bytes32 _salt) external {

    }

    // TODO finalizeAuction
    function finalizeAuction(string _name, string _protocol) external onlyOwner(_name, _protocol) {
        // TODO check can finalize
    }
 
    // TODO entries (status check)
    function entries(string _name, string _protocol) external view returns (Mode, address, uint, uint, uint) {
        
    }
}