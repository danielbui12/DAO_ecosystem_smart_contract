const crown = artifacts.require("CrownNFT")
contract("CrownNFT", () => {
  let word
  let crownInstance
  before("set up for word", async () => {
    crownInstance = await crown.deployed()
    console.log(`deployed crown at ${crownInstance.address}`)
  })
  describe("#printHello", async () => {
    it("should get traits hello", async () => {
      const crown6 = await crownInstance.getTraits(6)
      const totalSupply = await crownInstance.totalSupply()
      console.log(crown6)
      console.log(totalSupply.toString())
    })
  })
})
