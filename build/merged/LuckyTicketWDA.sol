// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)
/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface LinkTokenInterface {
    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);

    function approve(address spender, uint256 value)
        external
        returns (bool success);

    function balanceOf(address owner) external view returns (uint256 balance);

    function decimals() external view returns (uint8 decimalPlaces);

    function decreaseApproval(address spender, uint256 addedValue)
        external
        returns (bool success);

    function increaseApproval(address spender, uint256 subtractedValue)
        external;

    function name() external view returns (string memory tokenName);

    function symbol() external view returns (string memory tokenSymbol);

    function totalSupply() external view returns (uint256 totalTokensIssued);

    function transfer(address to, uint256 value)
        external
        returns (bool success);

    function transferAndCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (bool success);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool success);
}

contract VRFRequestIDBase {
    /**
     * @notice returns the seed which is actually input to the VRF coordinator
     *
     * @dev To prevent repetition of VRF output due to repetition of the
     * @dev user-supplied seed, that seed is combined in a hash with the
     * @dev user-specific nonce, and the address of the consuming contract. The
     * @dev risk of repetition is mostly mitigated by inclusion of a blockhash in
     * @dev the final seed, but the nonce does protect against repetition in
     * @dev requests which are included in a single block.
     *
     * @param _userSeed VRF seed input provided by user
     * @param _requester Address of the requesting contract
     * @param _nonce User-specific nonce at the time of the request
     */
    function makeVRFInputSeed(
        bytes32 _keyHash,
        uint256 _userSeed,
        address _requester,
        uint256 _nonce
    ) internal pure returns (uint256) {
        return
            uint256(
                keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce))
            );
    }

    /**
     * @notice Returns the id for this request
     * @param _keyHash The serviceAgreement ID to be used for this request
     * @param _vRFInputSeed The seed to be passed directly to the VRF
     * @return The id for this request
     *
     * @dev Note that _vRFInputSeed is not the seed passed by the consuming
     * @dev contract, but the one generated by makeVRFInputSeed
     */
    function makeRequestId(bytes32 _keyHash, uint256 _vRFInputSeed)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
    }
}

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator, _link) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash), and have told you the minimum LINK
 * @dev price for VRF service. Make sure your contract has sufficient LINK, and
 * @dev call requestRandomness(keyHash, fee, seed), where seed is the input you
 * @dev want to generate randomness from.
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomness method.
 *
 * @dev The randomness argument to fulfillRandomness is the actual random value
 * @dev generated from your seed.
 *
 * @dev The requestId argument is generated from the keyHash and the seed by
 * @dev makeRequestId(keyHash, seed). If your contract could have concurrent
 * @dev requests open, you can use the requestId to track which seed is
 * @dev associated with which randomness. See VRFRequestIDBase.sol for more
 * @dev details. (See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.)
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ. (Which is critical to making unpredictable randomness! See the
 * @dev next section.)
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the ultimate input to the VRF is mixed with the block hash of the
 * @dev block in which the request is made, user-provided seeds have no impact
 * @dev on its economic security properties. They are only included for API
 * @dev compatability with previous versions of this contract.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request.
 */
