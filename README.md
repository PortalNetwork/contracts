# Portal Network Contracts

### Portal Network Token (PRT)
Portal Network Token (PRT) is a requirement for Portal Network’s blockchain name service to be decentralized, scalable and operate across different protocols. It will fuel the adoption of its BNS standard through built-in incentives for stakeholders, and will be the access gate to Portal Network’s additional services like MUMEI and KAIZEN. PRT tokens are fungible, ERC20-based Ethereum Tokens. 

#### Information
- Name: Portal Network Token
- Symbol: PRT
- Decimals: 18
- Total Supply: 4000000000

### Universal Registrar

### Universal Registry

## Development

### Dependency
- node.js v8+ (includes npm)
- Ganache-cli
- Truffle

### Installation

MacOS quick setup
```
brew install node
npm i -g ganache-cli
npm i -g truffle
```

### Running Tests

Start ganache and create 1001 accounts

```
ganache-cli -a 1001
```

Test smart contract

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
