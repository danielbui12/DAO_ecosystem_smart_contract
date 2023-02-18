const Staking = artifacts.require("Staking")
const wda = artifacts.require("WDA")
const crown = artifacts.require("CrownNFT")
const windao = artifacts.require("WinDAO")
const DAOTreasury = artifacts.require("DAOTreasury")

module.exports = async (deployer) => {
  const crownInstance = await crown.deployed()
  const windaoInstance = await windao.deployed()
  const wdaInstance = await wda.deployed()
  const daoTreasuryInstance = await DAOTreasury.deployed()
  await deployer.deploy(Staking, wdaInstance.address)
  const StakingContract = await Staking.deployed()
  await StakingContract.initialize()
  await StakingContract.setCrownContract(crownInstance.address)
  await StakingContract.setDaoTreasuryWallet(daoTreasuryInstance.address)
  await StakingContract.setWinDAOAddress(windaoInstance.address)

  console.log(`Sucessfully init the Staking`)
}
