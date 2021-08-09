// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";
import "./Ownable.sol";

abstract contract ScholarDogeConfig is Ownable {
    struct FeeStruct {
        uint256 rewardFee;
        uint256 lpFee;
        uint256 treasuryFee;
        uint256 burnFee;
        uint256 totalFee;
    }

    struct RewardStruct {
        uint256 minToSwap;
        address rewardToken;
        uint256 swapSlippage;
        uint256 rewardSlippage;
    }

    struct DexStruct {
        IPancakeRouter02 router;
        address pair;
    }
    
    uint256 internal constant MAX_SUPPLY = 1000000000 * (10**9);
    // Sells have fees of 12 and 6 (10 * 1.2 and 5 * 1.2)
    uint8 internal constant SELL_FACTOR = 120;
    
    // Securize the launch by allowing 1 sell tx / block
    // also reverting / taxing if gas price set too high
    bool public safeLaunch = true;
    
    uint32 internal rewardTokenCount;
    
    bool public init;
    
    // use by default 250,000 gas to process auto-claiming dividends
    uint256 internal claimGas = 250000;
    
    // use by default 800,000 gas to process transfer
    // avoids out of gas exception, extra gas will be refunded
    uint256 internal minTxGas = 800000;
    
    uint256 public claimWait;
    uint256 public minTokensForDividends;

    // Stores the last sells times / address
    mapping(address => uint256) internal safeLaunchSells;

    // Stores the contracts updates
    // index = function number (arbitrary)
    // value = block timestamp of the first call + delay
    mapping(uint8 => uint256) public pendingContractUpdates;

    uint256 public maxHold = MAX_SUPPLY;
    
    // Set a multi-sign wallet here
    address public treasury;
    
    uint256 public maxSellTx = MAX_SUPPLY;
    
    mapping(address => bool) internal addedTokens;
    
    address[] public rewardTokens;

    FeeStruct public feeStruct;
    RewardStruct public rewardStruct;
    DexStruct public dexStruct;
    
    event UpdateDividendTracker(address _dividendTracker);

    event FeeStructUpdated(
        uint256 _rewardFee,
        uint256 _lpFee,
        uint256 _treasuryFee,
        uint256 _burnFee
    );

    event RewardStructUpdated(
        uint256 _minToSwap,
        address indexed _rewardToken,
        uint256 _swapSlippage,
        uint256 _rewardSlippage
    );

    event DexStructUpdated(address indexed _router, address _pair);

    event MaxSellTxUpdated(uint256 _maxSellTx);

    event MaxHoldUpdated(uint256 _maxHold);
    
    event MinTokensForDividendsUpdated(uint256 _min);

    event TreasuryUpdated(address _treasury);
    
    event ClaimGasUpdated(uint256 newValue);
    
    event MinTxGasUpdated(uint256 newValue);
    
    event RewardTokenAdded(address rewardToken);

    event ClaimWaitUpdated(uint256 newValue);
    
    event SafeLaunchDisabled();
    
    event ContractUpdateCall(uint8 indexed fnNb, uint256 indexed delay);

    event ContractUpdateCancelled(uint8 indexed fnNb);

    // Adds a security on sensible contract updates
    modifier safeContractUpdate(uint8 fnNb, uint256 delay) {
        if (init) {
            if (pendingContractUpdates[fnNb] == 0) {
                pendingContractUpdates[fnNb] = block.timestamp + delay;
    
                emit ContractUpdateCall(fnNb, delay);
    
                return;
            } else {
                require(
                    block.timestamp >= pendingContractUpdates[fnNb],
                    "Update still pending"
                );
    
                pendingContractUpdates[fnNb] = 0;
    
                _;
            }
        } else {
            _;
        }
        
    }
    
    modifier uninitialized() {
        require(
            !init,
            "$SDOGE: Already init");

	init = true;
        _;
    }
    
    constructor() {
        // Main net: 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // Test net: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        dexStruct.router
            = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        dexStruct.pair = IPancakeFactory(dexStruct.router.factory())
            .createPair(address(this), dexStruct.router.WETH());
        rewardStruct.rewardToken = dexStruct.router.WETH();
        
        _addRewardToken(dexStruct.router.WETH());
        
        claimWait = 60;//3600;
        //must hold 10000+ tokens
        minTokensForDividends = 10000 * (10**9);
    }
    
    function initializeContract(address _treasury)
        public
        virtual
        onlyOwner
    {
        feeStruct.rewardFee = 10;
        feeStruct.lpFee = 3;
        feeStruct.treasuryFee = 3;
        feeStruct.burnFee = 0;
        feeStruct.totalFee = 16;

        // Arbitrary setting max slipplage
        // ensure better security than common 100%
        // will be updated depending on reward tokens
        rewardStruct.swapSlippage = 15;
        rewardStruct.rewardSlippage = 5;
        // Initialized at 0.1% totalSupply
        maxSellTx = MAX_SUPPLY * 1 / 10 ** 3;
        // Initialized to 2.5% totalSupply
        maxHold = MAX_SUPPLY * 25 / 10 ** 3;

        rewardStruct.minToSwap
            = uint128(MAX_SUPPLY * 5 / 10 ** 5);

        treasury = _treasury;
    }
    
    function wbnb() public view returns (address) {
        return dexStruct.router.WETH();
    }
    
    function cancelUpdate(uint8 fnNb) external onlyOwner {
        pendingContractUpdates[fnNb] = 0;

        emit ContractUpdateCancelled(fnNb);
    }

    function updateFeeStruct(
        uint256 _rewardFee,
        uint256 _lpFee,
        uint256 _treasuryFee,
        uint256 _burnFee
    )
        external
        onlyOwner
        safeContractUpdate(0, 3 days)
    {
        uint256 totalFees = _rewardFee + _lpFee + _treasuryFee + _burnFee;
        // Max fees up to 25% max
        require(
            totalFees <= 25,
            "totalFees > 25"
        );

        feeStruct.rewardFee = _rewardFee;
        feeStruct.lpFee = _lpFee;
        feeStruct.treasuryFee = _treasuryFee;
        feeStruct.burnFee = _burnFee;
        feeStruct.totalFee = totalFees;

        emit FeeStructUpdated(_rewardFee, _lpFee, _treasuryFee, _burnFee);
    }

    function setTreasury(address _treasury)
        external
        onlyOwner
        safeContractUpdate(1, 3 days)
    {
        treasury = _treasury;

        emit TreasuryUpdated(_treasury);
    }
    
    function updateDEXStruct(address _router)
        external
        onlyOwner
        safeContractUpdate(2, 15 days)
    {
        _setDexStruct(_router);

        emit DexStructUpdated(_router, dexStruct.pair);
    }
    
    function setMaxSellTx(uint256 _amount)
        external
        onlyOwner
        safeContractUpdate(3, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 0.01% and max to 1% total supply
        require(
            _amount >= MAX_SUPPLY / 10 ** 4 &&
            _amount <= MAX_SUPPLY / 10 ** 2,
            "0.01% < maxSellTx < 1% (supply)"
        );

        maxSellTx = _amount;

        emit MaxSellTxUpdated(_amount);
    }
    
    function setMinTokensForDividends(uint64 _min)
        external
        onlyOwner
        safeContractUpdate(4, 3 days)
    {
        require(_min > 0, "min == 0");
        require(_min <= MAX_SUPPLY / 100, "min > 1% supply");
        
        minTokensForDividends = _min;
        
        emit MinTokensForDividendsUpdated(_min);
    }

    function setMaxHoldAmount(uint256 _amount)
        external
        onlyOwner
        safeContractUpdate(5, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 1% and max to 5% total supply
        require(
            _amount >= MAX_SUPPLY / 10 ** 2 &&
            _amount <= MAX_SUPPLY * 5 / 10 ** 2,
            "1% < maxHold < 5% (supply)"
        );

        maxHold = _amount;

        emit MaxHoldUpdated(_amount);
    }

    function updateRewardStruct(
        uint128 _minToSwap,
        address _rewardToken,
        uint256 _swapSlippage,
        uint256 _rewardSlippage
    )
        external
        onlyOwner
    {
        rewardStruct.minToSwap = _minToSwap;
        rewardStruct.rewardToken = _rewardToken;
        rewardStruct.swapSlippage = _swapSlippage;
        rewardStruct.rewardSlippage = _rewardSlippage;
        
        _addRewardToken(_rewardToken);

        emit RewardStructUpdated(
            _minToSwap,
            _rewardToken,
            _swapSlippage,
            _rewardSlippage
        );
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86400,
            "1h < claimWait < 24h"
        );

        claimWait = newClaimWait;

        emit ClaimWaitUpdated(newClaimWait);
    }
    
    function switchSafeLaunchOff() external onlyOwner {
        safeLaunch = false;

        emit SafeLaunchDisabled();
    }

    function updateClaimGas(uint256 newValue) external onlyOwner {
        claimGas = newValue;

        emit ClaimGasUpdated(newValue);
    }
    
    function updateMinTxGas(uint256 newValue) external onlyOwner {
        minTxGas = newValue;

        emit MinTxGasUpdated(newValue);
    }
    
    function _addRewardToken(address _token) internal {
        if (!addedTokens[_token]) {
            addedTokens[_token] = true;
            rewardTokens.push(_token);
            rewardTokenCount++;
        
            emit RewardTokenAdded(_token);
        }
    }
    
    function _setDexStruct(address _router) virtual internal {
        dexStruct.router = IPancakeRouter02(_router);
        dexStruct.pair = IPancakeFactory(dexStruct.router.factory())
            .createPair(address(this), dexStruct.router.WETH());
    }
}
