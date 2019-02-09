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
    mapping (address => mapping (string => bytes32)) sealedBids;
    mapping (string => ProtocolEntry) _protocolEntries;

    struct ProtocolEntry {
        uint registryStartDate;
        uint32 totalAuctionLength;
        uint32 revealPeriod;
        uint minPrice;
        uint32 nameMaxLength;
        uint32 nameMinLength;
        bool available;
    }

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
    event Transfer(address indexed owner, address indexed newOwner, string name, string protocol);
    event UpdatePortalNetworkToken(address portalNetworkTokenAddress);

    Registry registry;
    PortalNetworkToken public portalNetworkToken;

    constructor(Registry registryAddr) public {
        registry = registryAddr;
    }

    // Check the state
    //modifier inState(string _name, string _protocol, Mode _state) {
    //    require(state(_name, _protocol) == _state, "state is different");
    //    _;
    //}

    modifier onlyBnsOwner(string _name, string _protocol) {
        // TODO check the domain owner, msg.sender is the highest bidder
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        require(state(_name, _protocol) == Mode.Owned && msg.sender == _entries[bns].owner, "state is not Owned or sender is not BNS owner");
        _;
    }

    /**
     * @dev Update the PortalNetworkToken address
     *
     * @param _portalNetworkToken The PortalNetworkToken address
     */
    function updatePortalNetworkTokenAddress(PortalNetworkToken _portalNetworkToken) external onlyOwner {
        require(_portalNetworkToken != address(0), "PortalNetworkToken address can not set 0x0");
        require(_portalNetworkToken != address(this), "PortalNetworkToken address can not be the same as UniversalRegistrar");
        require(_portalNetworkToken != portalNetworkToken, "PortalNetworkToken address is the same as current address");

        portalNetworkToken = _portalNetworkToken;

        emit UpdatePortalNetworkToken(_portalNetworkToken);
    }

    /**
     * @dev Start an auction of the BNS
     *
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param _sealedBid Sealed bid of the bidding BNS
     */
    function startAuction(string _name, string _protocol, bytes32 _sealedBid) external {
        _startAuction(_name, _protocol, _sealedBid);
    }

    /**
     * @dev The internal function of start an auction of the BNS
     *
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param _sealedBid Sealed bid of the bidding BNS
     */
    function _startAuction(string _name, string _protocol, bytes32 _sealedBid) internal {
        require(_protocol.toSlice().len() > 0, "Protocol length incorrect");
        require(ProtocolRegex.protocolMatches(_protocol), "Protocol mismatch");
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        require(protocolEntry.available == true, "Protocol is not availalbe");
        // TODO check protocol is available
        require(NameRegex.nameMatches(_name), "Name mismatch");
        // TODO check name is available
        require(_name.toSlice().len() >= protocolEntry.nameMinLength, "Name length incorrect");
        // TODO check name + protocol Mode is available
        Mode mode = state(_name, _protocol);
        //if (mode == Mode.Auction) return;
        require(mode == Mode.Open || mode == Mode.Auction, "Mode incorrect");
        
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        bytes32 tempSealedBid = sealedBids[msg.sender][bns];
        // TODO make sure the bid is different
        require(tempSealedBid != _sealedBid, "SealedBid is the same");

        Entry storage entry = _entries[bns];
        if (entry.registrationDate == 0) {
            entry.registrationDate = now + protocolEntry.totalAuctionLength;
            entry.owner = address(0);
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

    /**
     * @dev Reveal an auction of the BNS
     *
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param _value The bid amount of BNS
     * @param _salt The salt of the sealed bid
     */
    function revealAuction(string _name, string _protocol, uint _value, bytes32 _salt) external {
        require(_protocol.toSlice().len() > 0, "Protocol length incorrect");
        require(ProtocolRegex.protocolMatches(_protocol), "Protocol mismatch");
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        require(protocolEntry.available == true, "Protocol is not availalbe");
        // TODO check protocol is available
        require(NameRegex.nameMatches(_name), "Name mismatch");
        // TODO check name is available
        require(_name.toSlice().len() >= protocolEntry.nameMinLength, "Name length incorrect");
        Mode mode = state(_name, _protocol);
        require(mode == Mode.Reveal, "Mode incorrect");
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        bytes32 tempSealedBid = sealedBids[msg.sender][bns];
        // TODO check salt and information is correct
        require(shaBid(_name, _protocol, _value, _salt) == tempSealedBid, "shaBid is not the same");
        
        // TODO need check over minimun price
        require(_value >= protocolEntry.minPrice, "Bid value is lower then minimum price");
        require(portalNetworkToken.balanceOf(msg.sender) >= _value, "Bidder's PRT is no enough");

        // TODO compare with other data where the bid is the highest bid
        Entry storage entry = _entries[bns];
        if (entry.highestBid < _value) {
            // New winner

            // TODO We do lock PRT first and then move the PRT token of new highest bidder to AuctionPool
            if (!portalNetworkToken.transferToAuctionPool(msg.sender, _value)) {
                return;
            }
            if (entry.owner != address(0) && entry.highestBid > 0) {
                portalNetworkToken.transferBackToOwner(entry.owner, entry.highestBid);
            }
            
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

    /**
     * @dev Finalize an auction of the BNS
     *
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     */
    function finalizeAuction(string _name, string _protocol) external onlyBnsOwner(_name, _protocol) {
        // TODO check name + protocol Mode is available
        Mode mode = state(_name, _protocol);
        require(mode == Mode.Owned, "Mode incorrect");
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        Entry storage entry = _entries[bns];
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        require(entry.owner == msg.sender, "sender is not the BNS owner");
        
        // TODO if the bidder is the only one then refund by vickrey rule
        if (entry.value == 0) {
            portalNetworkToken.transferBackToOwner(entry.owner, entry.highestBid - protocolEntry.minPrice);
        } else if (entry.value > 0 && entry.highestBid > entry.value) {
            portalNetworkToken.transferBackToOwner(entry.owner, entry.highestBid - entry.value);
        }

        // TODO We do lock PRT first before register to registry
        portalNetworkToken.transferWithMetadata(
            entry.owner, 
            (entry.value > protocolEntry.minPrice) ? entry.value : protocolEntry.minPrice, 
            entry.name, 
            entry.protocol, 
            entry.registrationDate
        );

        // TODO update UniversalRegistry
        registry.setRegistrant(_name, _protocol, msg.sender);

        // TODO emit event
        emit BidFinalized(msg.sender, _name, _protocol, entry.highestBid, now);
    }

    function shaBid(string _name, string _protocol, uint value, bytes32 salt) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_name, _protocol, value, salt));
    }

    /**
     * @dev The owner of a domain may transfer it to someone else at any time.
     *
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     * @param newOwner The address to transfer ownership to
     */
    function transfer(string _name, string _protocol, address newOwner) external onlyBnsOwner(_name, _protocol) {
        // TODO check name is available
        require(_name.toSlice().len() > 0, "Name length incorrect");
        // TODO check protocol is available
        require(_protocol.toSlice().len() > 0, "Protocol length incorrect");
        require(NameRegex.nameMatches(_name), "Name mismatch");
        require(ProtocolRegex.protocolMatches(_protocol), "Protocol mismatch");
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        Entry storage entry = _entries[bns];
        address currentOwner = entry.owner;
        entry.owner = newOwner;

        registry.setRegistrant(_name, _protocol, newOwner);
        emit Transfer(currentOwner, newOwner, _name, _protocol);
    }

    
    /**
     * @dev Get the entries of the BNS
     * 
     * @param _name Name of BNS
     * @param _protocol Protocol of BNS
     */
    function entries(string _name, string _protocol) external view returns (Mode, string, uint, uint, uint, address) {
        // TODO check name is available
        require(_name.toSlice().len() > 0, "Name length incorrect");
        // TODO check protocol is available
        require(_protocol.toSlice().len() > 0, "Protocol length incorrect");
        require(NameRegex.nameMatches(_name), "Name mismatch");
        require(ProtocolRegex.protocolMatches(_protocol), "Protocol mismatch");
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());

        Entry storage entry = _entries[bns];
        return (state(_name, _protocol), bns, entry.registrationDate, entry.value, entry.highestBid, entry.owner);
    }

    // State transitions for names:
    //   Open -> Auction (startAuction)
    //   Auction -> Reveal
    //   Reveal -> Owned
    //   Reveal -> Open (if nobody bid)
    //   Owned -> Open (releaseDeed or invalidateName)
    function state(string _name, string _protocol) public view returns (Mode) {
        require(_protocol.toSlice().len() > 0, "Protocol length incorrect");
        require(ProtocolRegex.protocolMatches(_protocol), "Protocol mismatch");
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        require(protocolEntry.available == true, "Protocol is not availalbe");
        // TODO check protocol is available
        require(NameRegex.nameMatches(_name), "Name mismatch");
        // TODO check name is available
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());

        Entry storage entry = _entries[bns];

        if (_name.toSlice().len() > protocolEntry.nameMaxLength || 
            _name.toSlice().len() < protocolEntry.nameMinLength || 
            !isAllowed(_protocol, now)) {
            return Mode.NotYetAvailable;
        } else if (now < entry.registrationDate) {
            if (now < (entry.registrationDate - protocolEntry.revealPeriod)) {
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
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        require(protocolEntry.available == true, "Protocol is not available");
        return protocolEntry.registryStartDate;
    }

    /**
     * @dev Set Protocol information
     * 
     * @param _protocol Protocol of BNS
     * @param registryStartDate Protocol registry start date
     * @param totalAuctionLength Protocol total auction length
     * @param revealPeriod Protocol reveal period
     * @param nameMaxLength The BNS name max length
     * @param nameMinLength The BNS name min length
     * @param minPrice The min bidding price of BNS
     * @param available Is the protocol available
     */
    function setProtocolEntry(
        string _protocol, 
        uint registryStartDate, 
        uint32 totalAuctionLength, 
        uint32 revealPeriod, 
        uint32 nameMaxLength, 
        uint32 nameMinLength, 
        uint minPrice, 
        bool available
    ) external onlyOwner {
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        protocolEntry.registryStartDate = registryStartDate;
        protocolEntry.totalAuctionLength = totalAuctionLength;
        protocolEntry.revealPeriod = revealPeriod;
        protocolEntry.nameMaxLength = nameMaxLength;
        protocolEntry.nameMinLength = nameMinLength;
        protocolEntry.minPrice = minPrice;
        protocolEntry.available = available;
    }

    /**
     * @dev Get the protocol entries
     *
     * @param _protocol Protocol of BNS
     */
    function protocolEntries(string _protocol) external view returns (uint, uint32, uint32, uint32, uint32, uint, bool) {
        require(_protocol.toSlice().len() > 0, "Protocol length incorrect");
        require(ProtocolRegex.protocolMatches(_protocol), "Protocol mismatch");
        ProtocolEntry storage protocolEntry = _protocolEntries[_protocol];
        return (
            protocolEntry.registryStartDate, 
            protocolEntry.totalAuctionLength, 
            protocolEntry.revealPeriod, 
            protocolEntry.nameMaxLength, 
            protocolEntry.nameMinLength, 
            protocolEntry.minPrice, 
            protocolEntry.available
        );
    }
}
