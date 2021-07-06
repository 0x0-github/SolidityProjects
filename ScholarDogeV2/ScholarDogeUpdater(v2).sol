// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";
import "./SafeMath.sol";

contract ScholarDogeUpdater is Ownable {
    using SafeMath for uint256;

    uint256 public constant SUPPLY = 1000000000 * (10**18);
    
    uint8 private _rewardFee;
    uint8 private _liquidityFee;
    uint8 private _treasuryFee;
    uint8 private _burnFee;

    bool private _swapAndLiquifyEnabled;
    bool private _rewardSystemEnabled;
    bool private _burnSystemEnabled;
    bool private _initialized;
    
    uint128 private _minToSwap;
    address private _rewardToken;
    
    uint256 private _maxSellTxAmount = SUPPLY;
    uint256 private _maxHoldAmount = SUPPLY;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 private _gasForProcessing = 300000;
    
    // Set a multi-sign wallet here
    address private _treasury;

    // Stores the contracts updates
    // index = function number (arbitrary)
    // value = block timestamp of the first call + delay
    mapping (uint8 => uint256) private _contractUpdateQueue;
    
    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    event RewardFeeUpdated(uint8 fee);
    
    event LiquidityFeeUpdated(uint8 fee);
    
    event TreasuryFeeUpdated(uint8 fee);
    
    event BurnFeeUpdated(uint8 fee);
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    
    event RewardSystemEnabledUpdated(bool enabled);
    
    event BurnSystemEnabledUpdated(bool enabled);
    
    event MinToSwapUpdated(uint128 min);
    
    event RewardTokenUpdated(address token);
    
    event MaxSellTxAmountUpdated(uint256 maxSellTxAmount);
    
    event MaxHoldAmountUpdated(uint256 maxHoldAmount);
    
    event TreasuryUpdated(address treasury);
    
    event ExcludeFromFees(address indexed account, bool isExcluded);
    
    event GasForProcessingUpdated(uint256 indexed value);
    
    event ContractUpdateCall(uint8 indexed fnNb, uint256 indexed delay);

    event ContractUpdateCancelled(uint8 indexed fnNb);

    // Adds a security on sensible contract updates
    modifier safeContractUpdate(uint8 fnNb, uint256 delay) {
        if (_contractUpdateQueue[fnNb] == 0) {
            _contractUpdateQueue[fnNb] = block.timestamp + delay;

            emit ContractUpdateCall(fnNb, delay);
        } else {
            require(
                block.timestamp >= _contractUpdateQueue[fnNb], 
                "ScholarDogeUpdater: Delay for update still pending"
            );
            
            _contractUpdateQueue[fnNb] = 0;
            
            _;
        }
    }
    
    modifier onlyInit() {
        require(
            !_initialized,
            "ScholarDogeUpdater: Contract already initialized");

        _;
        
        _initialized = true;
    }
    
    constructor() {
    }
    
    function initializeContract(address sdoge, address treasury)
        public
        onlyOwner
    {
  	    _rewardFee = 4;
        _liquidityFee = 4;
        _treasuryFee = 3;
        _burnFee = 1;

        // Initialized at 0.5% totalSupply
        _maxSellTxAmount = SUPPLY.mul(5).div(10 ** 3);
        // Initialized to 2.5% totalSupply
        _maxHoldAmount = SUPPLY.mul(25).div(10 ** 3);

        _swapAndLiquifyEnabled = true;
        _minToSwap = uint128(SUPPLY.div(10 ** 4));
        // Default to 0x0 => BNB
        _rewardToken = address(0x0);
        _treasury = treasury;
        _isExcludedFromFees[sdoge] = true;
  	}
  	
  	function setRewardFee(uint8 rewardFee_)
        external
        onlyOwner
        safeContractUpdate(0, 3 days)
    {
        _rewardFee = rewardFee_;
        
        _validateFees();
        
        emit RewardFeeUpdated(rewardFee_);
    }
    
    function setLiquidityFee(uint8 liquidityFee_)
        external
        onlyOwner
        safeContractUpdate(1, 3 days)
    {
        _liquidityFee = liquidityFee_;
        
        _validateFees();
        
        emit LiquidityFeeUpdated(liquidityFee_);
    }
    
    function setTreasuryFee(uint8 treasuryFee_)
        external
        onlyOwner
        safeContractUpdate(2, 3 days)
    {
        _treasuryFee = treasuryFee_;
        
        _validateFees();
        
        emit TreasuryFeeUpdated(treasuryFee_);
    }
    
    function setBurnFee(uint8 burnFee_)
        external
        onlyOwner
        safeContractUpdate(3, 3 days)
    {
        _burnFee = burnFee_;
        
        _validateFees();
        
        emit BurnFeeUpdated(burnFee_);
    }
    
    function excludeFromFees(address account, bool excluded)
        public
        onlyOwner
        safeContractUpdate(4, 3 days)
    {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function setMaxSellTxAmount(uint256 amount)
        public
        onlyOwner
        safeContractUpdate(5, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 0.01%
        require(
            amount >= SUPPLY.div(10 ** 4),
            "ScholarDogeUpdater: max sell tx amount too low"
        );
        // Max to 1%
        require(
            amount <= SUPPLY.div(10 ** 2),
            "ScholarDogeUpdater: max sell tx amount too high"
        );
        
        _maxSellTxAmount = amount;
        
        emit MaxSellTxAmountUpdated(amount);
    }
    
    function setMaxHoldAmount(uint256 amount)
        public
        onlyOwner
        safeContractUpdate(6, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 1% total supply
        require(
            amount >= SUPPLY.div(10 ** 2),
            "ScholarDogeUpdater: max sell tx amount too low"
        );
        // Max to 5%
        require(
            amount <= SUPPLY.mul(5).div(10 ** 2),
            "ScholarDogeUpdater: max sell tx amount too high"
        );
        
        _maxHoldAmount = amount;
        
        emit MaxHoldAmountUpdated(amount);
    }
    
    function setTreasury(address treasury)
        external
        onlyOwner
        safeContractUpdate(7, 3 days)
    {
        _treasury = treasury;
        
        emit TreasuryUpdated(treasury);
    }
    
    function setSwapAndLiquifyEnabled(bool enabled)
        external
        onlyOwner
    {
        _swapAndLiquifyEnabled = enabled;
        
        emit SwapAndLiquifyEnabledUpdated(enabled);
    }
    
    function setRewardSystemEnabled(bool enabled) external onlyOwner {
        _rewardSystemEnabled = enabled;
        
        emit RewardSystemEnabledUpdated(enabled);
    }
    
    function setBurnSystemEnabled(bool enabled) external onlyOwner {
        _burnSystemEnabled = enabled;
        
        emit BurnSystemEnabledUpdated(enabled);
    } 
    
    function setMinToSwap(uint128 minToSwap_) external onlyOwner {
        require(minToSwap_ > 0, "ScholarDogeUpdater: Can't swap at 0");
        
        _minToSwap = minToSwap_;
        
        emit MinToSwapUpdated(minToSwap_);
    }
    
    function setRewardToken(address token) external onlyOwner {
        // TODO Check address != $SDOGE
        
        _rewardToken = token;
        
        emit RewardTokenUpdated(token);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        _gasForProcessing = newValue;
        
        emit GasForProcessingUpdated(newValue);
    }
    
    function rewardFee() public view returns (uint8) {
        return _rewardFee;
    }
    
    function treasuryFee() public view returns (uint8) {
        return _treasuryFee;
    }
    
    function burnFee() public view returns (uint8) {
        return _burnFee;
    }
    
    function swapAndLiquifyEnabled() public view returns (bool) {
        return _swapAndLiquifyEnabled;
    }
    
    function rewardSystemEnabled() public view returns (bool) {
        return _rewardSystemEnabled;
    }
    
    function burnSystemEnabled() public view returns (bool) {
        return _burnSystemEnabled;
    }
    
    function minToSwap() public view returns (uint128) {
        return _minToSwap;
    }
    
    function rewardToken() public view returns (address) {
        return _rewardToken;
    }
    
    function maxSellTxAmount() public view returns (uint256) {
        return _maxSellTxAmount;
    }
    
    function maxHoldAmount() public view returns (uint256) {
        return _maxHoldAmount;
    }
    
    function gasForProcessing() public view returns (uint256) {
        return _gasForProcessing;
    }
    
    function treasury() public view returns (address) {
        return _treasury;
    }
    
    function isExcludedFromFees(address account)
        public
        view
        returns (bool)
    {
        return _isExcludedFromFees[account];
    }
    
    function totalFees() public view returns (uint8) {
        return _rewardFee + _liquidityFee + _treasuryFee + _burnFee;
    }
    
    function _validateFees() private view {
        // Max fees up to 20% max
        require(
            totalFees() <= 20,
            "ScholarDogeUpdater: Total fees should be <= 20"
        );
    }
}
