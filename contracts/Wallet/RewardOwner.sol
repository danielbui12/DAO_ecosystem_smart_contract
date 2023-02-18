// SPDX-License-Identifier:MIT

pragma solidity 0.8.11;

import "../DAO/IDAO.sol";
import "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract RewardOwner {
    IDAO private immutable _dao;
    IVotes private immutable _token;
    // Balance of each proposalId
    mapping(uint256 => uint256) private balances;
    // mapping from proposalId, address to isClaim
    mapping(uint256 => mapping(address => bool)) private proposalIdToIsClaim; 
    event UpdateBalance(uint256 indexed proposalId, uint256 value);
   
    constructor(IDAO dao_,IVotes token_){
        _dao = dao_;
        _token = token_;
    }

    receive() external payable{
    }

    function updateBalance(uint256 proposalId) external payable{
        require(msg.value > 0, 'RewardOwner:msg.value should larger than 0');
        uint256 snapShot = _dao.proposalSnapshot(proposalId);
        require(snapShot > 0, 'RewardOwner: Proposal is not exist!');
        balances[proposalId] += msg.value;
        emit UpdateBalance(proposalId, msg.value);
    }

    function claimBNB(uint256 proposalId) external{
        require(balances[proposalId] > 0,"RewardOwner: Not update balance yet");
        require(!proposalIdToIsClaim[proposalId][msg.sender],"RewardOwner: Already Claimed");
        uint256 snapShot = _dao.proposalSnapshot(proposalId);
        require(snapShot > 0, 'RewardOwner: Proposal is not exist!');
        uint256 totalSupply = _token.getPastTotalSupply(snapShot);
        uint256 votes = _token.getPastVotes(msg.sender,snapShot);
        require(votes > 0, "RewardOwner: Not a Crown Holder");
        uint256 addressToReward = (votes * 100 / totalSupply) * balances[proposalId];
        proposalIdToIsClaim[proposalId][msg.sender] = true;
        (bool success,) = payable(msg.sender).call{value:addressToReward}("");
        require(success,"RewardOwner: Transfer failed");
    }

    function getProposalIdToBalances(uint256 proposalId) external view returns(uint256){
        return balances[proposalId];
    }


    


}