// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BUSD is ERC20 {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply
    ) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply * 10**decimals());
    }

    function mint() external {
        _mint(msg.sender, 10000 * 10**18);
    }
}
