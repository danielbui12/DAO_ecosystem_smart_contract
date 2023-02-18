require("@openzeppelin/test-helpers/configure")({
  provider: "http://127.0.0.1:8546",
})
const crown = artifacts.require("CrownNFT")
const { time } = require("@openzeppelin/test-helpers")
const { expect } = require("chai")

contract("CrownNFT", async (accounts) => {
  let crownInstance
  let user1
  let owner
  let user2
  before("set up before test", async () => {
    owner = accounts[0]
    user1 = accounts[1]
    user2 = accounts[2]
    crownInstance = await crown.new(
      "CrownNFT",
      "CROWN",
      "https://nft.wdadao.tk/crowns/"
    )
  })
  it("should transfer the token", async () => {
    await crownInstance.setValidTarget(owner, true)
    await crownInstance.mintValidTarget(20)
    await crownInstance.safeTransferFrom(owner, user1, 0, "")
    await crownInstance.safeTransferFrom(owner, user1, 1, "")
    await crownInstance.safeTransferFrom(owner, user1, 2, "")
    const balanceUser1 = await crownInstance.balanceOf(user1)
    expect(balanceUser1.toString()).to.be.eq("3")
  })
})
