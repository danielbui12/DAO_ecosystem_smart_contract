const crownNFT = artifacts.require("CrownNFT")
const wda = artifacts.require("WDA")

module.exports = async (deployer) => {
  await deployer.deploy(
    crownNFT,
    "CrownNFT",
    "CROWN",
    "https://nft-staging.wdadao.tk/crowns/"
  )
  await deployer.deploy(wda, "WinDAO", "WDA", 1000000000)
}
