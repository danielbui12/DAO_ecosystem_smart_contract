const LuckyTicketWDA = artifacts.require("LuckyTicketWDA")
const daoTreasury = artifacts.require("DaoTreasury")
const wdaToken = artifacts.require("WDA")
module.exports = async (deployer) => {
  const wdaInstance = await wdaToken.deployed()
  await deployer.deploy(LuckyTicketWDA, wdaInstance.address)
  const daoTreasuryInstance = await daoTreasury.deployed()
  const LuckyTicketWDAContract = await LuckyTicketWDA.deployed()
  await LuckyTicketWDAContract.initialize()
  await LuckyTicketWDAContract.setDAOTreasuryWallet(daoTreasuryInstance.address)
  await LuckyTicketWDAContract.setValidTarget(
    "0xEc43e3f7999e965d2cEe50B166C58229A4717FC6",
    true
  )
}
