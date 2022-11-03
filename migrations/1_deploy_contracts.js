const BlockchainedLearning = artifacts.require("BlockchainedLearning");

module.exports = function(deployer) {
    deployer.deploy(BlockchainedLearning);
};
