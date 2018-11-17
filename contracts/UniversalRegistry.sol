pragma solidity ^0.4.24;

import "./Registry.sol";

contract UniversalRegistry is Registry {
    // Protocol Regex: [a-z]{2,}
    // Name Regex: min 1, max 63, ([a-z0-9-]{0,61}[a-z0-9])?
    // 
}
