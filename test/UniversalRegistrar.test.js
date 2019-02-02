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
  })
})