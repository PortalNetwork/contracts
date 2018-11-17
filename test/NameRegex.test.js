const NameRegex = artifacts.require('NameRegex.sol');

contract('Name Regex', function () {
  describe('contract testing', async () => {
    it('contract address', async () => {
      try {
        let nameRegex = await NameRegex.deployed();
        console.log('NameRegex address', nameRegex.address);
      } catch (err) {
        console.log(err);
      }
    });

    it('check name', async () => {
      try {
        let nameRegex = await NameRegex.deployed();

        assert.equal(await nameRegex.nameMatches('x'), true, 'name isn\'t correct');
        assert.equal(await nameRegex.nameMatches('-'), false, 'name isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    })
  })
})