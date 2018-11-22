var PortalNetworkToken = artifacts.require("./PortalNetworkToken.sol");

module.exports = function (deployer) {
  deployer.deploy(PortalNetworkToken);
};
