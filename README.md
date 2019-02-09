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
- Total Supply: 4000000000

### Universal Registrar
Universal Registrar contract is to register a blockchain name service, it using Vickrey auction with the bidding flow.

#### Vickrey Auction
With Universal Registrar, is implement the secret auction with Portal Network Token contract, the Portal Network Token contract is the pool for check the bidding price, and it can be check at reveal period, this action wont expose the real bid price of the sealed bid.

### Universal Registry
Universal Registry is to set the blockchain name service owner, ttl and subdomain.

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
