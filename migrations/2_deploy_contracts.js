var PortalNetworkToken = artifacts.require("./PortalNetworkToken.sol");
var NameRegex = artifacts.require("./NameRegex.sol");
var ProtocolRegex = artifacts.require("./ProtocolRegex.sol");
var UniversalRegistry = artifacts.require("./UniversalRegistry.sol");
var UniversalRegistrar = artifacts.require("./UniversalRegistrar.sol");

module.exports = function (deployer) {
  // Deploy Universal Registry 
  // Deploy Universal Registrar 
  deployer.deploy(NameRegex).then(function(nameRegex) {
    console.log('NameRegex address \t\t', nameRegex.address);
    return deployer.deploy(ProtocolRegex);
  }).then(function(protocolRegex) {
    console.log('ProtocolRegex address \t\t', protocolRegex.address);
    return deployer.deploy(UniversalRegistry);
  }).then(function(universalRegistry) {
    console.log('UniversalRegistry address \t', universalRegistry.address);
    return deployer.deploy(UniversalRegistrar, universalRegistry.address);
  }).then(function(universalRegistrar) {
    console.log('UniversalRegistrar address \t', universalRegistrar.address);
    return deployer.deploy(PortalNetworkToken, '0x000000000000000000000000000000000000dead', universalRegistrar.address, '0x00000000000000000000000000000000deaddead');
  }).then(function(portalNetworkToken) {
    console.log('PortalNetworkToken address \t', portalNetworkToken.address);
  });
};
