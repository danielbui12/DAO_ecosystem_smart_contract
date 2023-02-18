// SPDX-License-Identifier:MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// solhint-disable-next-line
contract DAOTreasury is Ownable{
 
    IERC20 private _wda;
    uint256 private balances;

    constructor(IERC20 wda_){
        _wda = wda_;
    }

    fallback() payable external{
         deposit();
    }

    function deposit() payable public{
        balances+=msg.value;
    }

    function getBalance() external view returns(uint256){
        return balances;
    }

    function sendWDA(address to, uint256 amount) onlyOwner external{
        uint256 balanceWDA = _wda.balanceOf(address(this));
        require(amount <= balanceWDA * 10 / 100, "DAOTresury: Only transfer less than 10 percentage");
        bool success = _wda.transfer(to, amount);
        require(success,"DAOTresury:Transfer failed");
    }

    function transferBNB(address payable to, uint256 amount) onlyOwner external{
        require(balances > 0, "DAOTreasury:Insufficent BNB");
        (bool success,)= to.call{value:amount}("");
        require(success,"Transaction Failed");
    }

   
}