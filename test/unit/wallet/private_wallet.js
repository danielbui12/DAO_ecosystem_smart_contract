const PrivateWallet = artifacts.require("PrivateWallet")
const BUSD = artifacts.require("BUSD")
const WDA = artifacts.require("WDA")

const { expect } = require("chai")
const { time, BN } = require("@openzeppelin/test-helpers")
const { web3 } = require("@openzeppelin/test-helpers/src/setup")
/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
/**
 *
E ơi , sửa hộ a giá - lượng bán Private thành
Private: giá  BUSD 1 WDA
Tổng bán : 80.000.000 WDA nhé

Phạm Quang Phúc, [3/22/2022 2:16 AM]
Seedround giá giữ nguyên. tổng bán: 20.000.000 WDA
 * Seedround: giá 0.00068$ BUSD 1 WDA
    Tổng bán : 20.000.000 WDA nhé
    Min buy 1000000 WDA
    Max buy 10000000 WDA
   Private: giá 0.0015$ BUSD 1 WDA
   Tổng bán : 80.000.000 WDA nhé
    Min 1000000 WDA
    Max 10000000 WDA
 *
 */

contract("PrivateWallet", async (accounts) => {
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
  let _min2
  let _max2

  before("should set up before each test", async () => {
    owner = accounts[0]
    user = accounts[1]
    busd = await BUSD.deployed()
    wda = await WDA.deployed()
    timelockwallet = await PrivateWallet.deployed()
    _startAt = await time.latest()
    _endAt = _startAt.add(time.duration.days(30))
    _firstLockingTime = time.duration.days(30)
    _tge = 20
    _totalVestingPeriod = 8
    _vestingPeriod = time.duration.days(30)
    _totalBalances = await web3.utils.toWei("80000000")
    _cost = await web3.utils.toWei("0.0015")
    _min = await web3.utils.toWei("1000000")
    _max = await web3.utils.toWei("10000000")
    _min2 = await web3.utils.toWei("2000000")
    _max2 = await web3.utils.toWei("5000000")
    await timelockwallet.initialize(
      _startAt,
      _firstLockingTime,
      _tge,
      2 * _vestingPeriod,
      _totalVestingPeriod,
      _totalBalances,
      _cost
    )
    await timelockwallet.setMinMax(_min, _max, _min2, _max2)
    await timelockwallet.setWhiteList1([user])
    await timelockwallet.setUserBalance(accounts[4], _min2)
    await wda.transfer(timelockwallet.address, _totalBalances)
    await busd.transfer(user, _max)
    await busd.transfer(accounts[3], _max)
  })

  it("should assert true", async function () {
    await PrivateWallet.deployed()
    return assert.isTrue(true)
  })

  it("should active the timelock wallet", async () => {
    const startAt = await timelockwallet._startAt()
    const balance = await wda.balanceOf(timelockwallet.address)
    expect(startAt.toString()).to.be.eq(_startAt.toString())
    expect(balance.toString()).to.be.eq(_totalBalances.toString())
    expect(startAt.toString()).to.be.not.eq("0")
  })

  it("should claim the tge", async () => {
    const tgeTime = _startAt.add(_firstLockingTime)
    await timelockwallet.setTgeTime(tgeTime)
    await time.increase(_firstLockingTime)
    const amount = _min
    const amountToEther = await web3.utils.fromWei(_min)
    const amountToNumber = parseInt(amountToEther.toString())
    const totalTGE = (amountToNumber * _tge) / 100
    const totalBusd = amountToNumber * 0.0068
    const totalBusdToWei = await web3.utils.toWei(totalBusd.toString())
    await busd.approve(timelockwallet.address, totalBusdToWei, { from: user })
    await timelockwallet.buy(amount, { from: user })
    await timelockwallet.claimTGE({ from: user })
    const balance = await wda.balanceOf(user)
    const balanceToEther = await web3.utils.fromWei(balance)
    expect(balanceToEther.toString()).to.be.equal(totalTGE.toString())
  })

  it("should claim TGE with whitelist2", async () => {
    const whitelist2 = accounts[3]
    await timelockwallet.setWhiteList2([whitelist2])
    await busd.approve(timelockwallet.address, _min2, { from: whitelist2 })
    await timelockwallet.buy(_min2, { from: whitelist2 })
    await timelockwallet.claimTGE({ from: whitelist2 })
    await timelockwallet.claimTGE({ from: accounts[4] })
    const balanceWDA = await wda.balanceOf(whitelist2)
    const balanceWDA2 = await wda.balanceOf(accounts[4])
    const _maxBN = new BN(_min2)
    const tgeAmount = _maxBN.mul(new BN(_tge.toString())).div(new BN("100"))
    expect(tgeAmount.toString()).to.be.eq(balanceWDA.toString())
    expect(tgeAmount.toString()).to.be.eq(balanceWDA2.toString())
  })

  xit("should claim TGE with whitelist3", async () => {
    const whitelist3 = accounts[2]
    await timelockwallet.setWhiteList3([whitelist3])
    await timelockwallet.buy(_max, { from: whitelist3 })
    await timelockwallet.claimTGE({ from: whitelist3 })

    const balanceWDA = await wda.balanceOf(whitelist3)
    const _maxBN = new BN(_max)
    const tgeAmount = _maxBN.mul(new BN(_tge.toString())).div(new BN("100"))
    expect(tgeAmount.toString()).to.be.eq(balanceWDA.toString())
  })

  it("should claim the vesting", async () => {
    await time.increase(3 * _vestingPeriod)
    let amountToEther = await web3.utils.fromWei(_min)
    let amountToNumber = parseInt(amountToEther.toString())
    let totalVestingPerMonth =
      (amountToNumber * ((100 - _tge) / 100)) / _totalVestingPeriod
    let balance = await wda.balanceOf(user)
    let balanceToEther = await web3.utils.fromWei(balance)
    let balanceToNumber = parseInt(balanceToEther.toString())
    let totalBalance = 2 * totalVestingPerMonth + balanceToNumber
    await timelockwallet.vesting({ from: user })
    balance = await wda.balanceOf(user)
    balanceToEther = await web3.utils.fromWei(balance)
    expect(balanceToEther.toString()).to.be.eq(totalBalance.toString())
  })
})
