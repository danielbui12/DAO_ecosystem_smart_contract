const rewardOwner = artifacts.require("RewardOwner")
const winDAO = artifacts.require("WinDAO")
const crown = artifacts.require("CrownNFT")

module.exports = async (deployer, network) => {
  // if (network == "production" || network === "bsc_testnet") {
  //   return
  // }
  return
  const winDAOInstance = await winDAO.deployed()
  const crownInstance = await crown.deployed()
  await deployer.deploy(
    rewardOwner,
    winDAOInstance.address,
    crownInstance.address
  )
  const rewardOwnerInstance = await rewardOwner.deployed()
  console.log(
    `Successfully! RewardOwner is deployed at ${rewardOwnerInstance.address}`
  )
}
