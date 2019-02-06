# Solidity Coverage

## Test contracts

On localhost testing.

```
NameRegex address 		 0x2cAc03060B611f0e0196a779E83FED51e3022b14
ProtocolRegex address 		 0x4a3707f999dD13c4e427Cf7e2a0380D50285ba4d
UniversalRegistry address 	 0x438a3CBA4D3991513F2FB66dD2329dA1d731F6bF
UniversalRegistrar address 	 0x00791f9C54757AD048c0E2698B62E9D41031A752
PortalNetworkToken address 	 0xB439F2200942E3981e89B5410791519B4Cedf7a5
```

## Coverage Report
```
-------------------------------|----------|----------|----------|----------|----------------|
File                           |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-------------------------------|----------|----------|----------|----------|----------------|
 contracts/                    |    31.97 |       20 |    41.57 |    30.46 |                |
  ERC20Interface.sol           |      100 |      100 |      100 |      100 |                |
  ERC20Token.sol               |    45.83 |      100 |       60 |    45.83 |... 80,85,87,89 |
  Math.sol                     |    55.56 |    33.33 |       50 |    55.56 |    22,24,26,31 |
  Owned.sol                    |    15.79 |     8.33 |       50 |       20 |... 59,60,62,64 |
  PortalNetworkToken.sol       |    58.33 |    42.86 |    66.67 |    59.18 |... 151,153,154 |
  PortalNetworkTokenConfig.sol |      100 |      100 |      100 |      100 |                |
  Registry.sol                 |      100 |      100 |      100 |      100 |                |
  UniversalRegistrar.sol       |    67.21 |    34.62 |    68.75 |    64.06 |... 258,261,269 |
  UniversalRegistry.sol        |       20 |    11.76 |    27.27 |    20.93 |... 85,86,90,94 |
  strings.sol                  |     5.88 |     1.04 |    13.33 |     7.63 |... 709,710,714 |
 contracts/regex/              |     56.1 |       40 |    63.64 |     56.1 |                |
  NameRegex.sol                |    54.55 |    41.67 |       60 |    54.55 |... 32,35,40,46 |
  ProtocolRegex.sol            |    57.89 |     37.5 |    66.67 |    57.89 |... 37,41,42,45 |
-------------------------------|----------|----------|----------|----------|----------------|
All files                      |    33.93 |    21.33 |       44 |    32.33 |                |
-------------------------------|----------|----------|----------|----------|----------------|

Istanbul coverage reports generated
```