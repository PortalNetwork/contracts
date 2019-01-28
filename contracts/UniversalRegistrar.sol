pragma solidity ^0.4.24;

import "./strings.sol";
import "./regex/NameRegex.sol";
import "./regex/ProtocolRegex.sol";
import "./Registry.sol";
import "./Owned.sol";

contract UniversalRegistrar is Owned, NameRegex, ProtocolRegex {

    using strings for *;

    mapping (string => Entry) _entries;
    mapping (address => mapping (string => bytes32)) public sealedBids;
    mapping (string => uint) _registryStartDate;

    uint32 constant revealPeriod = 48 hours;

    struct Entry {
        string name;
        string protocol;
        uint registrationDate;
        uint value;
        uint highestBid;
    }

    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    Registry registry;

    constructor(Registry registryAddr) public {
        registry = registryAddr;
    }

    modifier inState(string _name, string _protocol) {
        // TODO check state
        _;
    }

    modifier onlyBnsOwner(string _name, string _protocol) {
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
        _startAuction(_name, _protocol, _registrant, _sealedBid);
    }

    // TODO _startAuction internal
    function _startAuction(string _name, string _protocol, address _registrant, bytes32 _sealedBid) internal {
        // TODO check name is available
        require(_name.toSlice().len() > 0);
        // TODO check protocol is available
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        
        // TODO check name + protocol Mode is available
        // TODO store sealedBid
        // TODO emit event

        // TODO bid will check the address have enough PRT
        sealedBids[msg.sender][bns] = _sealedBid;
    }

    // TODO revealAuction
    function revealAction(string _name, string _protocol, uint _value, bytes32 _salt) external {
        // TODO check name + protocol Mode is available
        // TODO check salt and information is correct
        // TODO compare with other data where the bid is the highest bid
        // TODO refund or keep 
        // TODO emit event
    }

    // TODO finalizeAuction
    function finalizeAuction(string _name, string _protocol) external onlyBnsOwner(_name, _protocol) {
        // TODO check name + protocol Mode is available
        // TODO check can finalize
        // TODO emit event
    }

    // TODO entries (status check)
    function entries(string _name, string _protocol) external view returns (Mode, string, string, uint, uint, uint) {
        // TODO check name is available
        require(_name.toSlice().len() > 0);
        // TODO check protocol is available
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());

        Entry storage entry = _entries[bns];
        return (state(_name, _protocol), entry.name, entry.protocol, entry.registrationDate, entry.value, entry.highestBid);
    }

    // State transitions for names:
    //   Open -> Auction (startAuction)
    //   Auction -> Reveal
    //   Reveal -> Owned
    //   Reveal -> Open (if nobody bid)
    //   Owned -> Open (releaseDeed or invalidateName)
    function state(string _name, string _protocol) public view returns (Mode) {
        // TODO check name is available
        require(_name.toSlice().len() > 0);
        // TODO check protocol is available
        require(_protocol.toSlice().len() > 0);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());

        Entry storage entry = _entries[bns];

        if (!isAllowed(_protocol, now)) {
            return Mode.NotYetAvailable;
        } else if (now < entry.registrationDate) {
            if (now < entry.registrationDate - revealPeriod) {
                return Mode.Auction;
            } else {
                return Mode.Reveal;
            }
        } else {
            if (entry.highestBid == 0) {
                return Mode.Open;
            } else {
                return Mode.Owned;
            }
        }
    }

    /**
     * @dev Determines if a name is available for registration yet
     *
     * Each name will be assigned a random date in which its auction
     * can be started, from 0 to 8 weeks
     *
     * @param _protocol The protocol to start an auction on
     * @param _timestamp The timestamp to query about
     */
    function isAllowed(string _protocol, uint _timestamp) public view returns (bool allowed) {
        return _timestamp > getAllowedTime(_protocol);
    }

    /**
     * @dev Returns available date for protocol
     *
     * The available time from the `registryStarted` for a hash is proportional
     * to its numeric value.
     *
     * @param _protocol The hash to start an auction on
     */
    function getAllowedTime(string _protocol) public view returns (uint) {
        return _registryStartDate[_protocol];
    }

    /**
     * 
     */
    function setRegistryStartDate(string _protocol, uint registryStartDate) external onlyOwner {
        _registryStartDate[_protocol] = registryStartDate;
    }
}
