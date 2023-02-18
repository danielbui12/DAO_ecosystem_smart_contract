const { expect } = require("chai")
contract("TEST", () => {
  let word
  before("set up for word", async () => {
    word = "Hello"
  })
  describe("#printHello", async () => {
    it("should equa hello", async () => {
      expect(word).to.be.eq("Hello")
    })
  })
})
