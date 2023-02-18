const daoTresury = artifacts.require("DAOTreasury")
const windao = artifacts.require("WinDAO")

module.exports = async (deployer, network) => {
  return
  // if (network == "production" || network === "bsc_testnet") {
  //   return
  // }
  // if (network == "development") {
  //   const daoTresuryInstance = await daoTresury.deployed()
  //   const windaoInstance = await windao.deployed()
  //   const wdaToWei = await web3.utils.toWei("100")
  //   console.log(wdaToWei)
  //   const daoSendWDA = await web3.eth.abi.encodeFunctionCall(
  //     {
  //       name: "sendWDA",
  //       type: "function",
  //       inputs: [
  //         {
  //           type: "address",
  //           name: "to",
  //         },
  //         {
  //           type: "uint256",
  //           name: "amount",
  //         },
  //       ],
  //     },
  //     ["0x8445F6f0349CA3B4B0aF400C3f373876E8A5EAE0", wdaToWei]
  //   )
  //   const descriptionHash = await web3.utils.sha3(
  //     web3.utils.asciiToHex(
  //       `{"title":"Test DAOTresury","desscription":[{"header":"Send 100 wda to address ","content":"Test function"}]}`
  //     )
  //   )
  //   const proprosal_hash = await windaoInstance.hashProposal(
  //     daoTresuryInstance.address,
  //     0,
  //     daoSendWDA,
  //     descriptionHash
  //   )
  //   await windaoInstance.propose(
  //     daoTresuryInstance.address,
  //     0,
  //     daoSendWDA,
  //     `{"title":"Test DAOTresury","desscription":[{"header":"Send 100 wda to address ","content":"Test function"}]}`
  //   )
  //   // await windaoInstance.castVote(proprosal_hash, 1)
  //   const state = await windaoInstance.state(proprosal_hash)
  //   console.log(state.toString())
  //   console.log(`Successfully propose at ${proprosal_hash}`)
  // }
}