abstract contract VRFConsumerBase is VRFRequestIDBase {
    /**
     * @notice fulfillRandomness handles the VRF response. Your contract must
     * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
     * @notice principles to keep in mind when implementing your fulfillRandomness
     * @notice method.
     *
     * @dev VRFConsumerBase expects its subcontracts to have a method with this
     * @dev signature, and will call it once it has verified the proof
     * @dev associated with the randomness. (It is triggered via a call to
     * @dev rawFulfillRandomness, below.)
     *
     * @param requestId The Id initially returned by requestRandomness
     * @param randomness the VRF output
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        virtual;

    /**
     * @dev In order to keep backwards compatibility we have kept the user
     * seed field around. We remove the use of it because given that the blockhash
     * enters later, it overrides whatever randomness the used seed provides.
     * Given that it adds no security, and can easily lead to misunderstandings,
     * we have removed it from usage and can now provide a simpler API.
     */
    uint256 private constant USER_SEED_PLACEHOLDER = 0;

    /**
     * @notice requestRandomness initiates a request for VRF output given _seed
     *
     * @dev The fulfillRandomness method receives the output, once it's provided
     * @dev by the Oracle, and verified by the vrfCoordinator.
     *
     * @dev The _keyHash must already be registered with the VRFCoordinator, and
     * @dev the _fee must exceed the fee specified during registration of the
     * @dev _keyHash.
     *
     * @dev The _seed parameter is vestigial, and is kept only for API
     * @dev compatibility with older versions. It can't *hurt* to mix in some of
     * @dev your own randomness, here, but it's not necessary because the VRF
     * @dev oracle will mix the hash of the block containing your request into the
     * @dev VRF seed it ultimately uses.
     *
     * @param _keyHash ID of public key against which randomness is generated
     * @param _fee The amount of LINK to send with the request
     *
     * @return requestId unique ID for this request
     *
     * @dev The returned requestId can be used to distinguish responses to
     * @dev concurrent requests. It is passed as the first argument to
     * @dev fulfillRandomness.
     */
    function requestRandomness(bytes32 _keyHash, uint256 _fee)
        internal
        returns (bytes32 requestId)
    {
        LINK.transferAndCall(
            vrfCoordinator,
            _fee,
            abi.encode(_keyHash, USER_SEED_PLACEHOLDER)
        );
        // This is the seed passed to VRFCoordinator. The oracle will mix this with
        // the hash of the block containing this request to obtain the seed/input
        // which is finally passed to the VRF cryptographic machinery.
        uint256 vRFSeed = makeVRFInputSeed(
            _keyHash,
            USER_SEED_PLACEHOLDER,
            address(this),
            nonces[_keyHash]
        );
        // nonces[_keyHash] must stay in sync with
        // VRFCoordinator.nonces[_keyHash][this], which was incremented by the above
        // successful LINK.transferAndCall (in VRFCoordinator.randomnessRequest).
        // This provides protection against the user repeating their input seed,
        // which would result in a predictable/duplicate output, if multiple such
        // requests appeared in the same block.
        nonces[_keyHash] = nonces[_keyHash] + 1;
        return makeRequestId(_keyHash, vRFSeed);
    }

    LinkTokenInterface internal immutable LINK;
    address private immutable vrfCoordinator;

    // Nonces for each VRF key from which randomness has been requested.
    //
    // Must stay in sync with VRFCoordinator[_keyHash][this]
    mapping(bytes32 => uint256) /* keyHash */ /* nonce */
        private nonces;

    /**
     * @param _vrfCoordinator address of VRFCoordinator contract
     * @param _link address of LINK token contract
     *
     * @dev https://docs.chain.link/docs/link-token-contracts
     */
    constructor(address _vrfCoordinator, address _link) {
        vrfCoordinator = _vrfCoordinator;
        LINK = LinkTokenInterface(_link);
    }

    // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
    // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
    // the origin of the call
    function rawFulfillRandomness(bytes32 requestId, uint256 randomness)
        external
    {
        require(
            msg.sender == vrfCoordinator,
            "Only VRFCoordinator can fulfill"
        );
        fulfillRandomness(requestId, randomness);
    }
}

