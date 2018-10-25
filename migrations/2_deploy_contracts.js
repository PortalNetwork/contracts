var PortalNetworkToken = artifacts.require("./PortalNetworkToken.sol");

module.exports = async (deployer) => {
  deployer.deploy(PortalNetworkToken);
};
