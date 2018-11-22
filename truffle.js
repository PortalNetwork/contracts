module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      provider: new PrivateKeyProvider(process.env.PRIVATE_KEY, 'https://ropsten.infura.io'),
      network_id: 3
    }
  }
};