# Portal Network Contracts

### Portal Network Token (PRT)
Portal Network Token (PRT) is a requirement for Portal Network’s blockchain name service to be decentralized, scalable and operate across different protocols. It will fuel the adoption of its BNS standard through built-in incentives for stakeholders, and will be the access gate to Portal Network’s additional services like MUMEI and KAIZEN. PRT tokens are fungible, ERC20-based Ethereum Tokens.  
  
An ERC20 standard token, built using the [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-solidity) framework.

#### Information
- Name: Portal Network Token
- Symbol: PRT
- Decimals: 18
- Total Supply: 4000000000

### Universal Registrar

### Universal Registry

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

## Reference
- [Truffle documentation](http://truffleframework.com/docs/)
- [Solidity Regex](https://github.com/gnidan/solregex)

## License
[MIT](./LICENSE)
