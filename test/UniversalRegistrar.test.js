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

    it('set registry start date', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();

        const now = 1549344525;
        const totalAuctionLength = 60; // 432000; // (5 days)
        const revealPeriod = 30; // 172800; // (48 hours)
        const nameMaxLength = 10;
        const nameMinLength = 6;
        const minPrice = "1000000000000000000";

        //let nowTime = await universalRegistrar.getNow.call();
        //console.log('nowTime', (new BN(nowTime, 16)).toString(10));
        
        //                                                             5 days  48 hours
        //await universalRegistrar.setProtocolEntry('etc', 1549344525, 432000,   172800, 10, 6, "1000000000000000000", {from: accounts[0]});
        await universalRegistrar.setProtocolEntry('etc', now, totalAuctionLength, revealPeriod, nameMaxLength, nameMinLength, "1000000000000000000", {from: accounts[0]});
        let allowedTime = await universalRegistrar.getAllowedTime('etc');
        assert.equal(allowedTime, now, 'allowedTime isn\'t correct');

        let protocolEntry = await universalRegistrar.protocolEntries('etc');
        assert.equal(protocolEntry[1].toNumber(), totalAuctionLength, 'protocolEntry.totalAuctionLength isn\'t correct');
        assert.equal(protocolEntry[2].toNumber(), revealPeriod, 'protocolEntry.revealPeriod isn\'t correct');
        assert.equal(protocolEntry[3].toNumber(), nameMaxLength, 'protocolEntry.nameMaxLength isn\'t correct');
        assert.equal(protocolEntry[4].toNumber(), nameMinLength, 'protocolEntry.nameMinLength isn\'t correct');
        assert.equal((new BN(protocolEntry[5], 16)).toString(10), minPrice, 'protocolEntry.minPrice isn\'t correct');
        assert.equal(protocolEntry[6], true, 'protocolEntry.available isn\'t correct');
        
        let isAllowed = await universalRegistrar.isAllowed('etc', new Date().getTime());
        assert.equal(isAllowed, true, 'isAllowed isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });

    it('state', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'welcome';
        const protocol = 'etc';

        let isAllowed = await universalRegistrar.isAllowed(protocol, new Date().getTime());
        assert.equal(isAllowed, true, 'isAllowed isn\'t correct');

        let mode = await universalRegistrar.state(name, protocol);
        console.log(mode);
      } catch (err) {
        console.log(err);
      }
    })

    it('start auction with incorrect name', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'he';
        const protocol = 'etc';

        const shaBid = await universalRegistrar.shaBid(name, protocol, "2000000000000000000", web3.utils.sha3("secret"));
        const startAuction1 = await universalRegistrar.startAuction(name, protocol, shaBid);
        assert.equal(startAuction1.receipt.status, false);
        assert.fail('start auction check did not fail');
      } catch (err) {
        
      }
    });

    it('start auction with correct name', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'welcome';
        const protocol = 'etc';

        const shaBid = await universalRegistrar.shaBid(name, protocol, "2000000000000000000", web3.utils.sha3("secret"));
        const startAuction2 = await universalRegistrar.startAuction(name, protocol, shaBid);
        assert.equal(startAuction2.receipt.status, true);
      } catch (err) {
        console.log(err);
      }
    });
  })
})