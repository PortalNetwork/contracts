const UniversalRegistry = artifacts.require('UniversalRegistry.sol');
const UniversalRegistrar = artifacts.require('UniversalRegistrar.sol');

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
        await universalRegistrar.setRegistryStartDate('etc', now, {from: accounts[0]});
        let allowedTime = await universalRegistrar.getAllowedTime('etc');
        assert.equal(allowedTime, now, 'allowedTime isn\'t correct');

        let isAllowed = await universalRegistrar.isAllowed('etc', new Date().getTime());
        assert.equal(isAllowed, true, 'isAllowed isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    });

  })
})