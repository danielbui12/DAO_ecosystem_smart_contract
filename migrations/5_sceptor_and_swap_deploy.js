const crownNFT = artifacts.require("CrownNFT")
const scepterNFT = artifacts.require("ScepterNFT")
const swapScepter = artifacts.require("SwapScepter")

module.exports = async (deployer) => {
  await deployer.deploy(scepterNFT)
  const scepter = await scepterNFT.deployed()
  const crown = await crownNFT.deployed()
  await deployer.deploy(swapScepter, crown.address, scepter.address)
  const swap = await swapScepter.deployed()
  await crown.setValidTarget(swap.address, true)
}
