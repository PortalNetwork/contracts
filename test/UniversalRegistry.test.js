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
  });
});