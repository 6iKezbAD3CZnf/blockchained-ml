const BlockchainedML = artifacts.require("BlockchainedML");

module.exports = function(deployer) {
    deployer.deploy(BlockchainedML);
};
