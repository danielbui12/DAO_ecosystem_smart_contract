const DAOTreasury = artifacts.require("DAOTreasury")
const windao = artifacts.require("WinDAO")
const wda = artifacts.require("WDA")

module.exports = async (deployer) => {
  const wdaInstance = await wda.deployed()
  await deployer.deploy(DAOTreasury, wdaInstance.address)
  const treasury = await DAOTreasury.deployed()
  const windaoInstance = await windao.deployed()
  console.log(`Success deploy DAOTreasury at ${treasury.address}`)
  const tx_transfer = await treasury.transferOwnership(windaoInstance.address)
  console.log(`Success deploy transfer Ownership at ${tx_transfer.address}`)
}
