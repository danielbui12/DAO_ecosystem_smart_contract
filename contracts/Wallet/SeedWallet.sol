// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SeedWallet is Ownable, ReentrancyGuard {
    struct User {
        uint256 balance;
        uint256 amountClaimVesting;
        bool isClaimTGE;
    }

    uint256 public _startAt;
    uint256 public _endAt;
    uint256 public _firstLockingTime;
    uint256 public _tge;
    uint256 public _totalVestingPeriod;
    uint256 public _vestingPeriod;
    uint256 public _totalBalances;
    uint256 public _cost;
    uint256 public _min;
    uint256 public _max;
    uint256 public _tgeTime;

    bool public _soldOut;

    address public _token;
    address public _exchangeToken;
    address[] public whiteList;

    address[] private _userKeys;

    mapping(address => User) public users;

    event Register(address indexed buyer, uint256 amount);
    event ClaimWDA(address indexed buyer, uint256 amount);
    event SoldOut(bool soldout);

    constructor(address token_, address exchangeToken_) {
        _token = token_;
        _exchangeToken = exchangeToken_;
    }

    function initialize(
        uint256 startAt_,
        uint256 firstLockingTime_,
        uint256 tge_,
        uint256 vestingPeriod_,
        uint256 totalVestingPeriod_,
        uint256 totalBalances_,
        uint256 cost_,
        uint256 min_,
        uint256 max_
    ) external onlyOwner {
        require(min_ < max_, "SEED:Min lower than max");
        _startAt = startAt_;
        _firstLockingTime = firstLockingTime_;
        _tge = tge_;
        _vestingPeriod = vestingPeriod_;
        _totalVestingPeriod = totalVestingPeriod_;
        _totalBalances = totalBalances_;
        _cost = cost_;
        _min = min_;
        _max = max_;
    }

    function buy(uint256 amount) external onlyAfterStart nonReentrant {
        require(_max > 0, "SEED:Not initial");
        require(
            getTotalBoughtWDA() + amount <= _totalBalances,
            "SEED:Higer than total"
        );
        require(amount >= _min, "SEED:Amount should larger than min");
        require(isWhiteList(msg.sender), "SEED:Address not whitelist");
        if (!isExistAddress(msg.sender)) {
            users[msg.sender] = User(0, 0, false);
            _userKeys.push(msg.sender);
        }
        User storage user = users[msg.sender];
        require(user.balance + amount <= _max, "SEED: More than max");
        user.balance += amount;

        if (getTotalBoughtWDA() == _totalBalances) {
            _soldOut = true;
            emit SoldOut(_soldOut);
        }

        uint256 totalBusd = (amount / 1 ether) * _cost;
        uint256 allowance = IERC20(_exchangeToken).allowance(
            msg.sender,
            address(this)
        );

        require(totalBusd <= allowance, "SEED:Insufficent allowance");
        IERC20(_exchangeToken).transferFrom(
            msg.sender,
            address(this),
            totalBusd
        );
        emit Register(msg.sender, amount);
    }

    function setTgeTime(uint256 tgeTime_) external onlyOwner {
        require(tgeTime_ >= block.timestamp, "SEED: Tge time invalid");
        _tgeTime = tgeTime_;
        _firstLockingTime = _firstLockingTime + _tgeTime;
    }

    function claimTGE() external onlyTgeStart nonReentrant {
        require(block.timestamp >= _tgeTime, "PRIVATE: Early for tge");
        User storage user = users[msg.sender];
        require(!user.isClaimTGE, "SEED:Already Claim TGE");
        uint256 balanceOfUser = user.balance;
        uint256 amount = (balanceOfUser * _tge) / 100;
        _claimToken(amount);
        user.isClaimTGE = true;
    }

    function vesting() external nonReentrant onlyTgeStart {
        require(block.timestamp >= _tgeTime, "PRIVATE: Early for tge");
        User storage user = users[msg.sender];
        uint256 amount = getUnlocked(msg.sender);
        require(amount > 0, "PRIVATE: Unlock token is 0");
        user.amountClaimVesting += amount;
        _claimToken(amount);
    }

    function _claimToken(uint256 amount) internal {
        uint256 walletBalances = IERC20(_token).balanceOf(address(this));
        require(amount <= walletBalances, "Insufficent token");
        IERC20(_token).transfer(msg.sender, amount);
        emit ClaimWDA(msg.sender, amount);
    }

    function getUnlocked(address account)
        public
        view
        onlyTgeStart
        returns (uint256)
    {
        User storage user = users[account];
        uint256 amountUnlock = 0;
        require(
            block.timestamp >= _firstLockingTime,
            "SEED:Early for unlocking"
        );
        uint256 times = (block.timestamp - _firstLockingTime) / _vestingPeriod;
        require(times > 0, "SEED:Early for vesting");
        uint256 unlockedTokenPerTime = ((user.balance * (100 - _tge)) / 100) /
            _totalVestingPeriod;
        uint256 totalUnlockedToken = (times * unlockedTokenPerTime);
        if (totalUnlockedToken >= ((user.balance * (100 - _tge)) / 100)) {
            amountUnlock = (user.balance * (100 - _tge)) / 100;
        } else {
            amountUnlock = totalUnlockedToken - user.amountClaimVesting;
        }
        return amountUnlock;
    }

    function setWhiteList(address[] calldata users_) external onlyOwner {
        delete whiteList;
        whiteList = users_;
    }

    function isWhiteList(address account) public view returns (bool) {
        for (uint256 i = 0; i < whiteList.length; i++) {
            if (whiteList[i] == account) {
                return true;
            }
        }
        return false;
    }

    function withdrawBusd() external onlyOwner {
        uint256 amountBusd = IERC20(_exchangeToken).balanceOf(address(this));
        IERC20(_exchangeToken).transfer(owner(), amountBusd);
    }

    function getBusdBalance(address account) public view returns (uint256) {
        for (uint256 i = 0; i < _userKeys.length; i++) {
            if (_userKeys[i] == account) {
                return users[_userKeys[i]].balance * _cost;
            }
        }
        return 0;
    }

    function getWDABalance(address account) public view returns (uint256) {
        for (uint256 i = 0; i < _userKeys.length; i++) {
            if (_userKeys[i] == account) {
                return users[_userKeys[i]].balance;
            }
        }
        return 0;
    }

    function getTotalBoughtWDA() public view returns (uint256) {
        uint256 totalBought = 0;
        for (uint256 i = 0; i < _userKeys.length; i++) {
            totalBought += users[_userKeys[i]].balance;
        }
        return totalBought;
    }

    function getTotalUnboughtWDA() public view returns (uint256) {
        return _totalBalances - getTotalBoughtWDA();
    }

    function isExistAddress(address account) public view returns (bool) {
        for (uint256 i = 0; i < _userKeys.length; i++) {
            if (_userKeys[i] == account) {
                return true;
            }
        }
        return false;
    }

    modifier onlyAfterStart() {
        require(block.timestamp >= _startAt, "SEED: Not started");
        _;
    }

    modifier onlyTgeStart() {
        require(_tgeTime > 0, "SEED: TGE not start");
        _;
    }
}
