// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IPancakeRouter02.sol";
import "./IPancakeFactory.sol";
import "./Ownable.sol";

contract ScholarDogeManager is Ownable {
    struct FeeStruct {
        uint8 rewardFee;
        uint8 lpFee;
        uint8 treasuryFee;
        uint8 burnFee;
        uint8 totalFee;
    }

    struct RewardStruct {
        bool swapAndLiquifyOn;
        bool rewardsOn;
        bool burnOn;
        uint128 minToSwap;
        address rewardToken;
        uint8 swapSlippage;
        uint8 rewardSlippage;
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

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 internal requiredGas = 300000;
    
    // Used gas for withdraw, can be updated as it may change
    uint256 internal withdrawGas = 6000;
    
    uint64 internal rewardTokenCount;
    
    bool public init;
    
    uint256 public claimWait;
    uint256 public minTokensForDividends;
    
    mapping(address => bool) internal addedTokens;
    
    address[] public rewardTokens;

    FeeStruct public feeStruct;
    RewardStruct public rewardStruct;
    DexStruct public dexStruct;
    
    event UpdateDividendTracker(address indexed _dividendTracker);

    event FeeStructUpdated(
        uint8 _rewardFee,
        uint8 _lpFee,
        uint8 _treasuryFee,
        uint8 _burnFee
    );

    event RewardStructUpdated(
        bool _swapAndLiquifyOn,
        bool _rewardsOn,
        bool _burnOn,
        uint256 _minToSwap,
        address indexed _rewardToken,
        uint8 indexed _swapSlippage,
        uint8 indexed _rewardSlippage
    );

    event DexStructUpdated(address indexed _router, address indexed _pair);

    event MaxSellTxUpdated(uint256 indexed _maxSellTx);

    event MaxHoldUpdated(uint256 indexed _maxHold);

    event TreasuryUpdated(address indexed _treasury);
    
    event RequiredGasUpdated(uint256 indexed newValue);
    
    event RewardTokenAdded(address indexed rewardToken);
    
    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);
    
    event WithdrawGasUpdated(uint256 gas);
    
    event SafeLaunchDisabled();
    
    event ContractUpdateCall(uint8 indexed fnNb, uint256 indexed delay);

    event ContractUpdateCancelled(uint8 indexed fnNb);

    // Adds a security on sensible contract updates
    modifier safeContractUpdate(uint8 fnNb, uint256 delay) {
        // TODO Remove here, testing only
        _;
        /*if (pendingContractUpdates[fnNb] == 0) {
            pendingContractUpdates[fnNb] = block.timestamp + delay;

            emit ContractUpdateCall(fnNb, delay);

            return;
        } else {
            require(
                block.timestamp >= contractUpdates[fnNb],
                "$SDOGE: Too early"
            );

            pendingContractUpdates[fnNb] = 0;

            _;
        }*/
    }
    
    modifier uninitialized() {
        require(
            !init,
            "$SDOGE: Already init");

        _;

        init = true;
    }
    
    constructor() {
        // Main net: 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // Test net: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
        dexStruct.router
            = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        dexStruct.pair = IPancakeFactory(dexStruct.router.factory())
            .createPair(address(this), dexStruct.router.WETH());
        rewardStruct.rewardToken = dexStruct.router.WETH();
        
        addRewardToken(dexStruct.router.WETH());
        
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

        rewardStruct.swapAndLiquifyOn = true;
        rewardStruct.rewardsOn = true;
        rewardStruct.minToSwap
            = uint128(MAX_SUPPLY * 5 / 10 ** 5);

        treasury = _treasury;
    }
    
    function wbnb() public view returns (address) {
        return dexStruct.router.WETH();
    }

    function getRewardToken() public view returns (address) {
        return rewardStruct.rewardToken;
    }
    
    function cancelUpdate(uint8 fnNb) external onlyOwner {
        pendingContractUpdates[fnNb] = 0;

        emit ContractUpdateCancelled(fnNb);
    }

    function updateFeeStruct(
        uint8 _rewardFee,
        uint8 _lpFee,
        uint8 _treasuryFee,
        uint8 _burnFee
    )
        external
        onlyOwner
        safeContractUpdate(0, 3 days)
    {
        uint16 totalFees = _rewardFee + _lpFee + _treasuryFee + _burnFee;
        // Max fees up to 25% max
        require(
            totalFees <= 25,
            "$SDOGE: > 25"
        );

        feeStruct.rewardFee = _rewardFee;
        feeStruct.lpFee = _lpFee;
        feeStruct.treasuryFee = _treasuryFee;
        feeStruct.burnFee = _burnFee;
        feeStruct.totalFee = uint8(totalFees);

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
            "$SDOGE: 0.01% < maxSellTx < 1% (supply)"
        );

        maxSellTx = _amount;

        emit MaxSellTxUpdated(_amount);
    }

    function setMaxHoldAmount(uint256 _amount)
        external
        onlyOwner
        safeContractUpdate(4, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 1% and max to 5% total supply
        require(
            _amount >= MAX_SUPPLY / 10 ** 2 &&
            _amount <= MAX_SUPPLY * 5 / 10 ** 2,
            "$SDOGE: 1% < maxHold < 5% (supply)"
        );

        maxHold = _amount;

        emit MaxHoldUpdated(_amount);
    }

    function updateRewardStruct(
        bool _swapAndLiquifyOn,
        bool _rewardsOn,
        bool _burnOn,
        uint128 _minToSwap,
        address _rewardToken,
        uint8 _swapSlippage,
        uint8 _rewardSlippage
    )
        external
        virtual
        onlyOwner
    {
        rewardStruct.swapAndLiquifyOn = _swapAndLiquifyOn;
        rewardStruct.rewardsOn = _rewardsOn;
        rewardStruct.burnOn = _burnOn;
        rewardStruct.minToSwap = _minToSwap;
        rewardStruct.rewardToken = _rewardToken;
        rewardStruct.swapSlippage = _swapSlippage;
        rewardStruct.rewardSlippage = _rewardSlippage;
        
        addRewardToken(_rewardToken);

        emit RewardStructUpdated(
            _swapAndLiquifyOn,
            _rewardsOn,
            _burnOn,
            _minToSwap,
            _rewardToken,
            _swapSlippage,
            _rewardSlippage
        );
    }
    
    function addRewardToken(address _token) public onlyOwner {
        if (!addedTokens[_token]) {
            addedTokens[_token] = true;
            rewardTokens.push(_token);
            rewardTokenCount++;
        
            emit RewardTokenAdded(_token);
        }
    }

    function updateWithdrawGas(uint256 gas) external onlyOwner {
        require(
            gas > 0,
            "$SDOGE_DT: <= 0"
        );

        withdrawGas = gas;

        emit WithdrawGasUpdated(gas);
    }

    function updateClaimWait(uint256 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86400,
            "$SDOGE_DT: 1h < claimWait < 24h"
        );

        claimWait = newClaimWait;

        emit ClaimWaitUpdated(newClaimWait, claimWait);
    }
    
    function switchSafeLaunchOff() external onlyOwner {
        safeLaunch = false;

        emit SafeLaunchDisabled();
    }

    function updateRequiredGas(uint256 newValue) external onlyOwner {
        requiredGas = newValue;

        emit RequiredGasUpdated(newValue);
    }
    
    function _setDexStruct(address _router) virtual internal {
        dexStruct.router = IPancakeRouter02(_router);
        dexStruct.pair = IPancakeFactory(dexStruct.router.factory())
            .createPair(address(this), dexStruct.router.WETH());
    }
}
