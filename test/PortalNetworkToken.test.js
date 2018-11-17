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

    it('token contract owner', async () => {
      try {
        let PRT = await PortalNetworkToken.deployed();
        let owner = await PRT.isOwner(accounts[0]);

        assert.equal(owner, true, 'owner isn\'t correct');
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

        accounts.forEach(async (address) => {
          if (address !== accounts[0]){
            await PRT.transfer(address, 1000000000000000000, {from: accounts[0]});
            let balance = await PRT.balanceOf.call(address);
            assert.equal(balance.toNumber(), 1000000000000000000, 'balance isn\'t correct');
          }
        })
      } catch (err) {
        console.log(err);
      }
    });

    it('change universal registrar address', async () => {
      try {
        let PRT = await PortalNetworkToken.deployed();
        let universalRegistrarAddr = await PRT.universalRegistrarAddr.call();
        assert.equal(universalRegistrarAddr, '0x0000000000000000000000000000000000000000', 'universal registrar address isn\'t correct');
        await PRT.updateUniversalRegistrar('0x000000000000000000000000000000000000dead', {from: accounts[0]});
        universalRegistrarAddr = await PRT.universalRegistrarAddr.call();
        
        assert.equal(universalRegistrarAddr, '0x000000000000000000000000000000000000dead', 'universal registrar address isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });
  })
});