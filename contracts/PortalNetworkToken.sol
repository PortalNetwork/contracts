pragma solidity ^0.4.24;

import "./strings.sol";
import "./Owned.sol";
import "./ERC20Token.sol";
import "./PortalNetworkTokenConfig.sol";

contract PortalNetworkToken is Owned, ERC20Token, PortalNetworkTokenConfig {

    using strings for *;

    address public prtAccrueAddr;
    address public universalRegistrarAddr;
    address public auctionPoolAddr;

    event PRTAccrue(
        address indexed _owner, 
        string indexed _name, 
        string indexed _protocol, 
        uint _registrationDate, 
        uint _expiredate, 
        uint256 _value
    );
    
    event UpgradeUniversalRegistrar(address _universalRegistrarAddr);
    event UpgradePRTAccrue(address _prtAccrueAddr);
    event UpgradeAuctionPool(address _auctionPoolAddr);

    constructor(address _prtAccrueAddr, address _universalRegistrarAddr, address _auctionPoolAddr) public
        ERC20Token(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, TOKEN_TOTALSUPPLY, msg.sender)
    { 
        prtAccrueAddr = _prtAccrueAddr;
        universalRegistrarAddr = _universalRegistrarAddr;
        auctionPoolAddr = _auctionPoolAddr;
    }

    struct Metadata {
        string name;
        string protocol;
        address owner;
        uint registrationDate;
        uint expireDate;
        uint256 value;
    }

    mapping (string => Metadata) _metadata;

    /**
     * Only available for the UniversalRegistrar contract
     */
    modifier onlyUniversalRegistrar() {
        require(msg.sender == address(universalRegistrarAddr));
        _;
    }

    /**
     * @dev Transfer PRT to auction pool at the auction process
     *
     * @param _from The from address who need to lock the RPT
     * @param _value The tokne of the bidding price
     */
    function transferToAuctionPool(address _from, uint256 _value) external onlyUniversalRegistrar {
        _transferToAuctionPool(_from, _value);
    }

    /**
     * @dev The internal function of transferToAuctionPool
     * 
     * @param _from The from address who need to lock the RPT
     * @param _value The token of the bidding price
     */
    function _transferToAuctionPool(address _from, uint256 _value) internal {
        require(_value > 0);
        require(balances[_from] >= _value);
        balances[_from] = balances[_from].sub(_value);
        balances[auctionPoolAddr] = balances[auctionPoolAddr].add(_value);
    }

    /**
     * @dev Transfer PRT to the origin owner
     * 
     * @param _to The address of the origin sender
     * @param _value The token of the origin amount
     */
    function transferBackToOwner(address _to, uint256 _value) external onlyUniversalRegistrar {
        _transferBackToOwner(_to, _value);
    }

    /**
     * @dev The internal function of transferBackToOwner
     * 
     * @param _to The address of the origin sender
     * @param _value The token of the origin amount
     */
    function _transferBackToOwner(address _to, uint256 _value) internal {
        require(_value > 0);
        require(balances[auctionPoolAddr] >= _value);
        balances[auctionPoolAddr] = balances[auctionPoolAddr].sub(_value);
        balances[_to] = balances[_to].add(_value);
    }
    
    /**
     * @dev The function to store the metadata of BNS
     *
     * @param _from The owner of the BNS
     * @param _value The final amount of the BNS
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     * @param _registrationDate The registration date of the BNS
     */
    function transferWithMetadata(
        address _from, 
        uint256 _value, 
        string _name, 
        string _protocol, 
        uint _registrationDate
    ) external onlyUniversalRegistrar {
        _transferWithMetadata(_from, _value, _name, _protocol, _registrationDate);
    }

    /**
     * @dev The internal function of transferWithMetadata
     *
     * @param _from The owner of the BNS
     * @param _value The final amount of the BNS
     * @param _name The name of the BNS
     * @param _protocol The protocol of the BNS
     * @param _registrationDate The registration date of the BNS
     */
    function _transferWithMetadata(
        address _from, 
        uint256 _value, 
        string _name, 
        string _protocol, 
        uint _registrationDate
    ) internal {
        balances[_from] = balances[_from].sub(_value);
        balances[prtAccrueAddr] = balances[prtAccrueAddr].add(_value);

        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        uint _expireDate = _registrationDate + 365 days;

        Metadata storage newMetadata = _metadata[bns];
        newMetadata.name = _name;
        newMetadata.protocol = _protocol;
        newMetadata.owner = _from;
        newMetadata.registrationDate = _registrationDate;
        newMetadata.expireDate = _expireDate;
        newMetadata.value = _value;

        emit Transfer(_from, prtAccrueAddr, _value);
        emit PRTAccrue(_from, _name, _protocol, _registrationDate, _expireDate, _value);
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
     * @dev Update the address of the PRT accrue pool
     * 
     * @param _newPRTAccrue new PRT accrue address
     */
    function upgradePRTAccrue(address _newPRTAccrue) external onlyOwner {
        require(_newPRTAccrue != address(0));
        require(_newPRTAccrue != address(this));
        require(_newPRTAccrue != prtAccrueAddr);

        prtAccrueAddr = _newPRTAccrue;

        emit UpgradePRTAccrue(_newPRTAccrue);
    }

    /**
     * @dev Update the Universal Registrar contract
     *
     * @param _newUniversalRegistrar New UniversalRegistrar address
     */
    function upgradeUniversalRegistrar(address _newUniversalRegistrar) external onlyOwner {
        require(_newUniversalRegistrar != address(0));
        require(_newUniversalRegistrar != address(this));
        require(_newUniversalRegistrar != universalRegistrarAddr);

        universalRegistrarAddr = _newUniversalRegistrar;

        emit UpgradeUniversalRegistrar(_newUniversalRegistrar);
    }

    /**
     * @dev Update the auction pool address
     * 
     * @param _newAuctionPool New auction pool address
     */
    function upgradeAuctionPool(address _newAuctionPool) external onlyOwner {
        require(_newAuctionPool != address(0));
        require(_newAuctionPool != address(this));
        require(_newAuctionPool != auctionPoolAddr);

        auctionPoolAddr = _newAuctionPool;

        emit UpgradeAuctionPool(_newAuctionPool);
    }
}