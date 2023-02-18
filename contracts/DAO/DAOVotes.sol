// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import './DAO.sol';
import "@openzeppelin/contracts/governance/utils/IVotes.sol";
abstract contract DAOVotes is DAO {
    IVotes public immutable token;
    constructor (IVotes tokenAddress){
        token = tokenAddress;
    }

    function getVotes(address account, uint256 blockNumber)public view virtual override returns(uint256){
        return token.getPastVotes(account, blockNumber);
    }
}