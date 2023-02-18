const LuckyTicketNFT = artifacts.require("LuckyTicketNFT")
const crownNFT = artifacts.require("CrownNFT")
const scepterNFT = artifacts.require("ScepterNFT")
const wdaToken = artifacts.require("WDA")

module.exports = async (deployer) => {
  const wda = await wdaToken.deployed()
  await deployer.deploy(LuckyTicketNFT, wda.address)
  const CrownLucky = await LuckyTicketNFT.deployed()
  const crown = await crownNFT.deployed()
  const scepter = await scepterNFT.deployed()
  await CrownLucky.setCrownAddress(crown.address)
  await CrownLucky.setScepterAddress(scepter.address)
  await crown.setValidTarget(CrownLucky.address, true)
  await scepter.setValidTarget(CrownLucky.address, true)
  await CrownLucky.setValidTarget(
    "0xEc43e3f7999e965d2cEe50B166C58229A4717FC6",
    true
  )

  await CrownLucky.setNewCrownBonus();

  console.log(`Sucessfully init the CrownLucky`)
}
