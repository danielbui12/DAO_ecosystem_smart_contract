// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DAO.sol";

abstract contract DAOCountVotes is DAO {
    /**
     * @dev Supported vote types.
     */
    enum VoteType {
        Against,
        For
    }

    struct ProposalVote {
        uint256 againstVotes;
        uint256 forVotes;
        address[] votedAddress;
        mapping(address => bool) hasVoted;
    }

    mapping(uint256 => ProposalVote) private _proposalVotes;

    /**
     * @dev Although `support=bravo`, but we only count the againstVotes and forVotes.
     */
    function COUNTING_MODE()
        public
        pure
        virtual
        override
        returns (string memory)
    {
        return "support=bravo&quorum=for,abstain";
    }

    /**
     * @dev See {IDAO-hasVoted}.
     */
    function hasVoted(uint256 proposalId, address account)
        public
        view
        virtual
        override
        returns (bool)
    {
        return _proposalVotes[proposalId].hasVoted[account];
    }

    /**
     * @dev Accessor to the internal vote counts.
     */
    function proposalVotes(uint256 proposalId)
        public
        view
        virtual
        returns (
            uint256 againstVotes,
            uint256 forVotes,
            address[] memory votedAddress
        )
    {
        return (
            _proposalVotes[proposalId].againstVotes,
            _proposalVotes[proposalId].forVotes,
            _proposalVotes[proposalId].votedAddress
        );
    }

    /**
     * @dev See {Governor-_quorumReached}.
     * Note quorum is modifier in this modules. It will contain both forVotes and againstVotes
     */
    function _quorumReached(uint256 proposalId)
        internal
        view
        virtual
        override
        returns (bool)
    {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];
        return
            quorum(
                proposalSnapshot(proposalId),
                proposalId == _finalProposalId
            ) <= (proposalvote.forVotes + proposalvote.againstVotes);
    }

    /**
     * @dev See {IDAO-_voteSucceeded}. In this module, the forVotesRate should be more than 75% if it is final proposal or be more than 25% if it is ideaproposal.
     */
    function _voteSucceeded(uint256 proposalId)
        internal
        view
        virtual
        override
        returns (bool)
    {
        uint256 proposalForRate_ = proposalForRate(proposalId);
        (uint256 againstVotes, uint256 forVotes, ) = proposalVotes(proposalId);
        return
            proposalId == _finalProposalId
                ? (forVotes * 100) / (againstVotes + forVotes) >= 75
                : proposalForRate_ >= 25;
    }

    /**
     * @dev See {DAO-highestRateFor}
     */
    function _highestRateFor()
        internal
        view
        virtual
        override
        returns (uint256)
    {
        uint256 highestRateProposal = 0;
        for (uint256 i = 0; i < _proposalKeys.length; i++) {
            if (
                state(_proposalKeys[i]) == ProposalState.Queued &&
                proposalForRate(_proposalKeys[i]) >
                proposalForRate(highestRateProposal)
            ) {
                highestRateProposal = _proposalKeys[i];
            }
        }
        return highestRateProposal;
    }

    /**
     * @dev proposalForRate
     */
    function proposalForRate(uint256 proposalId)
        public
        view
        virtual
        returns (uint256)
    {
        return _proposalVotes[proposalId].forVotes;
    }

    /**
     * @dev See {DAO-_resetCountVote}
     */
    function _resetCountVote(uint256 proposalId) public virtual override {
        ProposalVote storage proposalVote = _proposalVotes[proposalId];
        proposalVote.forVotes = 0;
        proposalVote.againstVotes = 0;
        for (uint256 i = 0; i < proposalVote.votedAddress.length; i++) {
            proposalVote.hasVoted[proposalVote.votedAddress[i]] = false;
        }
        delete proposalVote.votedAddress;
    }

    /**
     * @dev See {Governor-_countVote}. In this module, the support follows the `VoteType` enum (from Governor Bravo).
     */
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight
    ) internal virtual override {
        ProposalVote storage proposalvote = _proposalVotes[proposalId];
        require(
            !proposalvote.hasVoted[account],
            "DAOCountVotes: vote already cast"
        );
        proposalvote.hasVoted[account] = true;
        proposalvote.votedAddress.push(account);
        if (support == uint8(VoteType.Against)) {
            proposalvote.againstVotes += weight;
        } else if (support == uint8(VoteType.For)) {
            proposalvote.forVotes += weight;
        } else {
            revert("DAOCountVotes: invalid value for enum VoteType");
        }
    }
}
