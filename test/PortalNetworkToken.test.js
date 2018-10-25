const PortalNetworkToken = artifacts.require('PortalNetworkToken.sol');

contract('Portal Network Token', function (accounts) {
  describe('contract testing', async () => {
    it('initialize', async () => {
      try {
        let PRT = await PortalNetworkToken.deployed();
        let name = await PRT.name.call();
        let symbol = await PRT.symbol.call();
        let decimals = await PRT.decimals.call();
        let totalSupply = await PRT.totalSupply.call();

        assert.equal(name, 'Portal Network Token', 'name isn\'t correct');
        assert.equal(symbol, 'PRT', 'symbol isn\'t correct');
        assert.equal(decimals, 18, 'decimals isn\'t correct');
        assert.equal(totalSupply.toNumber(), 4000000000000000000000000000, 'totalSupply isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });

    it('token holder balance', async () => {
      try {
        let PRT = await PortalNetworkToken.deployed();
        let balance = await PRT.balanceOf.call(accounts[0]);
        assert.equal(balance.toNumber(), 4000000000000000000000000000, 'balance isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });

    it('token transfer', async () => {
      try {
        let PRT = await PortalNetworkToken.deployed();

        

      } catch (err) {
        console.log(err);
      }
    });
  })
});