contract LuckyTicketWDA is Ownable, ReentrancyGuard, VRFConsumerBase {
    bytes32 internal _keyHash =
        0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
    uint256 internal _fee = 0.1 * 10**18; // MAINNET CHANGE IT TO 0.2 LINK
    uint256 _randomResult;

    address _token;
    address _DAOTreasuryWallet = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint24 public maxTicketProvidePerDay = 50000;
    uint24 public ticketSoldPerDay = 0;
    uint256 public period = 5 days;
    uint256[] _winningTicket5000WDA;
    uint256 winningTicket100000WDA;
    uint256 public lastTimeCheck = block.timestamp;
    uint24 totalTicketSoldPerPeriod = 0; // maximum 50000 * 5 days = 250000
    uint8 _ownerTicketMaxCount = 50;
    uint256 _feePerTicket = 0.0004 * 10**18; // BNB
    uint256 _ticketCost = 1000 * 10**18; // WDA
    uint256 public currentDate = 1;
    /**
     * percent: % change
     * action: 0 decreasing, 1: increasing
     */
    struct Propsal {
        uint256 percent;
        uint8 action;
    }

    struct Ticket {
        uint256 purchaseDate;
        uint256 proposalPercentage;
        uint8 proposalAction;
    }

    Propsal public p;

    event BuyTicket(address indexed buyer, uint256 amount);
    event TicketWin(
        address indexed owner,
        uint256 indexed amount,
        uint256 ticketIndex
    );

    /**
     * BNB Chain Testnet
     * VRF coordinator 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
     * LINK 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
     * keyHash 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186
     * More information https://docs.chain.link/docs/vrf-contracts/v1/
     */

    address _VRFCoordinator = 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C;
    address _LINKToken = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;

    constructor(address token_) VRFConsumerBase(_VRFCoordinator, _LINKToken) {
        _token = token_;
    }

    mapping(address => Ticket[]) ownerTicket;
    // index ticket => player address
    mapping(uint256 => address) public ownerOfTicket;
    // player address => ticket reward amount
    mapping(address => uint256[]) public ownerWinningTicket5000WDA;
    // player address => ticket reward amount
    mapping(address => uint256[]) public ownerWinningTicket100000WDA;
    // player address => claimable date
    mapping(address => uint256[]) ownerTicketReward;
    // ticket each day
    mapping(uint256 => uint256) ticketEachDay;

    /**
     * --------------- TEST ONLY -----------------
     */
    uint256 lockTime = 5 days;
    uint256 minimumPlayer = 100;

    // minimum player la 100
    function setMinimumPlayer(uint256 amount) external {
        minimumPlayer = amount;
    }

    function setLockTime(uint256 time) external {
        lockTime = time;
    }

    function setPeriod(uint256 _period) external onlyOwner {
        period = _period;
    }

    /** ------------- END OF TEST ONLY --------------- */

    function getOwnerWinningTicket5000WDA() external view returns (uint256) {
        return ownerWinningTicket5000WDA[msg.sender].length;
    }

    function getOwnerWinningTicket100000() external view returns (uint256) {
        return ownerWinningTicket100000WDA[msg.sender].length;
    }

    /**
     * @param percentChange: update percent proposal
     * @param action: 0 deceasing, 1: increasting
     */
    function setProposal(uint256 percentChange, uint8 action)
        external
        onlyOwner
    {
        require(percentChange <= 10, "Percentage too big");
        p.action = action;
        p.percent = percentChange;
    }

    function getOwnerTicket() external view returns (uint256) {
        return ownerTicket[msg.sender].length;
    }

    function getPlayerRewardTicketCount() external view returns (uint256) {
        return ownerTicketReward[msg.sender].length;
    }

    function getPlayerRewardTicketAvailableCount()
        public
        view
        returns (uint256)
    {
        uint256 availableCount = 0;
        for (uint256 i = 0; i < ownerTicketReward[msg.sender].length; i++) {
            if (ownerTicketReward[msg.sender][i] <= block.timestamp) {
                availableCount++;
            }
        }
        return availableCount;
    }

    function getDAOTreasuryWallet() external view returns (address) {
        return _DAOTreasuryWallet;
    }

    function setDAOTreasuryWallet(address _newDAOTreasuryWallet)
        external
        onlyOwner
    {
        _DAOTreasuryWallet = _newDAOTreasuryWallet;
    }

    function getFeePerTicket() external view returns (uint256) {
        return _feePerTicket;
    }

    function setFeePerTicket(uint256 _newFeePerTicket) external onlyOwner {
        _feePerTicket = _newFeePerTicket;
    }

    function setCurrentDate() external onlyOwner {
        if (currentDate == 5) {
            currentDate = 1;
        } else {
            currentDate++;
        }
    }

    function cronRollingWinningTicket() external isPeriod onlyOwner {
        _setTicket100000WDA();
        _setTicket5000WDA();
        lastTimeCheck = block.timestamp;
        _resetAllTicket();
    }

    function _setTicket5000WDA() internal {
        // if too few player => return cost of ticket
        if (totalTicketSoldPerPeriod >= minimumPlayer) {
            // random number ticket for 1% user reward 5000 WDA
            uint256 _winnerCount = totalTicketSoldPerPeriod / minimumPlayer;
            for (uint256 i = 0; i < _winnerCount; i++) {
                uint256 _newIndexWinningTicket5000WDA = _generateRandomNum(
                    i,
                    totalTicketSoldPerPeriod
                );
                _winningTicket5000WDA.push(_newIndexWinningTicket5000WDA);
                _checkTicket(_newIndexWinningTicket5000WDA, 5000);
            }
        } else {
            _checkTicket(101, 5000);
        }
    }

    function _setTicket100000WDA() internal {
        // if too few player => return cost of ticket
        if (totalTicketSoldPerPeriod >= minimumPlayer) {
            // random 1 user reward 100000 WDA;
            uint256 indexWinningTicket = _generateRandomNum(
                100000,
                totalTicketSoldPerPeriod
            );
            winningTicket100000WDA = indexWinningTicket; // public winning ticket 100000 WDA
            _checkTicket(indexWinningTicket, 100000);
        } else {
            _checkTicket(101, 100000);
        }
    }

    function _checkTicket(uint256 _winningTicketIndex, uint256 _rewardAmount)
        internal
    {
        for (uint256 i = 0; i < totalTicketSoldPerPeriod; i++) {
            address _addressOwnerOfTicket = ownerOfTicket[i];
            Ticket memory _ownerTicket = ownerTicket[msg.sender][i];
            if (i == _winningTicketIndex) {
                uint256 _reward = _rewardAmount * 10**18; // to wei
                if (_ownerTicket.proposalPercentage != 0) {
                    _reward = _ownerTicket.proposalAction == 0
                        ? _reward -
                            ((_reward * _ownerTicket.proposalPercentage) / 100)
                        : _reward +
                            ((_reward * _ownerTicket.proposalPercentage) / 100);
                }
                if (_rewardAmount == 5000) {
                    ownerWinningTicket5000WDA[_addressOwnerOfTicket].push(
                        _reward
                    );
                } else {
                    ownerWinningTicket100000WDA[_addressOwnerOfTicket].push(
                        _reward
                    );
                }
                emit TicketWin(_addressOwnerOfTicket, _reward, i);
            } else {
                ownerTicketReward[_addressOwnerOfTicket].push(
                    _ownerTicket.purchaseDate + lockTime
                );
            }
        }
    }

    function getTicketSoldPerDay() public view returns (uint256) {
        return ticketEachDay[currentDate];
    }

    function _resetAllTicket() internal {
        getRandomNumber();
        for (uint24 i = 0; i < totalTicketSoldPerPeriod; i++) {
            address addressOwnerOfTicket = ownerOfTicket[i];
            delete ownerTicket[addressOwnerOfTicket][i];
            delete ownerOfTicket[i];
        }
        for (uint8 i = 1; i <= 5; i++) {
            ticketEachDay[i] = 0;
        }
        totalTicketSoldPerPeriod = 0;
    }

    function getRandomNumber() public returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= _fee,
            "Not enough fee LINK in contract"
        );
        return requestRandomness(_keyHash, _fee);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        _randomResult = randomness;
    }

    function _generateRandomNum(uint256 _more, uint256 _mod)
        internal
        view
        returns (uint256)
    {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    _randomResult,
                    _more,
                    block.timestamp,
                    msg.sender
                )
            )
        );
        return randomNumber % _mod;
    }

    function buyTicket(uint8 _quantity) external payable nonReentrant {
        // check maximum ticket allow of each user
        require(
            ownerTicket[msg.sender].length + _quantity <= _ownerTicketMaxCount,
            "Maximum ticket allow"
        );
        // check quantity provide per day
        require(
            _quantity + getTicketSoldPerDay() <= maxTicketProvidePerDay,
            "Over limited ticket"
        );
        // check fee
        uint256 _totalFeeBNB = _quantity * _feePerTicket;
        require(msg.value >= _totalFeeBNB, "Not enough fee BNB");
        // check allowance
        uint256 _totalFeeWDA = _quantity * _ticketCost;
        uint256 allowance = IERC20(_token).allowance(msg.sender, address(this));
        require(allowance >= _totalFeeWDA, "Over allowance WDA");
        IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            _totalFeeWDA // send ticket cost only to address(this)
        );
        // create & store ticket
        for (uint8 i = 0; i < _quantity; i++) {
            ownerTicket[msg.sender].push(
                Ticket(block.timestamp, p.percent, p.action)
            );
            // store address owner of ticket
            ownerOfTicket[totalTicketSoldPerPeriod] = msg.sender;
            totalTicketSoldPerPeriod++;
        }
        ticketEachDay[currentDate] =
            ticketEachDay[currentDate] +
            uint256(_quantity);

        // send fee per ticket (BNB) to DAO treasury
        payable(_DAOTreasuryWallet).transfer(_totalFeeBNB);
        emit BuyTicket(msg.sender, _quantity);
    }

    function _calculateReward(uint8 ticketType)
        internal
        view
        returns (uint256)
    {
        uint256 earned = 0;
        if (ticketType == 0) {
            for (
                uint8 i = 0;
                i < ownerWinningTicket5000WDA[msg.sender].length;
                i++
            ) {
                earned += ownerWinningTicket5000WDA[msg.sender][i];
            }
        } else {
            for (
                uint8 i = 0;
                i < ownerWinningTicket100000WDA[msg.sender].length;
                i++
            ) {
                earned += ownerWinningTicket100000WDA[msg.sender][i];
            }
        }
        return earned;
    }

    function claimCoin(uint8 _ticketType) external nonReentrant {
        // _ticketType: 0: 5000, 1: 100000
        if (_ticketType == 0) {
            require(
                ownerWinningTicket5000WDA[msg.sender].length > 0,
                "Not have enough ticket to claim"
            );
            uint256 _earned = _calculateReward(_ticketType);
            ownerWinningTicket5000WDA[msg.sender] = new uint256[](0);
            IERC20(_token).transfer(msg.sender, _earned);
        } else {
            require(
                ownerWinningTicket100000WDA[msg.sender].length > 0,
                "Not have enough ticket to claim"
            );
            uint256 _earned = _calculateReward(_ticketType);
            ownerWinningTicket100000WDA[msg.sender] = new uint256[](0);
            IERC20(_token).transfer(msg.sender, _earned);
        }
    }

    function claimReward() external nonReentrant {
        uint256 availableCount = getPlayerRewardTicketAvailableCount();
        require(availableCount > 0, "Invalid quantity");
        uint256 earned = availableCount * _ticketCost;
        ownerTicketReward[msg.sender] = new uint256[](0);
        IERC20(_token).transfer(msg.sender, earned);
    }

    modifier isPeriod() {
        require(block.timestamp >= lastTimeCheck + period, "Not period");
        _;
    }
}
