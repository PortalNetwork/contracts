pragma solidity ^0.4.24;

import "./Owned.sol";
import "./ERC20Token.sol";
import "./PortalNetworkTokenConfig.sol";

contract PortalNetworkToken is Owned, ERC20Token, PortalNetworkTokenConfig {
    constructor() public
        ERC20Token(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, TOKEN_TOTALSUPPLY, msg.sender)
    { 
    }
}