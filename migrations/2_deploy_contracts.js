const TestAdashe = artifacts.require("./TestAdashe.sol");

module.exports = function(deployer) {
  deployer.deploy(TestAdashe);
};
