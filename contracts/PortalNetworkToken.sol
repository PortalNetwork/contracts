pragma solidity ^0.4.18;

import "./ERC20Token.sol";
import "./PortalNetworkTokenConfig.sol";

contract PortalNetworkToken is ERC20Token, PortalNetworkTokenConfig {

    constructor() public
    ERC20Token(TOKEN_NAME, TOKEN_SYMBOL, TOKEN_DECIMALS, TOKEN_TOTALSUPPLY, msg.sender)
    { }
}