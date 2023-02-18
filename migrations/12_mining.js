const Mining = artifacts.require("Mining")
const wda = artifacts.require("WDA")
const crown = artifacts.require("CrownNFT")
const windao = artifacts.require("WinDAO")

module.exports = async (deployer) => {
  const crownInstance = await crown.deployed()
  const windaoInstance = await windao.deployed()
  const wdaInstance = await wda.deployed()
  await deployer.deploy(Mining, wdaInstance.address)
  const MiningContract = await Mining.deployed()
  await MiningContract.initialize()
  await MiningContract.setCrownContract(crownInstance.address)
  await MiningContract.setWinDAOAddress(windaoInstance.address)
  await crownInstance.setValidTarget(MiningContract.address, true)
}
