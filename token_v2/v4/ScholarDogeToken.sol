// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./ScholarDogeTeamTimelock.sol";
import "./IPancakePair.sol";
import "./ScholarDogeManager.sol";
import "./BEP20.sol";
import "./SafeMath.sol";
import "./SignedSafeMath.sol";
import "./IterableMapping.sol";

contract ScholarDogeToken2 is BEP20, ScholarDogeManager {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using IterableMapping for IterableMapping.Map;

    uint256 constant internal magnitude = 2**128;
    
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    
    uint256 public totalCollected;
    
    ScholarDogeTeamTimelock public teamTimelock;

    bool private swapping;
    
    // Below are associated to the reward tokens (first key)
    mapping(address => uint256) internal magnifiedDividendPerShare;
    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;

    mapping(address => mapping(address => uint256))
        internal withdrawnDividends;
    mapping(address => uint256) internal totalDividendsDistributed;
    
    mapping(address => bool) public automatedMarketMakerPairs;
    mapping(address => bool) public excludedFromFees;
    mapping(address => bool) public excludedFromDividends;

    mapping(address => mapping(address => uint256)) internal lastClaimTimes;
    
    event ExcludeFromFees(address indexed _account, bool _excluded);
    
    event ExcludeFromDividends(address indexed account);

    event SetAutomatedMarketMakerPair(
        address indexed _pair,
        bool indexed _value
    );
    
    event MigrateLiquidity(
        uint256 indexed tokenAmount,
        uint256 indexed bnbAmount,
        address indexed newAddress
    );

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 bnbReceived,
        uint256 addedLp
    );

    event SendDividends(
        uint256 tokens,
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
    
    event DividendWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );

    event DividendsDistributed(
        address indexed token,
        address indexed from,
        uint256 amount
    );
    
    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    constructor() BEP20("ScholarDoge", "$SDOGE") {
        // TODO Exclude from dividends the deployer
        excludeFromDividends(address(this));
        excludeFromDividends(address(0x0));
        excludeFromDividends(address(dexStruct.router));

        _addAMMPair(dexStruct.pair, true);

        teamTimelock = new ScholarDogeTeamTimelock(this, _msgSender());

        // TODO Exclude from fee the deployer
        // TODO Exclude marketing / foundation as well
        excludedFromFees[address(this)] = true;
        excludedFromFees[address(teamTimelock)] = true;
        excludedFromFees[owner()] = true;
    }

    receive() external payable {

    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }

    function initializeContract(address _treasury)
        public
        override
        onlyOwner
        uninitialized
    {
        super.initializeContract(_treasury);
        
        // Treasury will not be taxed as used for charities
        excludedFromFees[treasury] = true;
        excludedFromFees[owner()] = false;
    }
    
    function initSupply() external {
        require(
		    totalSupply() == 0,
		    "$SDOGE: Supply already Initialized"
	    );
        
        // Supply alloc
        // 8.4% Private sale - 42% Presale - (29.4% Liquidity
        // 5%
        uint256 teamAlloc = MAX_SUPPLY * 5 / 100;
        // 5.2%
        uint256 marketingAlloc = MAX_SUPPLY * 52 / 1000;
        // 10%
        uint256 foundationAlloc = MAX_SUPPLY * 10 / 100;
        
        _mint(owner(), MAX_SUPPLY);
        _transfer(owner(), address(teamTimelock), teamAlloc);
        // Hardcode marketing / foundation multisig here only used here
        _transfer(owner(), address(0x1), marketingAlloc);
        _transfer(owner(), address(0x2), foundationAlloc);
    }

    // TODO Remove, Testing purposes only
    function initLiquidity() external payable onlyOwner {
        _transfer(_msgSender(), address(this),
            balanceOf(_msgSender()) / 2);

        _addLiquidity(balanceOf(address(this)), msg.value);
    }

    function withdrawTeamTokens()
        external
        virtual
        onlyOwner
    {
        teamTimelock.release();
    }

    function excludeFromFees(
        address account,
        bool excluded
    )
        external
        onlyOwner
        safeContractUpdate(6, 3 days)
    {
        excludedFromFees[account] = excluded;

        emit ExcludeFromFees(account, excluded);
    }
    
    function excludeFromDividends(address account)
        public
        onlyOwner
        safeContractUpdate(7, 3 days)
    {
        require(!excludedFromDividends[account]);

        excludedFromDividends[account] = true;

        magnifiedDividendCorrections[getRewardToken()][account]
            += (magnifiedDividendPerShare[account]
                * balanceOf(account)).toInt256Safe();
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function setAutomatedMarketMakerPair(
        address _pair,
        bool value
    )
        external
        onlyOwner
    {
        require(
            _pair != dexStruct.pair,
            "$SDOGE: Can't remove current"
        );

        _addAMMPair(_pair, value);

        emit SetAutomatedMarketMakerPair(_pair, value);
    }
    
    function executeLiquidityMigration(address _router)
        external
        onlyOwner
        safeContractUpdate(5, 15 days)
    {
        (uint256 tokenReceived, uint256 bnbReceived) = _removeLiquidity();

        _setDexStruct(_router);
        _addLiquidity(tokenReceived, bnbReceived);

        emit MigrateLiquidity(tokenReceived, bnbReceived, _router);
    }

    function executeDividends() public {
        (
            uint256 iterations,
            uint256 claims,
            uint256 lastIndex
        ) = process();

        emit ProcessedDividendTracker(
            iterations,
            claims,
            lastIndex,
            false,
            requiredGas,
            tx.origin
        );
    }

    function claimDividends(address token) external {
        processAccount(
            payable(msg.sender),
            token,
            false
        );
    }
    
    function withdrawableDividendOf(address _owner, address _token)
        public
        view
        returns (uint256)
    {
        return accumulativeDividendOf(_owner, _token)
            - withdrawnDividends[_token][_owner];
    }
    
    function withdrawnDividendOf(address _owner, address _token)
        public
        view
        returns (uint256)
    {
        return withdrawnDividends[_token][_owner];
    }

    function accumulativeDividendOf(address _owner, address _token)
        public
        view
        returns (uint256)
    {
        return ((magnifiedDividendPerShare[_token] * balanceOf(_owner)).toInt256Safe()
            + magnifiedDividendCorrections[_token][_owner]).toUint256Safe() / magnitude;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }
    
    function getAccount(address _account, address _token)
        public
        view
        returns (
            address account,
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        account = _account;
        index = tokenHoldersMap.getIndexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index - int256(lastProcessedIndex);
            } else {
                uint256 processesUntilEndOfArray
                    = tokenHoldersMap.keys.length > lastProcessedIndex ?
                        tokenHoldersMap.keys.length - lastProcessedIndex : 0;

                iterationsUntilProcessed
                    = index + int256(processesUntilEndOfArray);
            }
        }

        withdrawableDividends
            = withdrawableDividendOf(account, _token);
        totalDividends
            = accumulativeDividendOf(account, _token);
        lastClaimTime = lastClaimTimes[_token][account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime + claimWait : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
            nextClaimTime - block.timestamp : 0;
    }
    
    function process() public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        uint256 gasLeft = gasleft();

        if (gasLeft < requiredGas || numberOfTokenHolders == 0)
            return (0, 0, lastProcessedIndex);

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < requiredGas && iterations < numberOfTokenHolders) {
            lastProcessedIndex++;

            if (lastProcessedIndex >= tokenHoldersMap.keys.length)
                lastProcessedIndex = 0;

            address account = tokenHoldersMap.keys[lastProcessedIndex];

            if (_canAutoClaim(lastClaimTimes[getRewardToken()][account]))
                if (processAccount(payable(account), getRewardToken(), true))
                    claims++;

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft)
                gasUsed = gasUsed + gasLeft - newGasLeft;

            gasLeft = newGasLeft;
        }

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(
        address payable account,
        address token,
        bool automatic
    )
        public
        onlyOwner
        returns (bool)
    {
        uint256 amount = _withdrawDividendOfUser(account, token);

        if (amount > 0) {
            lastClaimTimes[token][account] = block.timestamp;

            emit Claim(account, amount, automatic);

            return true;
        }

        return false;
    }

    function _canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp - lastClaimTime >= claimWait;
    }
    
    function _setDexStruct(address _router) override internal {
        super._setDexStruct(_router);

        excludeFromDividends(_router);
        _addAMMPair(dexStruct.pair, true);
    }
    
    function _updateShareAndTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
    {
        super._transfer(from, to, amount);
        
        int256 _magCorrection
            = (magnifiedDividendPerShare[getRewardToken()] * amount)
                .toInt256Safe();
        
        magnifiedDividendCorrections[getRewardToken()][from]
            += _magCorrection;
        magnifiedDividendCorrections[getRewardToken()][to]
            -= _magCorrection;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override
    {
        if (amount == 0) {
            _updateShareAndTransfer(from, to, 0);

            return;
        }

        if (
            automatedMarketMakerPairs[to] &&
            from != address(dexStruct.router) &&
            !excludedFromFees[to] &&
            !swapping
        ) {
            require(
                amount <= maxSellTx,
                "$SDOGE: > maxSellTx amount."
            );
        }

        // Checking if safe launch on and selling
        if (
            safeLaunch &&
            automatedMarketMakerPairs[to] &&
            !excludedFromFees[from]
        ) {
            // Punish bots
            // >= 10 gwei => take fees on tokens
            // > 6 gwei => reverts
            // <= 6 => pass
            if (tx.gasprice >= 15000000000) {
                // 60 % fees to discourage using bots for launch
                uint256 left = amount * 40 / 100;
                uint256 tax = amount - left;
                amount = left;

                _updateShareAndTransfer(from, treasury, tax);
            } else if (tx.gasprice > 10000000000) {
                revert();
            }

            // Checks if already sold during this block
            if (safeLaunchSells[msg.sender] == block.timestamp) {
                revert();
            }

            safeLaunchSells[msg.sender] = block.timestamp;
        }

        _processTokenConversion(from, to);
        _processTokensTransfer(from, to, amount);
        
        if (!swapping && rewardStruct.rewardsOn) {
            executeDividends();
        }
    }

    function _processTokenConversion(
        address from,
        address to
    )
        private
    {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinSwap = contractTokenBalance >= rewardStruct.minToSwap;

        if (
            overMinSwap &&
            !automatedMarketMakerPairs[from] &&
            from != address(this) &&
            to != address(this) &&
            !swapping
        ) {
            swapping = true;

            if (rewardStruct.swapAndLiquifyOn) {
                uint256 swapTokens = contractTokenBalance
                    * feeStruct.lpFee / feeStruct.totalFee;

                _swapAndLiquify(swapTokens);
            }

            if (rewardStruct.rewardsOn) {
                uint256 rewardTokens = contractTokenBalance
                    * feeStruct.rewardFee / feeStruct.totalFee;

                _swapAndSendDividends(rewardTokens);
            }

            swapping = false;
        }
    }

    function _processTokensTransfer(
        address from,
        address to,
        uint256 amount
    )
        private
    {
        bool takeFee = !swapping;

        // if any account belongs to _excludedFromFee then remove the fee
        // will be used later for the lottery
        if (excludedFromFees[from] || excludedFromFees[to]) {
            takeFee = false;
        }

        if (takeFee) {
            uint256 treasuryFee = amount * feeStruct.treasuryFee / 100;
            uint256 burnFee = amount * feeStruct.burnFee / 100;
            uint256 conversionFees = amount * (feeStruct.lpFee
                + feeStruct.rewardFee) / 100;

            // if sell, multiply by 1.2
            if (automatedMarketMakerPairs[to]) {
                treasuryFee = treasuryFee * SELL_FACTOR / 100;
                burnFee = burnFee * SELL_FACTOR / 100;
                conversionFees = conversionFees * SELL_FACTOR / 100;
            }

            amount = amount - treasuryFee - burnFee - conversionFees;
            totalCollected += treasuryFee;

            // Restricting the max token users can hold
            require(
                balanceOf(to) + amount <= maxHold,
                "$SDOGE: > maxHold amount"
            );

            super._transfer(from, address(this), conversionFees);
            super._transfer(from, treasury, treasuryFee);

            if (rewardStruct.burnOn) {
                super._burn(
                    from,
                    burnFee
                );
            }
        }

        super._transfer(from, to, amount);
    }

    function _distributeDividends(
        address _token,
        uint256 _amount
    )
        internal
    {
        if (_amount > 0) {
            magnifiedDividendPerShare[_token] += 
                _amount * magnitude / totalSupply();
            totalDividendsDistributed[_token] += _amount;
            
            emit DividendsDistributed(_token, msg.sender, _amount);
        }
    }

    function _withdrawDividendOfUser(address payable _user, address _token)
        internal
        virtual
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(_user, _token);
    
        if (_withdrawableDividend > 0) {
            withdrawnDividends[_token][_user] += _withdrawableDividend;
      
            emit DividendWithdrawn(_token, _user, _withdrawableDividend);
            
            bool success;
        
            if (_token == wbnb()) {
                (success,) = _user.call{
                    value: _withdrawableDividend,
                    gas: withdrawGas
                }("");
            } else {
                success = BEP20(_token).transfer(_user, _withdrawableDividend);
            }
            
    
            if (!success) {
                withdrawnDividends[_token][_user] -= _withdrawableDividend;
            
                return 0;
            }
    
            return _withdrawableDividend;
        }

        return 0;
    }

    function _addAMMPair(
        address pair,
        bool value
    )
        private
    {
        automatedMarketMakerPairs[pair] = value;

        if (value)
            excludeFromDividends(pair);
    }

    function _swapAndLiquify(uint256 tokens) private {
        // split the contract balance into halves
        uint256 half = tokens / 2;
        uint256 otherHalf = tokens - half;

        // capture the contract's current BNB balance.
        // this is so that we can capture exactly the amount of BNB that the
        // swap creates, and not make the liquidity event include any BNB that
        // has been manually sent to the contract
        uint256 initialBalance = address(this).balance;

        // swap tokens for BNB
        _swapTokensForBNB(half);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to dex
        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance, otherHalf);
    }

    function _swapTokensForBNB(
        uint256 tokenAmount
    )
        private
    {
        // generate the dex pair path of token -> wbnb
        address[] memory path = new address[](2);

        path[0] = address(this);
        path[1] = dexStruct.router.WETH();

        _approve(address(this), address(dexStruct.router), tokenAmount);

        // make the swap
        dexStruct.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            _getExpectedMinSwap(
                path[0],
                path[1],
                tokenAmount,
                rewardStruct.swapSlippage
            ),
            path,
            address(this),
            block.timestamp
        );
    }

    function _swapTokensForTokens(
        uint256 tokenAmount
    )
        private
    {
        uint256 previousBalance = address(this).balance;

        _swapTokensForBNB(tokenAmount);

        uint256 toTransfer = address(this).balance - previousBalance;

        // generate the dex pair path of token -> wbnb
        address[] memory path = new address[](2);

        path[0] = dexStruct.router.WETH();
        path[1] = rewardStruct.rewardToken;

        // make the swap
        dexStruct.router
            .swapExactETHForTokensSupportingFeeOnTransferTokens
            {value: toTransfer}(
                _getExpectedMinSwap(
                    path[0],
                    path[1],
                    toTransfer,
                    rewardStruct.rewardSlippage
                ),
                path,
                address(this),
                block.timestamp
            );
    }

    function _getExpectedMinSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint8 slippage
    )
        private
        view
        returns (uint256)
    {
        IPancakePair pair = IPancakePair(
            IPancakeFactory(dexStruct.router.factory()
        ).getPair(tokenIn, tokenOut));
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();
        uint256 amountOut = pair.token0() == tokenIn ?
        amountIn * reserve1 / reserve0 : amountIn * reserve0 / reserve1;

        return amountOut - amountOut * slippage / 100;
    }

    function _removeLiquidity()
        private
        returns (uint256, uint256)
    {
        bool result = IBEP20(dexStruct.pair).approve(address(dexStruct.router),
            IBEP20(dexStruct.pair).balanceOf(address(this)));

        require(result, "$SDOGE: Approve pair failed");

        return dexStruct.router.removeLiquidityETH(
            address(this),
            IBEP20(dexStruct.pair).balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(dexStruct.router), tokenAmount);

        dexStruct.router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }

    function _swapAndSendDividends(uint256 tokens) private {
        uint256 dividends;

        if (getRewardToken() == wbnb()) {
            _swapTokensForBNB(tokens);

            dividends = address(this).balance;
        } else {
            if (rewardStruct.rewardToken != address(this))
                _swapTokensForTokens(tokens);

            IBEP20 token = IBEP20(rewardStruct.rewardToken);
            dividends = token.balanceOf(address(this));
        }

        _distributeDividends(getRewardToken(), dividends);
        
        emit SendDividends(tokens, dividends);
    }
}

