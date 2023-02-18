const windao = artifacts.require("WinDAO")
const box = artifacts.require("Box")

module.exports = async (deployer, network, accounts) => {
  return
  if (network == "production" || network === "bsc_testnet") {
    return
  }
  await deployer.deploy(box)
  const boxInstance = await box.deployed()
  const windaoInstance = await windao.deployed()
  const tx_transfer = await boxInstance.transferOwnership(
    windaoInstance.address
  )
  console.log(`Successfully transferOwnerShip at ${tx_transfer.tx}`)
}
