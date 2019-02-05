const UniversalRegistry = artifacts.require('UniversalRegistry.sol');
const UniversalRegistrar = artifacts.require('UniversalRegistrar.sol');
const BN = require('bn.js');

contract('UniversalRegistrar', function (accounts) {
  describe('contract testing', async () => {
    it('contract address', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        console.log('UniversalRegistrar address', universalRegistrar.address);
      } catch (err) {
        console.log(err);
      }
    });

    it('start auction with incorrect name', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'hello';
        const protocol = 'etc';
      } catch (err) {
        console.log(err);
      }
    });

    it('set registry start date', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();

        let now = new Date().getTime();
        //                                                    5 days  48 hours
        await universalRegistrar.setProtocolEntry('etc', now, 432000,   172800, "1000000000000000000", {from: accounts[0]});
        let allowedTime = await universalRegistrar.getAllowedTime('etc');
        assert.equal(allowedTime, now, 'allowedTime isn\'t correct');

        let protocolEntry = await universalRegistrar.protocolEntries('etc');
        assert.equal(protocolEntry[1].toNumber(), 432000, 'protocolEntry.totalAuctionLength isn\'t correct');
        assert.equal(protocolEntry[2].toNumber(), 172800, 'protocolEntry.revealPeriod isn\'t correct');
        assert.equal((new BN(protocolEntry[3], 16)).toString(10), "1000000000000000000", 'protocolEntry.minPrice isn\'t correct');
        assert.equal(protocolEntry[4], true, 'protocolEntry.available isn\'t correct');
        
        let isAllowed = await universalRegistrar.isAllowed('etc', new Date().getTime());
        assert.equal(isAllowed, true, 'isAllowed isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });

  })
})