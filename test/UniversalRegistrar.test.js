const UniversalRegistry = artifacts.require('UniversalRegistry.sol');
const UniversalRegistrar = artifacts.require('UniversalRegistrar.sol');
const PortalNetworkToken = artifacts.require('PortalNetworkToken.sol');
const BN = require('bn.js');
const sleep = require('sleep');

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
        const totalAuctionLength = 10; // 432000; // (5 days)
        const revealPeriod = 7; // 172800; // (48 hours)
        const nameMaxLength = 10;
        const nameMinLength = 6;
        const minPrice = "1000000000000000000";
        
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

    it('state available', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'welcome';
        const protocol = 'etc';

        let isAllowed = await universalRegistrar.isAllowed(protocol, new Date().getTime());
        assert.equal(isAllowed, true, 'isAllowed isn\'t correct');

        let mode = await universalRegistrar.state(name, protocol);
        assert.equal(new BN(mode, 16).toString(10), "0");
      } catch (err) {
        console.log(err);
      }
    });

    it('state not yet available', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const protocol = 'etc';
        
        const name2 = 'wordistoolong';  // too long
        let mode2 = await universalRegistrar.state(name2, protocol);
        assert.equal(new BN(mode2, 16).toString(10), "5");

        const name3 = 'a';  // too short
        let mode3  = await universalRegistrar.state(name3, protocol);
        assert.equal(new BN(mode3, 16).toString(10), "5");
      } catch (err) {
        console.log(err);
      }
    });

    it('register registry protocol owner', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        let universalRegistry = await UniversalRegistry.deployed();
        const protocol = 'etc';

        const registerProtocol1 = await universalRegistry.registerProtocol(protocol, universalRegistrar.address);
        assert.equal(registerProtocol1.receipt.status, true);
      } catch (err) {
        console.log(err);
      }
    });

    it('set PortalNetworkToken address', async () => {
      try {
        let portalNetworkToken = await PortalNetworkToken.deployed();
        let universalRegistrar = await UniversalRegistrar.deployed();

        await universalRegistrar.updatePortalNetworkTokenAddress(portalNetworkToken.address);
        const portalNetworkTokenAddress = await universalRegistrar.portalNetworkToken.call();
        assert.equal(portalNetworkToken.address, portalNetworkTokenAddress, 'PortalNetworkToken address isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });

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

        const shaBid1 = await universalRegistrar.shaBid(name, protocol, "2000000000000000000", web3.utils.sha3("secret"));
        const startAuction2 = await universalRegistrar.startAuction(name, protocol, shaBid1, {from: accounts[1]});
        assert.equal(startAuction2.receipt.status, true);

        const shaBid2 = await universalRegistrar.shaBid(name, protocol, "1000000000000000000", web3.utils.sha3("welcome"));
        const startAuction3 = await universalRegistrar.startAuction(name, protocol, shaBid2, {from: accounts[2]});
        assert.equal(startAuction3.receipt.status, true);
      } catch (err) {
        console.log(err);
      }
    });

    it('start auction with minimum bidding price', async () => {
      try {
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'minimum';
        const protocol = 'etc';

        const shaBid3 = await universalRegistrar.shaBid(name, protocol, "1000000000000000000", web3.utils.sha3("secret"));
        const startAuction4 = await universalRegistrar.startAuction(name, protocol, shaBid3, {from: accounts[3]});
        assert.equal(startAuction4.receipt.status, true);
      } catch (err) {
        console.log(err);
      }
    });

    it('reveal auction with correct name', async () => {
      try {
        let portalNetworkToken = await PortalNetworkToken.deployed();
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'welcome';
        const protocol = 'etc';

        const transfer1 = await portalNetworkToken.transfer(accounts[1], "5000000000000000000", {from: accounts[0]});
        assert.equal(transfer1.receipt.status, true);
        const transfer2 = await portalNetworkToken.transfer(accounts[2], "6000000000000000000", {from: accounts[0]});
        assert.equal(transfer2.receipt.status, true);

        const bidderBalanceBefore1 = await portalNetworkToken.balanceOf.call(accounts[1]);
        const bidderBalanceBefore2 = await portalNetworkToken.balanceOf.call(accounts[2]);
        const auctionPoolAddress = await portalNetworkToken.auctionPoolAddr.call();
        const auctionPoolBalanceBefore = await portalNetworkToken.balanceOf.call(auctionPoolAddress);
        assert.equal(new BN(bidderBalanceBefore1, 16).toString(10), "5000000000000000000");
        assert.equal(new BN(bidderBalanceBefore2, 16).toString(10), "6000000000000000000");
        assert.equal(new BN(auctionPoolBalanceBefore, 16).toString(10), "0");
        //console.log(new BN(bidderBalanceBefore, 16).toString(10), new BN(auctionPoolBalanceBefore, 16).toString(10));

        sleep.sleep(5);        

        const entries = await universalRegistrar.entries.call(name, protocol);
        assert.equal(new BN(entries[0], 16).toString(10), "4");
        //console.log(new BN(entries[3], 16).toString(10), ((new Date()).getTime() / 1000));

        const revealAuction2 = await universalRegistrar.revealAuction(name, protocol, "1000000000000000000", web3.utils.sha3("welcome"), {from: accounts[2]});
        assert.equal(revealAuction2.receipt.status, true);
        const bidderBalanceProcess2 = await portalNetworkToken.balanceOf.call(accounts[2]);
        const auctionPoolBalanceProcess1 = await portalNetworkToken.balanceOf.call(auctionPoolAddress);
        assert.equal(new BN(bidderBalanceProcess2, 16).toString(10), "5000000000000000000");
        assert.equal(new BN(auctionPoolBalanceProcess1, 16).toString(10), "1000000000000000000");

        sleep.sleep(1);

        const revealAuction1 = await universalRegistrar.revealAuction(name, protocol, "2000000000000000000", web3.utils.sha3("secret"), {from: accounts[1]});
        assert.equal(revealAuction1.receipt.status, true);
        
        // TODO balance should change
        const bidderBalanceAfter1 = await portalNetworkToken.balanceOf.call(accounts[1]);
        const bidderBalanceAfter2 = await portalNetworkToken.balanceOf.call(accounts[2]);
        const auctionPoolBalanceAfter2 = await portalNetworkToken.balanceOf.call(auctionPoolAddress);
        assert.equal(new BN(bidderBalanceAfter1, 16).toString(10), "3000000000000000000");
        assert.equal(new BN(bidderBalanceAfter2, 16).toString(10), "6000000000000000000");
        assert.equal(new BN(auctionPoolBalanceAfter2, 16).toString(10), "2000000000000000000");
        //console.log(new BN(bidderBalanceAfter, 16).toString(10), new BN(auctionPoolBalanceAfter, 16).toString(10));
      } catch (err) {
        console.log(err);
      }
    });

    it('reveal auction with minimum bidding price', async () => {
      try {
        let portalNetworkToken = await PortalNetworkToken.deployed();
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'minimum';
        const protocol = 'etc';

        const transfer3 = await portalNetworkToken.transfer(accounts[3], "10000000000000000000", {from: accounts[0]});
        assert.equal(transfer3.receipt.status, true);

        const bidderBalanceBefore3 = await portalNetworkToken.balanceOf.call(accounts[3]);
        assert.equal(new BN(bidderBalanceBefore3, 16).toString(10), "10000000000000000000");

        const entries = await universalRegistrar.entries.call(name, protocol);
        assert.equal(new BN(entries[0], 16).toString(10), "4");

        const revealAuction3 = await universalRegistrar.revealAuction(name, protocol, "1000000000000000000", web3.utils.sha3("secret"), {from: accounts[3]});
        assert.equal(revealAuction3.receipt.status, true);

        const bidderBalanceAfter3 = await portalNetworkToken.balanceOf.call(accounts[3]);
        assert.equal(new BN(bidderBalanceAfter3, 16).toString(10), "9000000000000000000");
      } catch (err) {
        console.log(err);
      }
    });

    it('finalize auction with correct name', async () => {
      try {
        let portalNetworkToken = await PortalNetworkToken.deployed();
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'welcome';
        const protocol = 'etc';

        sleep.sleep(10);

        const entries2 = await universalRegistrar.entries.call(name, protocol);
        //console.log(new BN(entries2[0], 16).toString(10));
        //console.log(new BN(entries2[3], 16).toString(10), ((new Date()).getTime() / 1000));

        const finalizeAuction1 = await universalRegistrar.finalizeAuction(name, protocol, {from: accounts[1]});
        assert.equal(finalizeAuction1.receipt.status, true);

        const prtAccrueAddress = await portalNetworkToken.prtAccrueAddr.call();
        const prtAccrueAddressBalanceAfter = await portalNetworkToken.balanceOf.call(prtAccrueAddress);
        const bidderBalanceAfter = await portalNetworkToken.balanceOf.call(accounts[1]);
        assert.equal(new BN(bidderBalanceAfter, 16).toString(10), "4000000000000000000");
        assert.equal(new BN(prtAccrueAddressBalanceAfter, 16).toString(10), "1000000000000000000");
      } catch (err) {
        console.log(err);
      }
    });

    it('finalize auction with minimum bidding price', async () => {
      try {
        let portalNetworkToken = await PortalNetworkToken.deployed();
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'minimum';
        const protocol = 'etc';

        const entries3 = await universalRegistrar.entries.call(name, protocol);
        
        const finalizeAuction2 = await universalRegistrar.finalizeAuction(name, protocol, {from: accounts[3]});
        assert.equal(finalizeAuction2.receipt.status, true);

        const prtAccrueAddress = await portalNetworkToken.prtAccrueAddr.call();
        const prtAccrueAddressBalanceAfter = await portalNetworkToken.balanceOf.call(prtAccrueAddress);
        const bidderBalanceAfter = await portalNetworkToken.balanceOf.call(accounts[3]);
        assert.equal(new BN(bidderBalanceAfter, 16).toString(10), "9000000000000000000");
        assert.equal(new BN(prtAccrueAddressBalanceAfter, 16).toString(10), "2000000000000000000");
      } catch (err) {
        console.log(err);
      }
    });

    it('transfer domain ownership', async () => {
      try {
        let universalRegistry = await UniversalRegistry.deployed();
        let universalRegistrar = await UniversalRegistrar.deployed();
        const name = 'welcome';
        const protocol = 'etc';

        const registrant1 = await universalRegistry.registrant(name + "." + protocol);
        assert.equal(registrant1, accounts[1]);

        const transfer1 = await universalRegistrar.transfer(name, protocol, accounts[2], {from: accounts[1]});
        assert.equal(transfer1.receipt.status, true);

        const entries = await universalRegistrar.entries(name, protocol);
        assert.equal(entries[5], accounts[2], 'transfer is\'t correct');

        const registrant2 = await universalRegistry.registrant(name + "." + protocol);
        assert.equal(registrant2, accounts[2]);
      } catch (err) {
        console.log(err);
      }
    });
  })
})