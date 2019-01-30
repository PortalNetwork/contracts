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

    modifier onlyUniversalRegistrar() {
        require(msg.sender == address(universalRegistrarAddr));
        _;
    }
    
    function transferWithMetadata(
        address _from, 
        uint256 _value, 
        string _name, 
        string _protocol, 
        uint _registrationDate
        ) public onlyUniversalRegistrar returns (bool success) {
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

        return true;
    }

    function metadata(string _name, string _protocol) public view returns (address, uint, uint, uint256) {
        string memory protocol = ".".toSlice().concat(_protocol.toSlice());
        string memory bns = _name.toSlice().concat(protocol.toSlice());
        Metadata storage m = _metadata[bns];
        return (m.owner, m.registrationDate, m.expireDate, m.value);
    }

    function upgradePRTAccure(address _newPRTAccrue) external onlyOwner {
        require(_newPRTAccrue != address(0));
        require(_newPRTAccrue != address(this));
        require(_newPRTAccrue != prtAccrueAddr);

        prtAccrueAddr = _newPRTAccrue;

        emit UpgradePRTAccrue(_newPRTAccrue);
    }

    function upgradeUniversalRegistrar(address _newUniversalRegistrar) external onlyOwner {
        require(_newUniversalRegistrar != address(0));
        require(_newUniversalRegistrar != address(this));
        require(_newUniversalRegistrar != universalRegistrarAddr);

        universalRegistrarAddr = _newUniversalRegistrar;

        emit UpgradeUniversalRegistrar(_newUniversalRegistrar);
    }

    function upgradeAuctionPool(address _newAuctionPool) external onlyOwner {
        require(_newAuctionPool != address(0));
        require(_newAuctionPool != address(this));
        require(_newAuctionPool != auctionPoolAddr);

        auctionPoolAddr = _newAuctionPool;

        emit UpgradeAuctionPool(_newAuctionPool);
    }
}