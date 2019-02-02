const UniversalRegistry = artifacts.require('UniversalRegistry.sol');

contract('UniversalRegistry', function (accounts) {
  describe('contract testing', async () => {
    it('contract address', async () => {
      try {
        let universalRegistry = await UniversalRegistry.deployed();
        console.log('UniversalRegistry address', universalRegistry.address);
      } catch (err) {
        console.log(err);
      }
    });

    it('create new protocol', async () => {
      try {
        let universalRegistry = await UniversalRegistry.deployed();
        await universalRegistry.registerProtocol('etc', accounts[0], {from: accounts[0]});

        let isProtocolAvailable = await universalRegistry.isProtocolAvailable.call('etc');
        let isProtocolAvailable2 = await universalRegistry.isProtocolAvailable.call('etf');
        assert.equal(isProtocolAvailable, true, 'isProtocolAvailable isn\'t correct');
        assert.equal(isProtocolAvailable2, false, 'isProtocolAvailable isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });
  });
});