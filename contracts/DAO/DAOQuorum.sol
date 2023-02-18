// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import './DAOVotes.sol';

abstract contract DAOQuorum is DAOVotes{
    
    uint256 private _numeratorIdea = 25;
    uint256 private _numeratorFinal = 40;

    function quorum(uint256 blockNumber, bool isFinal) public virtual override view returns(uint256){
        return token.getPastTotalSupply(blockNumber) * numerator(isFinal) / deminator();
    }
    
    function deminator() public pure returns(uint256){
        return 100;
    }
    
    function numerator(bool isFinal) public view returns(uint256){
        return isFinal ? _numeratorFinal : _numeratorIdea;
    }

}