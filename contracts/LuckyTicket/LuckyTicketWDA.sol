// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract LuckyTicketWDA is ReentrancyGuard, VRFConsumerBase {
    bytes32 internal _keyHash =
        0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 internal _fee = 0.1 * 10**18; // MAINNET CHANGE IT TO 0.2 LINK
    uint256 _randomResult;

    IERC20 WDAToken;
    address private _owner;
    address public DAOTreasuryWallet =
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint256 constant maxTicketProvidePerDay = 50000;
    uint256 public lastTimeCheck = block.timestamp;
    uint256 public totalTicketSoldPerPeriod = 0; // maximum 50000 * 5 days = 250000
    uint256 constant ownerTicketMaxCount = 50;
    uint256 _feePerTicket = 0.0004 * 10**18; // BNB
    uint256 _ticketCost = 1000 * 10**18; // WDA
    uint256 currentSession = 0;
    uint256 checkpointProposal;

    enum ContractState {
        NORMAL,
        GETTING_RANDOM_NUMBER,
        REWARDING_TICKET
    }
    ContractState public contractState = ContractState.NORMAL;

    struct TicketReward {
        uint256 amount;
        uint256 claimableDate;
    }

    event BuyTicket(
        address indexed buyer,
        uint256 amount,
        uint256 timestamp,
        uint256 checkpoint
    );
    event TicketWin(
        address indexed owner,
        uint256 indexed amount,
        uint8 ticketType
    );
    event RandomWinner(uint256 timestamp);

    /**
     * KOVAN Testnet
     * VRF coordinator 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK 0xa36085F69e2889c224210F603D836748e7dC0088
     * keyHash 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     * More information https://docs.chain.link/docs/vrf-contracts/v1/
     */

    constructor(IERC20 _token)
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088 // link
        )
    {
        WDAToken = _token;
        _owner = msg.sender;
    }

    // address user => session => amount
    mapping(address => mapping(uint256 => uint256)) ownerTicketCount;
    // player address => ticket reward amount
    mapping(address => TicketReward[]) ownerWinningTicket5000WDA;
    // player address => ticket reward amount
    mapping(address => TicketReward[]) ownerWinningTicket100000WDA;
    // address => ticket reward
    mapping(address => TicketReward[]) ownerTicketReward;
    // ticket each day
    mapping(uint256 => uint256) ticketEachDay;
    mapping(uint256 => uint256) checkpointToJackpot;
    mapping(uint256 => uint256) checkpointToLucky;
    mapping(address => bool) validTarget;

    /**
     * --------------- TEST ONLY -----------------
     */
    uint256 lockTime = 1800;
    uint256 minimumPlayer = 100;

    // minimum player la 100
    function setMinimumPlayer(uint256 amount) external {
        minimumPlayer = amount;
    }

    function setLockTime(uint256 time) external {
        lockTime = time;
    }

    uint256 maxPercent = 10;

    function setMaxPercentProposal(uint256 maxP) external {
        maxPercent = maxP;
    }

    /** ------------- END OF TEST ONLY --------------- */

    function withdrawWDAToDAOTreasury() external onlyOwner {
        uint256 amount = WDAToken.balanceOf(address(this));
        WDAToken.transfer(DAOTreasuryWallet, amount);
    }

    function setValidTarget(address target, bool permission)
        external
        onlyOwner
    {
        validTarget[target] = permission;
    }

    function initialize() external onlyOwner {
        checkpointToJackpot[checkpointProposal] = 100000 * 10**18;
        checkpointToLucky[checkpointProposal] = 5000 * 10**18;
    }

    /**
     * @param percentChange: update percent proposal
     * @param action: 0 deceasing, 1: increasting
     */
    function setProposal(uint256 percentChange, uint8 action)
        external
        onlyValidTarget
    {
        require(percentChange <= maxPercent, "Percentage too big");
        uint256 prevCheckpointJackpot = checkpointToJackpot[checkpointProposal];
        uint256 prevCheckpointLucky = checkpointToLucky[checkpointProposal];
        checkpointProposal++;
        if (action == 0) {
            checkpointToJackpot[checkpointProposal] =
                prevCheckpointJackpot -
                ((prevCheckpointJackpot * percentChange) / 100);
            checkpointToLucky[checkpointProposal] =
                prevCheckpointLucky -
                ((prevCheckpointLucky * percentChange) / 100);
        } else {
            checkpointToJackpot[checkpointProposal] =
                prevCheckpointJackpot +
                ((prevCheckpointJackpot * percentChange) / 100);
            checkpointToLucky[checkpointProposal] =
                prevCheckpointLucky +
                ((prevCheckpointLucky * percentChange) / 100);
        }
    }

    function getOwnerWinningTicket5000WDA() external view returns (uint256) {
        uint256 count = 0;
        TicketReward[] memory ownerReward = ownerWinningTicket5000WDA[
            msg.sender
        ];
        for (uint256 i = 0; i < ownerReward.length; i++) {
            if (
                ownerReward[i].amount != 0 && ownerReward[i].claimableDate != 0
            ) {
                count++;
            }
        }
        return count;
    }

    function getOwnerWinningTicket100000WDA() external view returns (uint256) {
        uint256 count = 0;
        TicketReward[] memory ownerReward = ownerWinningTicket100000WDA[
            msg.sender
        ];
        for (uint256 i = 0; i < ownerReward.length; i++) {
            if (
                ownerReward[i].amount != 0 && ownerReward[i].claimableDate != 0
            ) {
                count++;
            }
        }
        return count;
    }

    function getOwnerWinningTicket5000WDAAvailable()
        external
        view
        returns (uint256)
    {
        uint256 amount = 0;
        TicketReward[] memory ownerReward = ownerWinningTicket5000WDA[
            msg.sender
        ];
        for (uint256 i = 0; i < ownerReward.length; i++) {
            if (
                ownerReward[i].claimableDate != 0 &&
                ownerReward[i].claimableDate <= block.timestamp
            ) {
                amount++;
            }
        }
        return amount;
    }

    function getOwnerWinningTicket100000WDAAvailable()
        external
        view
        returns (uint256)
    {
        uint256 amount = 0;
        TicketReward[] memory ownerReward = ownerWinningTicket100000WDA[
            msg.sender
        ];
        for (uint256 i = 0; i < ownerReward.length; i++) {
            if (
                ownerReward[i].claimableDate != 0 &&
                ownerReward[i].claimableDate <= block.timestamp
            ) {
                amount++;
            }
        }
        return amount;
    }

    function getOwnerTicketReward() external view returns (uint256) {
        uint256 amount = 0;
        TicketReward[] memory ownerTicket = ownerTicketReward[msg.sender];
        for (uint256 i = 0; i < ownerTicket.length; i++) {
            if (ownerTicket[i].claimableDate != 0) {
                amount += ownerTicket[i].amount;
            }
        }
        return amount;
    }

    function getOwnerTicketRewardAvailable() external view returns (uint256) {
        uint256 amount = 0;
        TicketReward[] memory ownerTicket = ownerTicketReward[msg.sender];
        for (uint256 i = 0; i < ownerTicket.length; i++) {
            if (
                ownerTicket[i].claimableDate != 0 &&
                ownerTicket[i].claimableDate <= block.timestamp
            ) {
                amount += ownerTicket[i].amount;
            }
        }
        return amount;
    }

    function getOwnerTicket() external view returns (uint256) {
        return ownerTicketCount[msg.sender][currentSession];
    }

    function setDAOTreasuryWallet(address _newDAOTreasuryWallet)
        external
        onlyOwner
    {
        DAOTreasuryWallet = _newDAOTreasuryWallet;
    }

    function getFeePerTicket() external view returns (uint256) {
        return _feePerTicket;
    }

    function setFeePerTicket(uint256 _newFeePerTicket) external onlyOwner {
        _feePerTicket = _newFeePerTicket;
    }

    function payWinner(
        address winner,
        uint256 rewardAmount,
        uint256 purchaseDate,
        uint256 checkpoint
    ) external onlyValidTarget {
        if (rewardAmount == 100000) {
            ownerWinningTicket100000WDA[winner].push(
                TicketReward(
                    checkpointToJackpot[checkpoint],
                    purchaseDate + lockTime
                )
            );
            emit TicketWin(winner, checkpointToJackpot[checkpoint], 1);
        } else {
            ownerWinningTicket5000WDA[winner].push(
                TicketReward(
                    checkpointToLucky[checkpoint],
                    purchaseDate + lockTime
                )
            );
            emit TicketWin(winner, checkpointToLucky[checkpoint], 0);
        }
    }

    function rewardTicket(
        address player,
        uint256 purchaseDate,
        uint256 amount
    ) external onlyValidTarget {
        ownerTicketReward[player].push(
            TicketReward(amount, purchaseDate + lockTime)
        );
    }

    function getTicketSoldPerDay() public view returns (uint256) {
        uint256 currentDate = (block.timestamp - lastTimeCheck) / 1 days;
        return ticketEachDay[currentDate];
    }

    function resetAllTicket() external onlyValidTarget {
        currentSession++;
        for (uint256 i = 0; i < 5; i++) {
            ticketEachDay[i] = 0;
        }
        totalTicketSoldPerPeriod = 0;
        lastTimeCheck = block.timestamp;
        contractState = ContractState.NORMAL;
    }

    function getRandomNumber()
        public
        onlyValidTarget
        returns (bytes32 requestId)
    {
        require(
            LINK.balanceOf(address(this)) >= _fee,
            "Not enough fee LINK in contract"
        );
        contractState = ContractState.GETTING_RANDOM_NUMBER;
        return requestRandomness(_keyHash, _fee);
    }

    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        _randomResult = randomness;
        contractState = ContractState.REWARDING_TICKET;
        emit RandomWinner(block.timestamp);
    }

    function generateRandomNum(uint256 mod) public view returns (uint256) {
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(_randomResult, block.timestamp, msg.sender)
            )
        );
        return randomNumber % mod;
    }

    function _calculateReward(uint8 ticketType) internal returns (uint256) {
        uint256 earned = 0;
        if (ticketType == 0) {
            for (
                uint256 i = 0;
                i < ownerWinningTicket5000WDA[msg.sender].length;
                i++
            ) {
                TicketReward memory reward = ownerWinningTicket5000WDA[
                    msg.sender
                ][i];
                if (
                    reward.claimableDate != 0 &&
                    reward.claimableDate <= block.timestamp
                ) {
                    earned += reward.amount;
                    delete ownerWinningTicket5000WDA[msg.sender][i];
                }
            }
        } else {
            for (
                uint256 i = 0;
                i < ownerWinningTicket100000WDA[msg.sender].length;
                i++
            ) {
                TicketReward memory reward = ownerWinningTicket100000WDA[
                    msg.sender
                ][i];
                if (
                    reward.claimableDate != 0 &&
                    reward.claimableDate <= block.timestamp
                ) {
                    earned += reward.amount;
                    delete ownerWinningTicket100000WDA[msg.sender][i];
                }
            }
        }
        require(earned > 0, "Ticket locked");
        return earned;
    }

    function claimCoin(uint8 _ticketType) external {
        // _ticketType: 0: 5000, 1: 100000
        if (_ticketType == 0) {
            require(
                ownerWinningTicket5000WDA[msg.sender].length > 0,
                "None ticket is available to claim"
            );
        } else {
            require(
                ownerWinningTicket100000WDA[msg.sender].length > 0,
                "None ticket is available to claim"
            );
        }
        uint256 _earned = _calculateReward(_ticketType);
        WDAToken.transfer(msg.sender, _earned);
    }

    function claimReward() external {
        TicketReward[] memory ownerReward = ownerTicketReward[msg.sender];
        require(ownerReward.length > 0, "None ticket is available");
        uint256 count = 0;
        for (uint256 i = 0; i < ownerReward.length; i++) {
            if (
                ownerReward[i].amount != 0 &&
                ownerReward[i].claimableDate != 0 &&
                ownerReward[i].claimableDate <= block.timestamp
            ) {
                delete ownerTicketReward[msg.sender][i];
                count += ownerReward[i].amount;
            }
        }
        WDAToken.transfer(msg.sender, count * _ticketCost);
    }

    function buyTicket(uint256 _quantity) external payable nonReentrant {
        require(contractState == ContractState.NORMAL, "Not time to buy");
        require(_quantity > 0, "Invalid quantity");
        // check maximum ticket allow of each user
        require(
            ownerTicketCount[msg.sender][currentSession] + _quantity <=
                ownerTicketMaxCount,
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
        uint256 allowance = WDAToken.allowance(msg.sender, address(this));
        require(allowance >= _totalFeeWDA, "Over allowance WDA");
        WDAToken.transferFrom(
            msg.sender,
            address(this),
            _totalFeeWDA // send ticket cost only to address(this)
        );
        totalTicketSoldPerPeriod += _quantity;
        uint256 currentDate = (block.timestamp - lastTimeCheck) / 1 days;
        ownerTicketCount[msg.sender][currentSession] += _quantity;
        ticketEachDay[currentDate] += _quantity;

        // send fee per ticket (BNB) to DAO treasury
        (bool sent, ) = payable(DAOTreasuryWallet).call{value: _totalFeeBNB}(
            ""
        );
        require(sent, "Transfer BNB to seller failed");
        emit BuyTicket(
            msg.sender,
            _quantity,
            block.timestamp,
            checkpointProposal
        );
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
        _owner = newOwner;
    }

    modifier onlyValidTarget() {
        require(validTarget[msg.sender], "Not valid target");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: Not owner");
        _;
    }
}
