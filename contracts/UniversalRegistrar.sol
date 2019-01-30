pragma solidity ^0.4.24;

import "./strings.sol";
import "./regex/NameRegex.sol";
import "./regex/ProtocolRegex.sol";
import "./Registry.sol";
import "./Owned.sol";
import "./PortalNetworkToken.sol";

contract UniversalRegistrar is Owned, NameRegex, ProtocolRegex {

    using strings for *;

    mapping (string => Entry) _entries;
    mapping (address => mapping (string => bytes32)) public sealedBids;
    mapping (string => uint) _registryStartDate;

    uint32 constant totalAuctionLength = 5 days;
    uint32 constant revealPeriod = 48 hours;

    struct Entry {
        string name;
        string protocol;
        uint registrationDate;
        uint value;
        uint highestBid;
        address owner;
    }

    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    event NewBid(address indexed bidder, string name, string protocol);
    event BidRevealed(address indexed owner, string name, string protocol, uint value, uint8 status);
    event BidFinalized(address indexed owner, string name, string protocol, uint value, uint registrationDate);

    Registry registry;
    PortalNetworkToken portalNetworkToken;

    constructor(Registry registryAddr) public {
        registry = registryAddr;
    }

    // Check the state
    modifier inState(string _name, string _protocol, Mode _state) {
        require(state(_name, _protocol) == _state);
        _;
    }

    modifier onlyBnsOwner(string _name, string _protocol) {
        // TODO check the domain owner, msg.sender is the highest bidder
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        require(state(_name, _protocol) == Mode.Owned && msg.sender == _entries[bns].owner);
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
        // TODO check name + protocol Mode is available
        Mode mode = state(_name, _protocol);
        //if (mode == Mode.Auction) return;
        require(mode == Mode.Open || mode == Mode.Auction);
        
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        bytes32 tempSealedBid = sealedBids[msg.sender][bns];
        // TODO make sure the bid is different
        require(tempSealedBid != _sealedBid);

        Entry storage entry = _entries[bns];
        if (entry.registrationDate == 0) {
            entry.registrationDate = now + totalAuctionLength;
            entry.name = _name;
            entry.protocol = _protocol;
            entry.value = 0;
            entry.highestBid = 0;
        }

        // TODO store sealedBid
        sealedBids[msg.sender][bns] = _sealedBid;
        
        // TODO emit event
        emit NewBid(msg.sender, _name, _protocol);
    }

    // TODO revealAuction
    function revealAction(string _name, string _protocol, uint _value, bytes32 _salt) external {
        // TODO check name + protocol Mode is available
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        Mode mode = state(_name, _protocol);
        require(mode == Mode.Reveal);

        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        bytes32 tempSealedBid = sealedBids[msg.sender][bns];
        // TODO check salt and information is correct
        require(shaBid(_name, _protocol, _value, _salt) == tempSealedBid);
        
        // TODO need check over minimun price
        require(portalNetworkToken.balanceOf(msg.sender) >= _value);

        // TODO compare with other data where the bid is the highest bid
        Entry storage entry = _entries[bns];
        if (entry.highestBid < _value) {
            // New winner

            // TODO refund the highestBid to entry.owner, update highestBid to value
            // TODO success bid, and transfer token to pending pool

            // TODO switch msg.sender to entry.owner, and update highestBid
            entry.owner = msg.sender;
            entry.value = entry.highestBid;
            entry.highestBid = _value;

            emit BidRevealed(msg.sender, _name, _protocol, _value, 1);
        } else {
            // Not Winner 
            emit BidRevealed(msg.sender, _name, _protocol, _value, 0);
        }
    }

    // TODO finalizeAuction
    function finalizeAuction(string _name, string _protocol) external onlyBnsOwner(_name, _protocol) {
        // TODO check name + protocol Mode is available
        // TODO check can finalize
        require(_name.toSlice().len() > 0);
        require(_protocol.toSlice().len() > 0);
        Mode mode = state(_name, _protocol);
        require(mode != Mode.Owned);
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        Entry storage entry = _entries[bns];
        require(entry.owner == msg.sender);
            
        entry.registrationDate = now;
        // TODO emit event
        emit BidFinalized(msg.sender, _name, _protocol, entry.highestBid, now);
    }

    function shaBid(string _name, string _protocol, uint value, bytes32 salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name, _protocol, value, salt));
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
