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

## Running Code Coverage 

Run the command below.
```
./node_modules/.bin/solidity-coverage
```

## Coverage Report
```
-------------------------------|----------|----------|----------|----------|----------------|
File                           |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
-------------------------------|----------|----------|----------|----------|----------------|
 contracts/                    |    31.84 |    20.22 |    41.57 |    30.21 |                |
  ERC20Interface.sol           |      100 |      100 |      100 |      100 |                |
  ERC20Token.sol               |    45.83 |      100 |       60 |    45.83 |... 80,85,87,89 |
  Math.sol                     |    55.56 |    33.33 |       50 |    55.56 |    22,24,26,31 |
  Owned.sol                    |    15.79 |     8.33 |       50 |       20 |... 59,60,62,64 |
  PortalNetworkToken.sol       |     54.9 |    45.83 |    66.67 |    55.77 |... 157,158,159 |
  PortalNetworkTokenConfig.sol |      100 |      100 |      100 |      100 |                |
  Registry.sol                 |      100 |      100 |      100 |      100 |                |
  UniversalRegistrar.sol       |    67.48 |    35.58 |    68.75 |    64.06 |... 299,302,310 |
  UniversalRegistry.sol        |    18.42 |       10 |    27.27 |    19.51 |... 113,122,131 |
  strings.sol                  |     5.88 |     1.04 |    13.33 |     7.63 |... 709,710,714 |
 contracts/regex/              |     56.1 |       40 |    63.64 |     56.1 |                |
  NameRegex.sol                |    54.55 |    41.67 |       60 |    54.55 |... 32,35,40,46 |
  ProtocolRegex.sol            |    57.89 |     37.5 |    66.67 |    57.89 |... 37,41,42,45 |
-------------------------------|----------|----------|----------|----------|----------------|
All files                      |    33.79 |    21.58 |       44 |    32.09 |                |
-------------------------------|----------|----------|----------|----------|----------------|

Istanbul coverage reports generated
```