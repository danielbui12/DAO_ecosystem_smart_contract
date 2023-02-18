const windao = artifacts.require("WinDAO")
const crownNFT = artifacts.require("CrownNFT")

module.exports = async (deployer) => {
  const instance = await crownNFT.deployed()
  await deployer.deploy(windao, instance.address)
  const windaoInstance = await windao.deployed()
  console.log(`Sucessfully deploy windao at ${windaoInstance.address}`)
}
