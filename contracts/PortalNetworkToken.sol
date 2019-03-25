pragma solidity ^0.4.24;

import "./strings.sol";
import "./Owned.sol";
import "./ERC20Token.sol";
import "./PortalNetworkTokenConfig.sol";

contract PortalNetworkToken is Owned, ERC20Token, PortalNetworkTokenConfig {

    using strings for *;

    address public prtAccrueAddr;
    address public auctionPoolAddr;
    mapping (string => address) protocolRegistrarAddr;

    event PRTAccrue(
        address indexed _owner, 
        string indexed _name, 
        string indexed _protocol, 
        uint _registrationDate, 
        uint _expiredate, 
        uint256 _value
    );
    
    event UpgradeProtocolRegistrar(string _protocol, address _protocolRegistrarAddr);
    event UpgradePRTAccrue(address _prtAccrueAddr);
    event UpgradeAuctionPool(address _auctionPoolAddr);

    constructor(address _prtAccrueAddr, address _auctionPoolAddr) public
        ERC20Token(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, TOKEN_TOTALSUPPLY, msg.sender)
    { 
        prtAccrueAddr = _prtAccrueAddr;
        auctionPoolAddr = _auctionPoolAddr;
    }
    
    struct Metadata {
        string name;
        string protocol;
        address owner;
        uint registrationDate;
        uint expireDate;
        uint value;
    }

    mapping (string => Metadata) _metadata;

    /**
     * @dev Only available for the ProtocolRegistrar contract
     * 
     * @param _protocol The protocol of the BNS
     */
    modifier onlyProtocolRegistrar(string _protocol) {
        require(msg.sender == address(protocolRegistrarAddr[_protocol]), "sender is not ProtocolRegistrar");
        _;
    }

    /**
     * @dev Transfer PRT to auction pool at the auction process
     *
     * @param _from The from address who need to lock the RPT
     * @param _value The tokne of the bidding price
     * @param _protocol The protocol of the BNS
     */
    function transferToAuctionPool(address _from, uint256 _value, string _protocol) external onlyProtocolRegistrar(_protocol) returns (bool) {
        return _transferToAuctionPool(_from, _value);
    }

    /**
     * @dev The internal function of transferToAuctionPool
     * 
     * @param _from The from address who need to lock the RPT
     * @param _value The token of the bidding price
     */
    function _transferToAuctionPool(address _from, uint256 _value) internal returns (bool) {
        if (_value < 0 || balances[_from] < _value) {
            return false;
        }
        balances[_from] = balances[_from].sub(_value);
        balances[auctionPoolAddr] = balances[auctionPoolAddr].add(_value);
        return true;
    }

    /**
     * @dev Transfer PRT to the origin owner
     * 
     * @param _to The address of the origin sender
     * @param _value The token of the origin amount
     * @param _protocol The protocol of the BNS
     */
    function transferBackToOwner(address _to, uint256 _value, string _protocol) external onlyProtocolRegistrar(_protocol) returns (bool) {
        return _transferBackToOwner(_to, _value);
    }

    /**
     * @dev The internal function of transferBackToOwner
     * 
     * @param _to The address of the origin sender
     * @param _value The token of the origin amount
     */
    function _transferBackToOwner(address _to, uint256 _value) internal returns (bool) {
        if (_value < 0 || balances[auctionPoolAddr] < _value) {
            return false;
        }
        balances[auctionPoolAddr] = balances[auctionPoolAddr].sub(_value);
        balances[_to] = balances[_to].add(_value);
        return true;
    }
    
    /**
     * @dev The function to store the metadata of BNS
     *
     * @param _from The owner of the BNS
     * @param _value The final amount of the BNS
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     * @param _expireDate The expire date of the BNS
     * @param _registrationDate The registration date of the BNS
     */
    function transferWithMetadata(
        address _from, 
        uint256 _value, 
        string _name, 
        string _protocol, 
        uint _expireDate,
        uint _registrationDate
    ) external onlyProtocolRegistrar(_protocol) returns (bool) {
        return _transferWithMetadata(_from, _value, _name, _protocol, _expireDate, _registrationDate);
    }

    /**
     * @dev The internal function of transferWithMetadata
     *
     * @param _from The owner of the BNS
     * @param _value The final amount of the BNS
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     * @param _expireDate The expire date of the BNS
     * @param _registrationDate The registration date of the BNS
     */
    function _transferWithMetadata(
        address _from, 
        uint256 _value, 
        string _name, 
        string _protocol, 
        uint _expireDate,
        uint _registrationDate
    ) internal returns (bool) {
        // TODO finalize and move the Token from AuctionPool address to PRTAccrue address
        balances[auctionPoolAddr] = balances[auctionPoolAddr].sub(_value);
        balances[prtAccrueAddr] = balances[prtAccrueAddr].add(_value);

        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());

        Metadata storage newMetadata = _metadata[bns];
        newMetadata.name = _name;
        newMetadata.protocol = _protocol;
        newMetadata.owner = _from;
        newMetadata.registrationDate = _registrationDate;
        newMetadata.expireDate = _expireDate;
        newMetadata.value = _value;

        emit Transfer(_from, prtAccrueAddr, _value);
        emit PRTAccrue(_from, _name, _protocol, _registrationDate, _expireDate, _value);
        return true;
    }

    /**
     * @dev Get the metadata of the BNS
     *
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     */
    function metadata(string _name, string _protocol) public view returns (address, uint, uint, uint256) {
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        Metadata storage m = _metadata[bns];
        return (m.owner, m.registrationDate, m.expireDate, m.value);
    }

    /**
     * @dev set metadata of BNS
     * 
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     * @param _owner The owner of the BNS
     * @param _registrationDate The registration date of the BNS
     * @param _expireDate The expire date of the BNS
     * @param _value The final amount of the BNS
     */
    function setMetadata(
        string _name, 
        string _protocol, 
        address _owner, 
        uint _registrationDate, 
        uint _expireDate,
        uint _value) external onlyProtocolRegistrar(_protocol) returns (bool) {
        return _setMetadata(_name, _protocol, _owner, _registrationDate, _expireDate, _value);
    }

    /**
     * @dev The internal function of setMetadata
     * 
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     * @param _owner The owner of the BNS
     * @param _registrationDate The registration date of the BNS
     * @param _expireDate The expire date of the BNS
     * @param _value The final amount of the BNS
     */
    function _setMetadata(
        string _name, 
        string _protocol, 
        address _owner, 
        uint _registrationDate, 
        uint _expireDate, 
        uint _value) internal returns (bool) {
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        Metadata storage newMetadata = _metadata[bns];
        newMetadata.name = _name;
        newMetadata.protocol = _protocol;
        newMetadata.owner = _owner;
        newMetadata.registrationDate = _registrationDate;
        newMetadata.expireDate = _expireDate;
        newMetadata.value = _value;
        // TODO store data
        return true;
    }

    /**
     * @dev Update the address of the PRT accrue pool
     * 
     * @param _newPRTAccrue new PRT accrue address
     */
    function upgradePRTAccrue(address _newPRTAccrue) external onlyOwner {
        require(_newPRTAccrue != address(0), "PRTAccrue address can not be 0");
        require(_newPRTAccrue != address(this), "PRTAccrue address can not as same as PortalNetworkToken address");
        require(_newPRTAccrue != prtAccrueAddr, "PRTAccrue address is as same as current address");

        prtAccrueAddr = _newPRTAccrue;

        emit UpgradePRTAccrue(_newPRTAccrue);
    }

    /**
     * @dev Update the Universal Registrar contract
     *
     * @param _protocol The protocol of the BNS
     * @param _newProtocolRegistrar New ProtocolRegistrar address
     */
    function upgradeProtocolRegistrar(string _protocol, address _newProtocolRegistrar) external onlyOwner {
        require(_newProtocolRegistrar != address(0), "ProtocolRegistrar address can not be 0");
        require(_newProtocolRegistrar != address(this), "ProtocolRegistrar address can not as same as PortalNetworkToken address");
        require(_newProtocolRegistrar != protocolRegistrarAddr[_protocol], "ProtocolRegistrar address is as same as current address");

        protocolRegistrarAddr[_protocol] = _newProtocolRegistrar;

        emit UpgradeProtocolRegistrar(_protocol, _newProtocolRegistrar);
    }

    /**
     * @dev Update the auction pool address
     * 
     * @param _newAuctionPool New auction pool address
     */
    function upgradeAuctionPool(address _newAuctionPool) external onlyOwner {
        require(_newAuctionPool != address(0), "AuctionPool address can not be 0");
        require(_newAuctionPool != address(this), "AuctionPool address can not as same as PortalNetworkToken address");
        require(_newAuctionPool != auctionPoolAddr, "AuctionPool address is as same as current address");

        auctionPoolAddr = _newAuctionPool;

        emit UpgradeAuctionPool(_newAuctionPool);
    }

    /**
     * @dev Return protocol registrar address
     * 
     * @param _protocol The protocol of the BNS
     */
    function protocolRegistrar(string _protocol) public view returns (address) {
        return protocolRegistrarAddr[_protocol];
    }
}