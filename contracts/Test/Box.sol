// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable{
    uint256 private _val;

    function setVal(uint256 val_)external onlyOwner {
        _val = val_;
    }
    function getVal() external view returns(uint256) {
        return _val;
    }
}