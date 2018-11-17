const ProtocolRegex = artifacts.require('ProtocolRegex.sol');

contract('Protocol Regex', function () {
  describe('contract testing', async () => {
    it('check protocol', async () => {
        try {
            let protocolRegex = await ProtocolRegex.deployed();

            assert.equal(await protocolRegex.matches('ae'), true, 'protocol isn\'t correct');
            assert.equal(await protocolRegex.matches('x'), false, 'protocol isn\'t correct');
        } catch (err) {
            console.log(err);
        }
    })
  })
})