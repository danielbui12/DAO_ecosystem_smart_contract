const Migrations = artifacts.require("Migrations")

module.exports = function(deployer, network) {
  if (network == "production" || network === "bsc_testnet") {
    return
  }
  deployer.deploy(Migrations)
}
