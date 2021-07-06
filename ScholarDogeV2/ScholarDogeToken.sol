// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ScholarDogeDividendTracker.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./BEP20.sol";
import "./IPancakePair.sol";
import "./IPancakeFactory.sol";
import "./IPancakeRouter02.sol";
import "./ScholarDogeTeamTimelock.sol";

contract ScholarDogeToken is BEP20, Ownable {
    using SafeMath for uint256;

    struct FeeStructure {
        uint8 rewardFee;
        uint8 liquidityFee;
        uint8 treasuryFee;
        uint8 burnFee;
        uint8 totalFees;
    }
    
    struct RewardStructure {
        bool swapAndLiquifyEnabled;
        bool rewardsEnabled;
        bool burnEnabled;
        uint128 minToSwap;
        address rewardToken;
    }

    struct DexStructure {
        // Using Uniswap V2 router specs (PCS for now)
        IPancakeRouter02 router;
        address pair;
    }
    
    uint256 public constant SUPPLY = 1000000000 * (10**18);
    
    // Stores the contracts updates
    // index = function number (arbitrary)
    // value = block timestamp of the first call + delay
    mapping (uint8 => uint256) public contractUpdateQueue;
    
    uint256 public maxHoldAmount = SUPPLY;
    
    // Set a multi-sign wallet here
    address public treasury = 0x11111112542D85B3EF69AE05771c2dCCff4fAa26;

    // sells have fees of 12 and 6 (10 * 1.2 and 5 * 1.2)
    uint256 public constant SELL_INCREASE_FACTOR = 120;
    bool private swapping;

    uint256 public maxSellTxAmount = SUPPLY;

    // use by default 300,000 gas to process auto-claiming dividends
    uint256 public gasForProcessing = 300000;
    
    FeeStructure public feeStructure;
    RewardStructure public rewardStructure;
    DexStructure public dexStructure;

    ScholarDogeTeamTimelock public teamTimelock;
    ScholarDogeDividendTracker public dividendTracker;

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;

    // store addresses that a automatic market maker pairs.
    // Any transfer *to* these addresses could be subject
    // to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;
    
    event UpdateDividendTracker(address indexed _dividendTracker);
    
    event FeeStructureUpdated(
        uint8 _rewardFee,
        uint8 _liquidityFee,
        uint8 _treasuryFee,
        uint8 _burnFee
    );
    
    event RewardStructureUpdated(
        bool _swapAndLiquifyEnabled,
        bool _rewardsEnabled,
        bool _burnEnabled,
        uint256 indexed _minToSwap,
        address indexed _rewardToken
    );

    event DexStructureUpdated(address indexed _router, address indexed _pair);
    
    event MaxSellTxAmountUpdated(uint256 indexed _maxSellTxAmount);
    
    event MaxHoldAmountUpdated(uint256 indexed _maxHoldAmount);
    
    event TreasuryUpdated(address indexed _treasury);

    event ExcludeFromFees(address indexed account, bool isExcluded);
    
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);

    event GasForProcessingUpdated(uint256 indexed newValue);

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    event SendDividends(
    	uint256 tokensSwapped,
    	uint256 amount
    );
    
    event ProcessedDividendTracker(
    	uint256 iterations,
    	uint256 claims,
        uint256 lastProcessedIndex,
    	bool indexed automatic,
    	uint256 gas,
    	address indexed processor
    );
    
    event MigrateLiquidity(
        uint256 indexed tokenAmount,
        uint256 indexed bnbAmount,
        address indexed newAddress
    );

    event ContractUpdateCall(uint8 indexed fnNb, uint256 indexed delay);

    event ContractUpdateCancelled(uint8 indexed fnNb);

    // Adds a security on sensible contract updates
    modifier safeContractUpdate(uint8 fnNb, uint256 delay) {
        if (contractUpdateQueue[fnNb] == 0) {
            contractUpdateQueue[fnNb] = block.timestamp + delay;

            emit ContractUpdateCall(fnNb, delay);
        } else {
            require(
                block.timestamp >= contractUpdateQueue[fnNb], 
                "Delay for update still pending"
            );
            
            contractUpdateQueue[fnNb] = 0;
            
            _;
        }
    }

    constructor() BEP20("ScholarDoge", "$SDOGE") {
        // Main net: 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        // Test net: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    	IPancakeRouter02 _router
    	    = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
         // Create a uniswap pair for this new token
        address _pair = IPancakeFactory(_router.factory())
            .createPair(address(this), _router.WETH());

        dexStructure.router = _router;
        dexStructure.pair = _pair;
        
        dividendTracker = new ScholarDogeDividendTracker();
        
        dividendTracker.excludeFromDividends(address(dividendTracker));
        dividendTracker.excludeFromDividends(address(this));
        dividendTracker.excludeFromDividends(address(_router));
        
        _setAutomatedMarketMakerPair(_pair, true);

        // exclude from paying fees or having max transaction amount
        excludeFromFees(address(this), true);
        
        // Init supply alloc
        uint256 teamAlloc = 0;
        uint256 marketingAlloc = 0;
	    uint256 airdropFoundationAlloc = 0;
	    uint256 devFoundationAlloc = 0;
	    uint256 burnFoundationAlloc = 0;
        uint256 alloc = SUPPLY.sub(teamAlloc).sub(marketingAlloc)
	        .sub(airdropFoundationAlloc).sub(devFoundationAlloc)
	        .sub(burnFoundationAlloc);
        
        teamTimelock = new ScholarDogeTeamTimelock(this, _msgSender());

        _mint(owner(), alloc);
        _mint(address(teamTimelock), teamAlloc);
        // Hardcode marketing address here only used here
        _mint(address(0x1), SUPPLY);
    }

    receive() external payable {

  	}
  	
  	function initializeContract() public onlyOwner {
  	    feeStructure.rewardFee = 4;
        feeStructure.liquidityFee = 4;
        feeStructure.treasuryFee = 3;
        feeStructure.burnFee = 1;
        feeStructure.totalFees = 12;

        // Initialized at 0.5% totalSupply
        maxSellTxAmount = SUPPLY.mul(5).div(10 ** 3);
        // Initialized to 2.5% totalSupply
        maxHoldAmount = SUPPLY.mul(25).div(10 ** 3);

        rewardStructure.swapAndLiquifyEnabled = true;
        rewardStructure.rewardsEnabled = true;
        rewardStructure.minToSwap
            = uint128(SUPPLY.div(10 ** 4));
        // Default to 0x0 => BNB
        rewardStructure.rewardToken = address(0x0);
  	}
  	
  	// Testing purposes only
    function initLiquidity() external payable onlyOwner {
        _transfer(_msgSender(), address(this),
            balanceOf(_msgSender()).div(2));
        
        _addLiquidity(balanceOf(address(this)), msg.value);
    }
  	
  	function withdrawTeamTokens()
  	    external
  	    virtual
  	    onlyOwner
  	{
        teamTimelock.release();
    }
    
    function cancelContractUpdate(uint8 fnNb) external onlyOwner {
        contractUpdateQueue[fnNb] = 0;
        
        emit ContractUpdateCancelled(fnNb);
    }
    
    function updateFeeStructure(
        uint8 _rewardFee,
        uint8 _liquidityFee,
        uint8 _treasuryFee,
        uint8 _burnFee
    )
        external
        onlyOwner
        safeContractUpdate(0, 3 days)
    {
        uint16 totalFees = _rewardFee + _liquidityFee + _treasuryFee
            + _burnFee;
        // Max fees up to 20% max
        require(
            totalFees <= 20,
            "$SDOGE: Total fees should be <= 20"
        );
        
        feeStructure.rewardFee = _rewardFee;
        feeStructure.liquidityFee = _liquidityFee;
        feeStructure.treasuryFee = _treasuryFee;
        feeStructure.burnFee = _burnFee;
        feeStructure.totalFees = uint8(totalFees);
        
        emit FeeStructureUpdated(_rewardFee, _liquidityFee, _treasuryFee, _burnFee);
    }
    
    function setTreasury(address _treasury)
        external
        onlyOwner
        safeContractUpdate(1, 3 days)
    {
        treasury = _treasury;
        
        emit TreasuryUpdated(_treasury);
    }
    
    function setDividendTracker(address newAddress)
        public
        onlyOwner
        safeContractUpdate(2, 3 days)
    {
        ScholarDogeDividendTracker newDividendTracker
            = ScholarDogeDividendTracker(payable(newAddress));

        require(
            newDividendTracker.owner() == address(this),
            "$SDOGE: Dividend tracker must be owned by the $SDOGE contract");

        newDividendTracker.excludeFromDividends(address(newDividendTracker));
        newDividendTracker.excludeFromDividends(address(this));
        newDividendTracker.excludeFromDividends(address(dexStructure.router));

        emit UpdateDividendTracker(newAddress);
    }
    
    function updateDexStructure(address _router)
        external
        onlyOwner
        safeContractUpdate(3, 15 days)
    {
        _setDexStructure(_router);
        
        emit DexStructureUpdated(_router, dexStructure.pair);
    }
    
    function migrateLiquidity(address _router)
        external
        onlyOwner
        safeContractUpdate(4, 15 days)
    {
        (uint256 tokenReceived, uint256 bnbReceived) = _removeLiquidity();
        
        _setDexStructure(_router);
        _addLiquidity(tokenReceived, bnbReceived);
        
        emit MigrateLiquidity(tokenReceived, bnbReceived, _router);
    }
    
    function excludeFromFees(
        address account,
        bool excluded
    )
        public
        onlyOwner
        safeContractUpdate(5, 3 days)
    {
        _isExcludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function setMaxSellTxAmount(uint256 _amount)
        public
        onlyOwner
        safeContractUpdate(6, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 0.01%
        require(
            _amount >= SUPPLY.div(10 ** 4),
            "$SDOGE: max sell tx amount too low"
        );
        // Max to 1%
        require(
            _amount <= SUPPLY.div(10 ** 2),
            "$SDOGE: max sell tx amount too high"
        );
        
        maxSellTxAmount = _amount;
        
        emit MaxSellTxAmountUpdated(_amount);
    }
    
    function setMaxHoldAmount(uint256 _amount)
        public
        onlyOwner
        safeContractUpdate(7, 3 days)
    {
        // Protect users from being unable to sell their tokens
        // Min to 1% total supply
        require(
            _amount >= SUPPLY.mul(5).div(10 ** 3),
            "$SDOGE: max sell tx amount too low"
        );
        // Max to 5%
        require(
            _amount <= SUPPLY.mul(5).div(10 ** 2),
            "$SDOGE: max sell tx amount too high"
        );
        
        maxHoldAmount = _amount;
        
        emit MaxHoldAmountUpdated(_amount);
    }
    
    function updateRewardStructure(
        bool _swapAndLiquifyEnabled,
        bool _rewardsEnabled,
        bool _burnEnabled,
        uint128 _minToSwap,
        address _rewardToken
    )
        external
        onlyOwner
    {
        require(_minToSwap > 0, "$SDOGE: Can't swap at 0");
        
        rewardStructure.swapAndLiquifyEnabled = _swapAndLiquifyEnabled;
        rewardStructure.rewardsEnabled = _rewardsEnabled;
        rewardStructure.burnEnabled = _burnEnabled;
        rewardStructure.minToSwap = _minToSwap;
        rewardStructure.rewardToken = _rewardToken;

        emit RewardStructureUpdated(
            _swapAndLiquifyEnabled,
            _rewardsEnabled,
            _burnEnabled,
            _minToSwap,
            _rewardToken
        );
    }

    function setAutomatedMarketMakerPair(
        address _pair,
        bool value
    )
        public
        onlyOwner
    {
        require(
            _pair != dexStructure.pair,
            "$SDOGE: Current pair cannot be removed"
        );

        _setAutomatedMarketMakerPair(_pair, value);
        
        emit SetAutomatedMarketMakerPair(_pair, value);
    }

    function updateGasForProcessing(uint256 newValue) public onlyOwner {
        gasForProcessing = newValue;
        
        emit GasForProcessingUpdated(newValue);
    }
    
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function getAccountDividendsInfo(address account)
        external 
        view 
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return dividendTracker.getAccount(account);
    }

	function getAccountDividendsInfoAtIndex(uint256 index)
        external 
        view 
        returns (
            address,
            int256,
            int256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
    	return dividendTracker.getAccountAtIndex(index);
    }

	function processDividendTracker(uint256 gas) external {
	    (
		    uint256 iterations,
		    uint256 claims,
		    uint256 lastProcessedIndex
		 ) = dividendTracker.process(gas);
		
		emit ProcessedDividendTracker(
		    iterations,
		    claims,
		    lastProcessedIndex,
		    false,
		    gas,
		    tx.origin
		);
    }

    function claim() external {
		dividendTracker.processAccount(payable(msg.sender), false);
    }

    function getLastProcessedIndex() external view returns(uint256) {
    	return dividendTracker.getLastProcessedIndex();
    }

    function getNumberOfDividendTokenHolders() external view returns(uint256) {
        return dividendTracker.getNumberOfTokenHolders();
    }
    
    function t(address from,
        address to,
        uint256 amount) public {
        super._transfer(from, to, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        if (amount == 0) {
            super._transfer(from, to, 0);
            
            return;
        }
        
        if (
            !swapping &&
            automatedMarketMakerPairs[to] &&
        	from != address(dexStructure.router) &&
            !_isExcludedFromFees[to]
        ) {
            require(
                amount <= maxSellTxAmount,
                "$SDOGE: Amount exceeds the maxSellTxAmount."
            );
        }

	    uint256 contractTokenBalance = balanceOf(address(this));
        
        bool overMinSwap = contractTokenBalance >= rewardStructure.minToSwap;

        if (
            overMinSwap &&
            !swapping &&
            !automatedMarketMakerPairs[from] &&
            from != address(this) &&
            to != address(this)
        ) {
            swapping = true;

            if (rewardStructure.swapAndLiquifyEnabled) {
                uint256 swapTokens = contractTokenBalance
                    .mul(feeStructure.liquidityFee).div(feeStructure.totalFees);

                _swapAndLiquify(swapTokens);
            }

            if (rewardStructure.rewardsEnabled) {
                uint256 rewardTokens = contractTokenBalance
                    .mul(feeStructure.rewardFee).div(feeStructure.totalFees);
                    
                _swapAndSendDividends(rewardTokens);
            }

            swapping = false;
        }

        bool takeFee = !swapping;

        // if any account belongs to _isExcludedFromFee then remove the fee
        // can be used later for the lottery
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 treasuryFee = amount.mul(feeStructure.treasuryFee).div(100);
            uint256 burnFee = amount.mul(feeStructure.burnFee).div(100);
        	uint256 conversionFees = amount.mul(feeStructure.liquidityFee
        	    + feeStructure.rewardFee).div(100);

            // if sell, multiply by 1.2
            if (automatedMarketMakerPairs[to]) {
                treasuryFee = treasuryFee.mul(SELL_INCREASE_FACTOR).div(100);
                burnFee = burnFee.mul(SELL_INCREASE_FACTOR).div(100);
                conversionFees = conversionFees.mul(SELL_INCREASE_FACTOR).div(100);
            }

        	amount = amount.sub(treasuryFee).sub(burnFee).sub(conversionFees);
        	
        	// Restricting the max token users can hold
        	require(
        	    this.balanceOf(to).add(amount) <= maxHoldAmount,
        	    "$SDOGE: Reaching max hold amount"
        	);

            super._transfer(from, address(this), conversionFees);
            super._transfer(from, treasury, treasuryFee);
            
            if (rewardStructure.burnEnabled) {
                super._transfer(
                    from,
                    0x000000000000000000000000000000000000dEaD,
                    burnFee
                );
            }
        }

        super._transfer(from, to, amount);

        if (rewardStructure.rewardsEnabled) {
            try dividendTracker.setBalance(payable(from), balanceOf(from)) {} catch {}
            try dividendTracker.setBalance(payable(to), balanceOf(to)) {} catch {}
    
            if(!swapping) {
    	    	uint256 gas = gasForProcessing;
    
    	    	try dividendTracker.process(gas) returns (uint256 iterations, uint256 claims, uint256 lastProcessedIndex) {
    	    		emit ProcessedDividendTracker(iterations, claims, lastProcessedIndex, true, gas, tx.origin);
    	    	} catch {}
            }
        }
    }
    
    function _setAutomatedMarketMakerPair(
        address pair,
        bool value
    )
        private
    {
        automatedMarketMakerPairs[pair] = value;

        if (value) 
            dividendTracker.excludeFromDividends(pair);
    }
    
    function _setDexStructure(address _router) private {
        dexStructure.router = IPancakeRouter02(_router);
        dexStructure.pair = IPancakeFactory(dexStructure.router.factory())
            .createPair(address(this), dexStructure.router.WETH());
            
        dividendTracker.excludeFromDividends(_router);
    }

    function _swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        _swapTokensForBnb(half);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to dex
        _addLiquidity(otherHalf, newBalance);
        
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForBnb(
        uint256 tokenAmount
    )
        private
    {
        // generate the dex pair path of token -> wbnb
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = dexStructure.router.WETH();

        _approve(address(this), address(dexStructure.router), tokenAmount);

        // make the swap
        dexStructure.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }

    function _removeLiquidity()
        private
        returns (uint256 amountToken, uint256 amountBnb)
    {
        bool result = IBEP20(dexStructure.pair).approve(address(dexStructure.router),
                IBEP20(dexStructure.pair).balanceOf(address(this)));
                
        require(result, "$SDOGE: Approve pair failed");
            
        return dexStructure.router.removeLiquidityETH(
            address(this),
            IBEP20(dexStructure.pair).balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(dexStructure.router), tokenAmount);

        // add the liquidity and adds the tokens to a lock contract
        // so it will be easier to migrate lps if needed
        dexStructure.router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _swapAndSendDividends(uint256 tokens) private {
        _swapTokensForBnb(tokens);

        uint256 dividends = address(this).balance;
        (bool success,) = address(dividendTracker).call{value: dividends}("");

        if(success) {
   	 		emit SendDividends(tokens, dividends);
        }
    }
}

