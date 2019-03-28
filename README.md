# Portal Network Contracts

## Prerequirement

- Solidity: 0.4.24
- Truffle
- Ganache

### Portal Network Token (PRT)
Portal Network Token (PRT) is a requirement for Portal Network’s blockchain name service to be decentralized, scalable and operate across different protocols. It will fuel the adoption of its BNS standard through built-in incentives for stakeholders, and will be the access gate to Portal Network’s additional services like MUMEI and KAIZEN. PRT tokens are fungible, ERC20-based Ethereum Tokens.  
  
An ERC20 standard token, built using the [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity) framework.

#### Information
- Name: Portal Network Token
- Symbol: PRT
- Decimals: 18
- Total Supply: 1000000000

### Universal Registrar
Universal Registrar contract is to register a blockchain name service, it using Vickrey auction with the bidding flow.

#### Vickrey Auction
With Universal Registrar, is implement the secret auction with Portal Network Token contract, the Portal Network Token contract is the pool for check the bidding price, and it can be check at reveal period, this action wont expose the real bid price of the sealed bid.

### Universal Registry
Universal Registry is to set the blockchain name service owner, ttl and subdomain.

## Contract

- NameRegex.sol: https://ropsten.etherscan.io/tx/0x8a4746ad8743d267f0adea902e53eb6ea31f1bbae3a6218fb2f81dcd8d2a25e6
- ProtocolRegex.sol: https://ropsten.etherscan.io/tx/0xe4fa1ea2bfe7d748744bb4e9612e65185af992e76f1c2ce5abf8c20507528584
- UniversalRegistry.sol: https://ropsten.etherscan.io/tx/0xe5831343854b0be0384eef2fa63332d8a554e1532593d7f2c0072a67702f26c9
- UniversalRegistrar.sol: https://ropsten.etherscan.io/tx/0x7835695e50d494a9753bbbb24e91b8f72d410225e353f633985d006c565a4cdf
- PortalNetworkToken.sol: https://ropsten.etherscan.io/tx/0x7caafab84e2a293e3756b09df1e40b7b6b5063ebf3c55c132140f293c0090f52


| Network    | Contract Name      | Contract address                                   | Transaction hash
|------------|--------------------|----------------------------------------------------|---------------------
| Ropsten    | NameRegex          | [0xba267219f38f5eaec6b20902f6684b1c8f0de70e](https://ropsten.etherscan.io/address/0xba267219f38f5eaec6b20902f6684b1c8f0de70e) | [0x8a4746ad8743d267f0adea902e53eb6ea31f1bbae3a6218fb2f81dcd8d2a25e6](https://ropsten.etherscan.io/tx/0x8a4746ad8743d267f0adea902e53eb6ea31f1bbae3a6218fb2f81dcd8d2a25e6)
| Ropsten    | ProtocolRegex      | [0x2bab9f0a7d21ae8fb35af5a88eacc66cfdbc541a](https://ropsten.etherscan.io/address/0x2bab9f0a7d21ae8fb35af5a88eacc66cfdbc541a) | [0xe4fa1ea2bfe7d748744bb4e9612e65185af992e76f1c2ce5abf8c20507528584](https://ropsten.etherscan.io/tx/0xe4fa1ea2bfe7d748744bb4e9612e65185af992e76f1c2ce5abf8c20507528584)
| Ropsten    | UniversalRegistry  | [0x76827857ac0c927690477c9d6667ffafc57247db](https://ropsten.etherscan.io/address/0x76827857ac0c927690477c9d6667ffafc57247db) | [0xe5831343854b0be0384eef2fa63332d8a554e1532593d7f2c0072a67702f26c9](https://ropsten.etherscan.io/tx/0xe5831343854b0be0384eef2fa63332d8a554e1532593d7f2c0072a67702f26c9)
| Ropsten    | UniversalRegistrar | [0xf576c44b9bc18c8030fa2fe62e1fe1e03e280abc](https://ropsten.etherscan.io/address/0xf576c44b9bc18c8030fa2fe62e1fe1e03e280abc) | [0x7835695e50d494a9753bbbb24e91b8f72d410225e353f633985d006c565a4cdf](https://ropsten.etherscan.io/tx/0x7835695e50d494a9753bbbb24e91b8f72d410225e353f633985d006c565a4cdf)
| Ropsten    | PortalNetworkToken | [0x6a3818ceea34bcf9f95b34b5f90e02071f4e757c](https://ropsten.etherscan.io/address/0x6a3818ceea34bcf9f95b34b5f90e02071f4e757c) | [0x7caafab84e2a293e3756b09df1e40b7b6b5063ebf3c55c132140f293c0090f52](https://ropsten.etherscan.io/tx/0x7caafab84e2a293e3756b09df1e40b7b6b5063ebf3c55c132140f293c0090f52)

## Development

### Dependency
- [node.js](https://nodejs.org/en/)
- [Ganache-cli](https://github.com/trufflesuite/ganache-cli)
- [Truffle](http://truffleframework.com/docs/getting_started/installation)

### Installation

MacOS installation
```
brew install node
npm i -g ganache-cli
npm i -g truffle
```

### Running Test Cases

Start ganache and create `1001` accounts for testing

```
ganache-cli -a 1001
```

Test smart contracts

```
truffle compile
truffle migrate
truffle test
```

## Code Coverage

We use [solidity-coverage](https://www.npmjs.com/package/solidity-coverage) for the code coverage of smart contracts.

### Running Code Coverage 

Run the command below.
```
./node_modules/.bin/solidity-coverage
```

Also can check the code coverage report, [HERE](./COVERAGE.md)

## Reference
- [Truffle documentation](http://truffleframework.com/docs/)
- [Solidity Regex](https://github.com/gnidan/solregex)
- [Solidity String Utils](https://github.com/Arachnid/solidity-stringutils/)

## License
[MIT](./LICENSE)
