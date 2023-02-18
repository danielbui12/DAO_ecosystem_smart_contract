const windao = artifacts.require("WinDAO")
const crownNFT = artifacts.require("CrownNFT")
const box = artifacts.require("Box")

const { time } = require("@openzeppelin/test-helpers")
const { expect } = require("chai")

const ProposalState = {
  Active: 0,
  Defeated: 1,
  Succeeded: 2,
  Queued: 3,
  Expired: 4,
  Executed: 5,
}

contract("WinDAO", async (accounts) => {
  let crownNftInstance
  let windaoInstance
  let owner
  let user
  let votingPeriod = 1200
  before("should set up before each test", async () => {
    owner = accounts[0]
    user = accounts[1]
    crownNftInstance = await crownNFT.new("CROWNNFT", "CRN", "")
    console.log(`CrownNFT is deployed at ${crownNftInstance.address}`)
    windaoInstance = await windao.new(crownNftInstance.address)
    console.log(`windaoNFT is deployed at ${windaoInstance.address}`)
    await crownNftInstance.setValidTarget(owner, true)
    await crownNftInstance.setValidTarget(user, true)
    await crownNftInstance.mintValidTarget(30)
    await crownNftInstance.mintValidTarget(20, { from: user })
    console.log(`Succesfully! Minted 50 crowns for user and owner `)
    await crownNftInstance.delegate(owner)
    await crownNftInstance.delegate(user, { from: user })
    console.log(`Succesfully! Delegate 50 crowns for user and owner `)
  })
  it("should deployed success fully", async () => {
    await crownNFT.new("CROWNNFT", "CRN", "")
    await windao.new(crownNftInstance.address)
    return assert.isTrue(true)
  })
  it("should getVotes successfully", async () => {
    const ownerVotes = await crownNftInstance.getVotes(owner)
    const userVotes = await crownNftInstance.getVotes(user)
    expect(ownerVotes.toString()).to.be.eq("30")
    expect(userVotes.toString()).to.be.eq("20")
  })
})
