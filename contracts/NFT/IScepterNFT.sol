// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

import "@openzeppelin/contracts/interfaces/IERC1155.sol";

interface IScepterNFT is IERC1155{
     function burn(
        address account,
        uint256 id,
        uint256 value
    ) external; 
    
    function burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory values
    ) external;

    function mintValidTarget(uint256) external;

    function setValidTarget(address, bool) external;
}
