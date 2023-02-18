require("@openzeppelin/test-helpers/configure")({
  provider: "http://127.0.0.1:8546",
})
const windao = artifacts.require("WinDAO")
const crownNFT = artifacts.require("CrownNFT")
const daoTresury = artifacts.require("DAOTresury")
const wda = artifacts.require("WDA")
const auction = artifacts.require("AuctionCrown")
const market = artifacts.require("Market")

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
  let daoTresuryInstance
  let auctionInstance
  let owner
  let user
  let wdaInstance
  let votingPeriod = 300
  let votingFinalPeriod = 600
  let proposalId
  before("should set up before each test", async () => {
    owner = accounts[0]
    user = accounts[1]
    crownNftInstance = await crownNFT.new("CROWNNFT", "CRN", "")
    console.log(`CrownNFT is deployed at ${crownNftInstance.address}`)
    wdaInstance = await wda.new("WDA", "WDA", 1000000000)
    console.log(`WDA is deployed at ${wdaInstance.address}`)
    windaoInstance = await windao.new(crownNftInstance.address)
    console.log(`windaoNFT is deployed at ${windaoInstance.address}`)
    daoTresuryInstance = await daoTresury.new(wdaInstance.address)
    console.log(
      `Successfully!Dao tresury is deployed at ${daoTresuryInstance.address}`
    )
    // Set up auction with
    auctionInstance = await auction.new(
      wdaInstance.address,
      daoTresuryInstance.address,
      windaoInstance.address
    )
    console.log(
      `auctionInstance is deployed at ${auctionInstance.address} with user address ${user}`
    )
    await crownNftInstance.setValidTarget(owner, true)
    await crownNftInstance.setValidTarget(user, true)
    await crownNftInstance.setValidTarget(auctionInstance.address, true)
    await crownNftInstance.mintValidTarget(30)
    await crownNftInstance.mintValidTarget(20, { from: user })
    console.log(`Succesfully! Minted 50 crowns for user and owner `)
    await crownNftInstance.delegate(owner)
    await crownNftInstance.delegate(user, { from: user })
    console.log(`Succesfully! Delegate 50 crowns for user and owner `)
  })
  describe("#DAOTresury", () => {
    it("should create successfully proposal", async () => {
      const tx = await daoTresuryInstance.transferOwnership(
        windaoInstance.address
      )
      await wdaInstance.transfer(
        daoTresuryInstance.address,
        web3.utils.toWei("1000000")
      )
      console.log(`Succesfully! TransferOwnership ${tx}`)
      const description = `{"title":"Test DAOTresury","desscription":[{"header":"Send 100 wda to address ","content":"Test function"}]}`
      const descriptionHash = await web3.utils.sha3(
        web3.utils.asciiToHex(description)
      )
      const calldatas = await web3.eth.abi.encodeFunctionCall(
        {
          name: "sendWDA",
          type: "function",
          inputs: [
            {
              type: "address",
              name: "to",
            },
            {
              type: "uint256",
              name: "amount",
            },
          ],
        },
        [user, web3.utils.toWei("100")]
      )
      proposalId = await windaoInstance.hashProposal(
        daoTresuryInstance.address,
        0,
        calldatas,
        descriptionHash
      )
      await windaoInstance.propose(
        daoTresuryInstance.address,
        0,
        calldatas,
        description
      )
      console.log(`Successfully!Propose at ${proposalId}`)
      const state = await windaoInstance.state(proposalId)
      expect(state.toString()).to.be.eq(ProposalState.Active.toString())
    })
    it("should cast vote and change queue state", async () => {
      await windaoInstance.castVote(proposalId, 1)
      const currentBlock = await time.latestBlock()
      await time.advanceBlockTo(parseInt(currentBlock) + votingPeriod)
      const state = await windaoInstance.state(proposalId)
      expect(state.toString()).to.be.eq(ProposalState.Queued.toString())
    })
    it("should set final proposal and execute", async () => {
      const description = `{"title":"Test DAOTresury","desscription":[{"header":"Send 100 wda to address ","content":"Test function"}]}`
      const descriptionHash = await web3.utils.sha3(
        web3.utils.asciiToHex(description)
      )
      const calldatas = await web3.eth.abi.encodeFunctionCall(
        {
          name: "sendWDA",
          type: "function",
          inputs: [
            {
              name: "to",
              type: "address",
            },
            {
              name: "amount",
              type: "uint256",
            },
          ],
        },
        [user, web3.utils.toWei("100")]
      )
      await windaoInstance.setFirstFinalProposal()
      let state = await windaoInstance.state(proposalId)
      expect(state.toString()).to.be.eq(ProposalState.Active.toString())
      await windaoInstance.castVote(proposalId, 1)
      await windaoInstance.castVote(proposalId, 1, { from: user })
      const currentBlock = await time.latestBlock()
      await time.advanceBlockTo(parseInt(currentBlock) + votingFinalPeriod)
      state = await windaoInstance.state(proposalId)
      expect(state.toString()).to.be.eq(ProposalState.Succeeded.toString())
      await windaoInstance.execute(
        daoTresuryInstance.address,
        0,
        calldatas,
        descriptionHash
      )
      state = await windaoInstance.state(proposalId)
      const balanceWDAOfUser = await wdaInstance.balanceOf(user)
      expect(state.toString()).to.be.eq(ProposalState.Executed.toString())
      expect(balanceWDAOfUser.toString()).to.be.eq(web3.utils.toWei("100"))
    })
  })
  describe("#Auction", () => {
    xit("should initial successfully", async () => {
      await auctionInstance.initialize(crownNftInstance.address)
      await auctionInstance.setDurationTime("600")
      const duration = await auctionInstance.durationTime()

      await wdaInstance.transfer(user, web3.utils.toWei("100000"))
      expect(duration.toString()).to.be.eq("600")
    })
    xit("should open auction", async () => {
      await auctionInstance.openAuction()
      const nftId = await auctionInstance.lastNftId()
      expect(nftId.toString()).not.to.be.eq("0")
    })
    xit("should place bid", async () => {
      // Arrange
      const nftId = await auctionInstance.lastNftId()
      // act
      await wdaInstance.approve(
        auctionInstance.address,
        web3.utils.toWei("4000")
      )
      await auctionInstance.placeBid(web3.utils.toWei("4000"), {
        value: web3.utils.toWei("0.00001"),
      })
      // Assertion
      const auctionInfor = await auctionInstance.auctions(nftId)
      const highestBidder = auctionInfor.highestBidder
      expect(highestBidder).to.be.eq(owner)
    })
    xit("should place bid with higher price", async () => {
      // Arrange
      const nftId = await auctionInstance.lastNftId()
      const ownerBlance = await wdaInstance.balanceOf(owner)
      console.log(web3.utils.fromWei(ownerBlance))
      // Act
      await wdaInstance.approve(
        auctionInstance.address,
        web3.utils.toWei("4100"),
        { from: user }
      )
      tx = await auctionInstance.placeBid(web3.utils.toWei("4100"), {
        from: user,
        value: web3.utils.toWei("0.00001"),
      })
      // Assertion
      const auctionInfor = await auctionInstance.auctions(nftId)
      const highestBidder = auctionInfor.highestBidder
      const currentBalance = await wdaInstance.balanceOf(owner)
      expect(highestBidder).to.be.eq(user)
      expect(web3.utils.fromWei(ownerBlance)).not.to.be.eq(
        web3.utils.fromWei(currentBalance)
      )
    })
    xit("should transfer BNB to windao and treasury", async () => {
      // Arrange
      let windaoBNB
      let daoTresuryBalance
      // Act
      await time.increase(time.duration.minutes(10))
      windaoBNB = await web3.eth.getBalance(windaoInstance.address)
      console.log(windaoBNB)
      await auctionInstance.closeAuction()
      windaoBNB = await web3.eth.getBalance(windaoInstance.address)
      daoTresuryBalance = await wdaInstance.balanceOf(
        daoTresuryInstance.address
      )
      const nftId = await auctionInstance.lastNftId()
      const ownerOfNft = await crownNftInstance.ownerOf(nftId)

      // Assertion
      expect(web3.utils.fromWei(daoTresuryBalance)).to.be.eq("1004100")
      expect(ownerOfNft).to.be.eq(user)
      expect(web3.utils.fromWei(windaoBNB)).to.be.eq("0.00001")
    })
    xit("should reopen auction", async () => {
      // Arrange
      const nftId = await auctionInstance.lastNftId()
      // Act
      await auctionInstance.openAuction()
      const newNftId = await auctionInstance.lastNftId()
      // Assertion
      expect(nftId).not.to.be.eq(newNftId)
    })
  })
  describe("#Market", () => {
    it()
  })
})
