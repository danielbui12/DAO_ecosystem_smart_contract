const market = artifacts.require("Market")
const daotreasury = artifacts.require("DAOTreasury")
const crown = artifacts.require("CrownNFT")
const scepterNFT = artifacts.require("ScepterNFT")

module.exports = async (deployer) => {
  await deployer.deploy(market)
  const marketInstance = await market.deployed()
  const daotreasuryInstance = await daotreasury.deployed()
  const crownInstance = await crown.deployed()
  const scepter = await scepterNFT.deployed()
  await crownInstance.setValidTarget(marketInstance.address, true)
  await marketInstance.setCrownContract(crownInstance.address)
  await marketInstance.setScepterContract(scepter.address)
  await marketInstance.setDAOTreasuryWallet(daotreasuryInstance.address)
  console.log(
    `Successfully deploy Market contract`
  )
}
