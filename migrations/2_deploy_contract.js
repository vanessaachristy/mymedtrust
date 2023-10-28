
var MainContract = artifacts.require("MainContract");
var RecordContract = artifacts.require("RecordContract");

module.exports = function (deployer) {
    deployer.deploy(MainContract);
    deployer.deploy(RecordContract);
};
