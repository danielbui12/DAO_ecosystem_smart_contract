// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

import "./DAO.sol";
import "./DAOCountVotes.sol";
import "./DAOQuorum.sol";
import "./DAOVotes.sol";

contract WinDAO is DAO, DAOCountVotes, DAOVotes, DAOQuorum {
    // Block number that cooldown for next propose
    uint256 public proposeCoolDown = (10*60)/3;

    mapping (address => uint256) private addressToBlockPropose;
    constructor(IVotes token_) DAO("WINDAO") DAOVotes(token_) {}

    // =============TEST ONLY================

    function setProposeCoolDown(uint256 blockNumber) external {
        proposeCoolDown = blockNumber;
    }

    // =============END OF TEST ONLY================

    function getBlockToPropose(address account) external view returns(uint256){
        return addressToBlockPropose[account];
    }

    function quorum(uint256 blockNumber, bool isFinal)
        public
        view
        override(IDAO, DAOQuorum)
        returns (uint256)
    {
        return super.quorum(blockNumber, isFinal);
    }

    function getVotes(address account, uint256 blockNumber)
        public
        view
        override(DAO, DAOVotes)
        returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    function proposalForRate(uint256 proposalId)
        public
        view
        override
        returns (uint256)
    {
        if (proposalId == 0) return 0;
        return
            (super.proposalForRate(proposalId) * 100) /
            token.getPastTotalSupply(proposalSnapshot(proposalId));
    }

    function state(uint256 proposalId)
        public
        view
        override(DAO)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }
    function propose(
        address targets,
        uint256 values,
        bytes memory calldatas,
        string memory description
    ) public override(DAO) returns (uint256) {
        require(
            token.getPastTotalSupply(block.number - 1) >= 50,
            "WinDAO:Insufficient total supply"
        );
        require(addressToBlockPropose[msg.sender] == 0 || addressToBlockPropose[msg.sender] <= block.number);
        addressToBlockPropose[msg.sender] = block.number + proposeCoolDown;
        return super.propose(targets, values, calldatas, description);
    }

    function proposalThreshold() public view override(DAO) returns (uint256) {
        return super.proposalThreshold();
    }

    function _execute(
        uint256 proposalId,
        address targets,
        uint256 values,
        bytes memory calldatas,
        bytes32 descriptionHash
    ) internal override(DAO) {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executor() internal view override(DAO) returns (address) {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(DAO)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
