const Auction = artifacts.require("AuctionCrown")
const wda = artifacts.require("WDA")
const daoTresury = artifacts.require("DaoTreasury")
const windao = artifacts.require("WinDAO")
const crownNFT = artifacts.require("CrownNFT")

module.exports = async (deployer) => {
  const wdaInstance = await wda.deployed()
  const daoTresuryInstance = await daoTresury.deployed()
  await deployer.deploy(
    Auction,
    wdaInstance.address,
    daoTresuryInstance.address
  )
  const auctionInstance = await Auction.deployed()
  const crown = await crownNFT.deployed()
  await crown.setValidTarget(auctionInstance.address, true)
  // if (network == "production") {
  //   return
  // }
  // if (network == "bsc_testnet") {
  //   const daoTresuryInstance = await daoTresury.deployed()
  //   // console.log(account[0])
  //   // console.log(daoTresuryInstance.address)
  //   await deployer.deploy(
  //     Auction,
  //     "0x3b979adf6Cd72Ae8ED420E7a9ba74865a7F64B82",
  //     daoTresuryInstance.address
  //   )
  // } else if (network == "development" || network == "production") {
  //   const wdaInstance = await wda.deployed()
  //   await deployer.deploy(Auction, wdaInstance.address, account[0])
  // }
  // console.log(`Successfully! Auction deployed at ${auctionInstance.address}`)
}
