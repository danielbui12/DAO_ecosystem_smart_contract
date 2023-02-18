// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "../NFT/ICrownNFT.sol";
import "../NFT/IScepterNFT.sol";

contract LuckyTicketNFT is
    ReentrancyGuard,
    ERC1155Receiver,
    IERC721Receiver,
    VRFConsumerBase
{
    bytes32 internal _keyHash =
        0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
    uint256 internal _fee = 0.1 * 10**18; // MUST CHANGE IT TO 0.2 WHEN DEPLOY TO MAINNET
    uint256 _randomResult;
    address private _owner;
    IERC20 WDAToken;
    ICrownNFT _CrownToken;
    IScepterNFT _ScepterToken;
    uint24 public maxTicketProvidePerDay = 50000;
    uint256 public ticketSoldPerDay = 0;
    uint256 _ticketCost = 50 * 10**18; // wda
    uint256 public todayTokenId;
    uint256 public currentSession = 0;
    enum ContractState {
        NORMAL,
        GETTING_RANDOM_NUMBER,
        BURNING_CROWN,
        REWARDING_TICKET
    }
    ContractState public contractState = ContractState.NORMAL;

    event BuyTicket(address indexed buyer, uint256 amount);
    event RandomTicket(uint256 timestamp);
    event TicketNFTWin(address indexed owner, uint256 indexed crowId);

    /**
     * Kovan Testnet
     * VRF coordinator 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK 0xa36085F69e2889c224210F603D836748e7dC0088
     * keyHash 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     * More information https://docs.chain.link/docs/vrf-contracts/v1/
     */

    constructor(IERC20 _token)
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9,
            0xa36085F69e2889c224210F603D836748e7dC0088
        )
    {
        WDAToken = _token;
        _owner = msg.sender;
    }

    // address user => session => amount
    mapping(address => mapping(uint256 => uint256)) ownerTicketCount;
    // playe[currentSession]r address => tokenId
    mapping(address => uint256[]) ownerWinningCrownNFT;
    // player address => amount
    mapping(address => uint256) public ownerScepterNFT;

    mapping(address => bool) validTarget;

    /** ============== TEST ONLY ============== */
    function setMaxTicketProvidePerDay(uint24 newAmount) public {
        maxTicketProvidePerDay = newAmount;
    }

    function setCrownAddress(address _newAddress) external onlyOwner {
        _CrownToken = ICrownNFT(_newAddress);
    }

    function setScepterAddress(address _newAddress) external onlyOwner {
        _ScepterToken = IScepterNFT(_newAddress);
    }

    /** ============== END OF TEST ONLY =========== */

    /**
     * Always returns `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155Received(address,address,uint256,uint256,bytes)"
                )
            );
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return
            bytes4(
                keccak256(
                    "onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"
                )
            );
    }

    function setValidTarget(address target, bool permission)
        external
        onlyOwner
    {
        validTarget[target] = permission;
    }

    function getOwnerCrownNFT() external view returns (uint256) {
        uint256 counter = 0;
        for (uint256 i = 0; i < ownerWinningCrownNFT[msg.sender].length; i++) {
            if (ownerWinningCrownNFT[msg.sender][i] != 0) {
                counter++;
            }
        }
        return counter;
    }

    function getListOwnerCrownNFT() external view returns (uint256[] memory) {
        return ownerWinningCrownNFT[msg.sender];
    }

    function getOwnerTicket() external view returns (uint256) {
        return ownerTicketCount[msg.sender][currentSession];
    }

    function setNewCrownBonus() external onlyValidTarget {
        _setNewCrownBonus();
    }

    function _setNewCrownBonus() internal {
        todayTokenId = _CrownToken.mintValidTarget(1);
    }

    function setNewSession() external onlyValidTarget {
        currentSession++;
        ticketSoldPerDay = 0;
        contractState = ContractState.NORMAL;
        _setNewCrownBonus();
    }

    function claimCrown(uint8 index) external {
        require(
            ownerWinningCrownNFT[msg.sender][index] > 0,
            "Invalid Crown NFT Id"
        );
        _CrownToken.transferFrom(
            address(this),
            msg.sender,
            ownerWinningCrownNFT[msg.sender][index]
        );
        delete ownerWinningCrownNFT[msg.sender][index];
    }

    function claimScepter() external {
        require(ownerScepterNFT[msg.sender] > 0, "Not enough quantity");
        _ScepterToken.mintValidTarget(ownerScepterNFT[msg.sender]);
        _ScepterToken.safeTransferFrom(
            address(this),
            msg.sender,
            0, // SCEPTER 0
            ownerScepterNFT[msg.sender],
            ""
        );
        ownerScepterNFT[msg.sender] = 0;
    }

    function getRandomNumber()
        external
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
        emit RandomTicket(block.timestamp);
    }

    function randomWinner() external view returns (uint256) {
        uint256 newIndexWinningTicket = _randomResult % ticketSoldPerDay;
        return newIndexWinningTicket;
    }

    function burnCrown() external onlyValidTarget {
        _CrownToken.burn(todayTokenId);
        contractState = ContractState.BURNING_CROWN;
    }

    function payWinner(address winner) external onlyValidTarget {
        ownerWinningCrownNFT[winner].push(todayTokenId);
        emit TicketNFTWin(winner, todayTokenId);
    }

    function buyTicket(uint256 _quantity) external nonReentrant {
        require(contractState == ContractState.NORMAL, "Not time to buy");
        require(_quantity > 0, "Invalid quantity");
        // check maximum ticket allow of each user
        require(
            ownerTicketCount[msg.sender][currentSession] + _quantity <= 250, // max allowance
            "Maximum ticket allow"
        );
        // check quantity provide per day
        require(
            _quantity + ticketSoldPerDay <= maxTicketProvidePerDay,
            "Over limited ticket"
        );
        // check allowance
        uint256 _totalFee = _quantity * _ticketCost;
        uint256 allowance = WDAToken.allowance(msg.sender, address(this));
        require(allowance >= _totalFee, "Over allowance WDA");
        WDAToken.transferFrom(msg.sender, address(this), _totalFee);
        ticketSoldPerDay += _quantity;
        ownerScepterNFT[msg.sender] += _quantity;
        ownerTicketCount[msg.sender][currentSession] += _quantity;
        emit BuyTicket(msg.sender, _quantity);
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
