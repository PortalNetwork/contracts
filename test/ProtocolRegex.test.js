const ProtocolRegex = artifacts.require('ProtocolRegex.sol');

contract('Protocol Regex', function () {
  describe('contract testing', async () => {
    it('contract address', async () => {
      try {
        let protocolRegex = await ProtocolRegex.deployed();
        console.log('ProtocolRegex address', protocolRegex.address);
      } catch (err) {
        console.log(err);
      }
    });
    
    // protocol has minimum 2 characters
    it('check protocol', async () => {
      try {
        let protocolRegex = await ProtocolRegex.deployed();

        assert.equal(await protocolRegex.protocolMatches('ae'), true, 'protocol isn\'t correct');
        assert.equal(await protocolRegex.protocolMatches('x'), false, 'protocol isn\'t correct');
      } catch (err) {
        console.log(err);
      }
    })
  })
})