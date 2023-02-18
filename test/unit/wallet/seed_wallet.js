const SeedWallet = artifacts.require("SeedWallet")
const BUSD = artifacts.require("BUSD")
const WDA = artifacts.require("WDA")

const { expect } = require("chai")
const { time } = require("@openzeppelin/test-helpers")
const { web3, BN } = require("@openzeppelin/test-helpers/src/setup")
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
/**
 * Seedround: giá 0.00068$ BUSD 1 WDA
    Min buy 1000000 WDA
    Max buy 10000000 WDA 
    supply 20.000.000
 
 * 
 */

/**
 * locking: 2hours
 * vesting period: 1 hours
 * tge 10%
 */

contract("SeedWallet", async (accounts) => {
  let owner
  let user
  let busd
  let wda
  let timelockwallet
  let _startAt
  let _firstLockingTime
  let _tge
  let _totalVestingPeriod
  let _vestingPeriod
  let _totalBalances
  let _cost
  let _min
  let _max

  before("should set up before each test", async () => {
    owner = accounts[0]
    user = accounts[1]
    busd = await BUSD.deployed()
    wda = await WDA.deployed()
    timelockwallet = await SeedWallet.deployed()
    _startAt = await time.latest()
    _endAt = _startAt.add(time.duration.days(30))
    _firstLockingTime = 6 * time.duration.days(30)
    _tge = 10
    _totalVestingPeriod = 9
    _vestingPeriod = time.duration.days(30)
    _totalBalances = await web3.utils.toWei("20000000")
    _cost = await web3.utils.toWei("0.00068")
    _min = await web3.utils.toWei("1000000")
    _max = await web3.utils.toWei("10000000")
    await timelockwallet.initialize(
      _startAt,
      _firstLockingTime,
      _tge,
      _vestingPeriod,
      _totalVestingPeriod,
      _totalBalances,
      _cost,
      _min,
      _max
    )
    await timelockwallet.setWhiteList([owner, user])
    await wda.transfer(timelockwallet.address, _totalBalances)
    await busd.transfer(user, _max)
  })

  it("should assert true", async function () {
    // console.log("startAt:" + _startAt)
    // console.log("firstTimeLock:" + _firstLockingTime)
    // console.log("_tge:" + _tge)
    // console.log("vestingPeriod" + _vestingPeriod * 2)
    // console.log("_totalVestingPeriod:" + _totalVestingPeriod)
    console.log("_totalBalances:" + _totalBalances)
    console.log("_cost:" + _cost)
    console.log(_min)
    console.log(_max)
    return assert.isTrue(true)
  })

  xit("should active the timelock wallet", async () => {
    const startAt = await timelockwallet._startAt()
    const balance = await wda.balanceOf(timelockwallet.address)
    expect(startAt.toString()).to.be.eq(_startAt.toString())
    expect(balance.toString()).to.be.eq(_totalBalances.toString())
    expect(startAt.toString()).to.be.not.eq("0")
  })

  xit("should claim the tge", async () => {
    const amountToEther = await web3.utils.fromWei(_max)
    const amountToNumber = parseInt(amountToEther.toString())
    const totalTGE = (amountToNumber * _tge) / 100
    const totalBusd = amountToNumber * 0.0068
    const totalBusdToWei = await web3.utils.toWei(totalBusd.toString())
    await busd.approve(timelockwallet.address, totalBusdToWei, { from: user })
    await timelockwallet.buy(_max, { from: user })
    await timelockwallet.claimTGE({ from: user })
    const balance = await wda.balanceOf(user)
    const balanceToEther = await web3.utils.fromWei(balance)
    expect(balanceToEther.toString()).to.be.equal(totalTGE.toString())
  })

  xit("should claim the vesting", async () => {
    await time.increase(7 * _vestingPeriod)
    let amountToEther = await web3.utils.fromWei(_max)
    let amountToNumber = parseInt(amountToEther.toString())
    let totalVestingPerMonth =
      (amountToNumber * ((100 - _tge) / 100)) / _totalVestingPeriod
    let balance = await wda.balanceOf(user)
    let balanceToEther = await web3.utils.fromWei(balance)
    let balanceToNumber = parseInt(balanceToEther.toString())
    let totalBalance = totalVestingPerMonth + balanceToNumber
    await timelockwallet.vesting({ from: user })
    balance = await wda.balanceOf(user)
    balanceToEther = await web3.utils.fromWei(balance)
    expect(balanceToEther.toString()).to.be.eq(totalBalance.toString())
  })

  xit("should sold out", async () => {
    const amountToEther = await web3.utils.fromWei(_max)
    const amountToNumber = parseInt(amountToEther.toString())
    const totalBusd = amountToNumber * 0.0068
    const totalBusdToWei = await web3.utils.toWei(totalBusd.toString())
    await busd.approve(timelockwallet.address, totalBusdToWei)
    await timelockwallet.buy(_max)
    await timelockwallet.claimTGE()
    const soldOut = await timelockwallet._soldOut()
    expect(soldOut).to.be.eq(true)
  })
})
