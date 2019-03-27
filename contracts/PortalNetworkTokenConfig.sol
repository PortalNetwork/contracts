pragma solidity ^0.4.24;

contract PortalNetworkTokenConfig {

    string  public constant TOKEN_SYMBOL      = "PRT";
    string  public constant TOKEN_NAME        = "Portal Network Token";
    uint8   public constant TOKEN_DECIMALS    = 18;

    uint256 public constant DECIMALSFACTOR    = 10**uint256(TOKEN_DECIMALS);
    uint256 public constant TOKEN_TOTALSUPPLY = 1000000000 * DECIMALSFACTOR;
}