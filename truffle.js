const PrivateKeyProvider = require("truffle-privatekey-provider");

module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    coverage: { // For the code coverage 
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
    /*ropsten: {
      provider: new PrivateKeyProvider(process.env.PRIVATE_KEY, 'https://ropsten.infura.io'),
      network_id: 3
    }*/
  },
  compilers: {
    solc: {
      version: "0.4.24",
      optimizer: {
        enabled: false,
        runs: 200
      }
      // version: "0.5.1",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      // settings: {          // See the solidity docs for advice about optimization and evmVersion
      //  optimizer: {
      //    enabled: false,
      //    runs: 200
      //  },
      //  evmVersion: "byzantium"
      // }
    }
  }
};