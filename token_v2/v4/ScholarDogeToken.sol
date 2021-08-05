// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./ScholarDogeTeamTimelock.sol";
import "./IPancakePair.sol";
import "./ScholarDogeConfig.sol";
import "./BEP20.sol";
import "./EnumerableMap.sol";

contract ScholarDogeToken is BEP20, ScholarDogeConfig {
    using EnumerableMap for EnumerableMap.Map;
    
    uint256 constant internal MAGNITUDE = 2**128;
    
    EnumerableMap.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    
    uint256 public treasuryFeeCollected;
    
    ScholarDogeTeamTimelock public teamTimelock;

    bool private swapping;
    bool private shouldAddLp;
    bool private shouldReward;
    
    mapping(address => uint256) public magnifiedDividendPerShare;
    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;

    mapping(address => mapping(address => uint256)) public withdrawnDividends;
    mapping(address => uint256) private totalDividendsDistributed;
    
    mapping(address => bool) private automatedMarketMakerPairs;
    mapping(address => bool) public excludedFromFees;
    mapping(address => bool) public excludedFromDividends;

    mapping(address => mapping(address => uint256)) private lastClaimTimes;
    
    event ExcludeFromFees(address indexed _account, bool _excluded);
    
    event ExcludeFromDividends(address indexed account);

    event SetAutomatedMarketMakerPair(
        address indexed _pair,
        bool _value
    );
    
    event MigrateLiquidity(
        address indexed newAddress
    );

    event SwapAndLiquify(
        uint256 addedTokens,
        uint256 addedBnb
    );

    event SendDividends(
        uint256 amount
    );

    event ProcessedDividendTracker(
        uint256 iterations,
        uint256 lastProcessedIndex,
        uint256 gas
    );
    
    event DividendWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );
    
    event Claim(address indexed account, uint256 amount);

    constructor() BEP20("ScholarDoge", "$SDOGE") {
        // TODO Exclude from dividends the deployer
        _excludeFromDividends(address(this));
        _excludeFromDividends(address(0x0));
        _excludeFromDividends(address(dexStruct.router));

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
        init = false;
        
        // Treasury will not be taxed as used for charities
        excludedFromFees[treasury] = true;
        excludedFromFees[owner()] = false;
    }
    
    function initSupply() external {
        require(
		    totalSupply() == 0,
		    "Supply already Initialized"
	    );
        
        // Supply alloc
        // 8.4% Private sale - 42% Presale - (29.4% Liquidity)
        // 5%
        uint256 teamAlloc = MAX_SUPPLY * 5 / 100;
        // 5.2%
        uint256 marketingAlloc = MAX_SUPPLY * 52 / 1000;
        // 10%
        uint256 foundationAlloc = MAX_SUPPLY * 10 / 100;
        
        _mint(owner(), MAX_SUPPLY);
        _updateShareAndTransfer(owner(), address(teamTimelock), teamAlloc);
        // Hardcode marketing / foundation multisig here only used here
        _updateShareAndTransfer(owner(), address(0x1), marketingAlloc);
        _updateShareAndTransfer(owner(), address(0x2), foundationAlloc);
    }

    // TODO Remove, Testing purposes only
    function initLiquidity() external payable onlyOwner {
        _transfer(_msgSender(), address(this),
            balanceOf(_msgSender()) / 2);

        _addLiquidity(balanceOf(address(this)), msg.value);
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
        external
        onlyOwner
        safeContractUpdate(7, 3 days)
    {
        _excludeFromDividends(account);

        emit ExcludeFromDividends(account);
    }
    
    function executeLiquidityMigration(address _router)
        external
        onlyOwner
        safeContractUpdate(8, 15 days)
    {
        (uint256 tokenReceived, uint256 bnbReceived) = _removeLiquidity();

        _setDexStruct(_router);
        _addLiquidity(tokenReceived, bnbReceived);

        emit MigrateLiquidity(_router);
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
            "Can't remove current"
        );

        _addAMMPair(_pair, value);

        emit SetAutomatedMarketMakerPair(_pair, value);
    }

    function claimDividends(address token) external {
        _processAccount(
            msg.sender,
            token
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
        return (_token == rewardStruct.rewardToken) ? 
            uint256(
                int256(magnifiedDividendPerShare[_token] * balanceOf(_owner))
                + magnifiedDividendCorrections[_token][_owner]
            ) / MAGNITUDE :
            magnifiedDividendPerShare[_token]
            * tokenHoldersMap.get(_owner, _token) / MAGNITUDE;
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.length();
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
        index = tokenHoldersMap.indexOfKey(account);

        iterationsUntilProcessed = -1;

        if (index >= 0) {
            if (uint256(index) > lastProcessedIndex) {
                iterationsUntilProcessed = index - int256(lastProcessedIndex);
            } else {
                uint256 processesUntilEndOfArray
                    = tokenHoldersMap.length() > lastProcessedIndex ?
                        tokenHoldersMap.length() - lastProcessedIndex : 0;

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
    
    function executeDividends() public {
        uint256 numberOfTokenHolders = tokenHoldersMap.length();
        uint256 gasLeft = gasleft();

        if (numberOfTokenHolders == 0)
            return;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 _lastProcessedIndex = lastProcessedIndex;
        address rewardToken = rewardStruct.rewardToken;

        while (gasUsed < claimGas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= numberOfTokenHolders)
                _lastProcessedIndex = 0;

            address account = tokenHoldersMap.keyAt(_lastProcessedIndex);

            if (_canAutoClaim(lastClaimTimes[rewardToken][account]))
                _processAccount(account, rewardToken);

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft)
                gasUsed = gasUsed + gasLeft - newGasLeft;

            gasLeft = newGasLeft;
        }
        
        lastProcessedIndex = _lastProcessedIndex;
        
        emit ProcessedDividendTracker(
            iterations,
            lastProcessedIndex,
            claimGas
        );
    }
    
    function _processAccount(
        address account,
        address token
    )
        private
        returns (bool)
    {
        uint256 amount = _withdrawDividendOfUser(account, token);

        if (amount > 0) {
            lastClaimTimes[token][account] = block.timestamp;

            emit Claim(account, amount);

            return true;
        }

        return false;
    }
    
    function _excludeFromDividends(address account) private {
        require(!excludedFromDividends[account]);

        excludedFromDividends[account] = true;

        magnifiedDividendCorrections[rewardStruct.rewardToken][account]
            += int256(magnifiedDividendPerShare[rewardStruct.rewardToken]
                * balanceOf(account));
        
        tokenHoldersMap.remove(account, rewardStruct.rewardToken);
    }

    function _canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp - lastClaimTime >= claimWait;
    }
    
    function _setDexStruct(address _router) override internal {
        super._setDexStruct(_router);

        _excludeFromDividends(_router);
        _addAMMPair(dexStruct.pair, true);
    }
    
    function _updateShareAndTransfer(
        address from,
        address to,
        uint256 amount
    )
        private
    {
        super._transfer(from, to, amount);
        
        int256 _magCorrection = int256(
            magnifiedDividendPerShare[rewardStruct.rewardToken] * amount);
        
        if (!excludedFromDividends[from]) {
            magnifiedDividendCorrections[rewardStruct.rewardToken][from]
                += _magCorrection;
                
            _processBalance(from);
        }
        
        if (!excludedFromDividends[to]) {
            magnifiedDividendCorrections[rewardStruct.rewardToken][to]
                -= _magCorrection;
                
            _processBalance(to);
        }
    }
    
    function _processBalance(address account) private {
        uint256 balance = balanceOf(account);
        
        if (balance > minTokensForDividends) {
            tokenHoldersMap.set(account, rewardStruct.rewardToken, balance);
            
            if (feeStruct.rewardFee > 0)
                _processAccount(account, rewardStruct.rewardToken);
        } else {
            tokenHoldersMap.remove(account, rewardStruct.rewardToken);
        }
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override
    {
        // Trick to avoid out of gas
        require(swapping || gasleft() > minTxGas);
        
        if (amount == 0) {
            _updateShareAndTransfer(from, to, 0);

            return;
        }
        
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
            if (!swapping && safeLaunchSells[msg.sender] == block.timestamp) {
                revert();
            }
    
            safeLaunchSells[msg.sender] = block.timestamp;
        }

        if (
            automatedMarketMakerPairs[to] &&
            from != address(dexStruct.router)
        ) {
            require(
                amount <= maxSellTx,
                "amount > maxSellTx"
            );
        }

        _processTokensTransfer(from, to, amount);
        
        bool processed = _processTokenConversion(from);

        if (!swapping && !processed && feeStruct.rewardFee > 0)
            executeDividends();
    }

    function _processTokenConversion(address from)
        private
        returns (bool)
    {
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinSwap = contractTokenBalance >= rewardStruct.minToSwap;
        bool processed = false;
        
        if (overMinSwap && !shouldAddLp && !shouldReward) {
            shouldAddLp = feeStruct.lpFee > 0;
            shouldReward = feeStruct.rewardFee > 0;
        }
        
        if (
            !automatedMarketMakerPairs[from] &&
            !swapping
        ) {
            swapping = true;
            
            // Slipts in order to avoid too much gas on transfer
            if (shouldAddLp) {
                shouldAddLp = false;
                
                uint256 swapTokens = rewardStruct.minToSwap
                    * feeStruct.lpFee / (feeStruct.lpFee + feeStruct.rewardFee);
    
                _swapAndLiquify(swapTokens);
                
                processed = true;
            } else if (shouldReward) {
                shouldReward = false;
                
                uint256 rewardTokens = rewardStruct.minToSwap
                    * feeStruct.rewardFee / (feeStruct.lpFee + feeStruct.rewardFee);
    
                _swapAndSendDividends(rewardTokens);
                
                processed = true;
            }
            
            swapping = false;
        }
        
        return processed;
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
                treasuryFee += treasuryFee * SELL_FACTOR / 100;
                burnFee += burnFee * SELL_FACTOR / 100;
                conversionFees += conversionFees * SELL_FACTOR / 100;
            }

            amount = amount - treasuryFee - burnFee - conversionFees;
            treasuryFeeCollected += treasuryFee;

            // Restricting the max token users can hold excluding pairs
            require(
                automatedMarketMakerPairs[to] ||
                balanceOf(to) + amount <= maxHold,
                "balance > maxHold"
            );

            _updateShareAndTransfer(from, address(this), conversionFees);
            _updateShareAndTransfer(from, treasury, treasuryFee);

            if (feeStruct.burnFee > 0) {
                super._burn(
                    from,
                    burnFee
                );
            }
        }

        _updateShareAndTransfer(from, to, amount);
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
        _swapTokensForBnb(half);

        // how much BNB did we just swap into?
        uint256 newBalance = address(this).balance - initialBalance;

        // add liquidity to dex
        _addLiquidity(otherHalf, newBalance);

        emit SwapAndLiquify(half, newBalance);
    }

    function _withdrawDividendOfUser(address _user, address _token)
        internal
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(_user, _token);
    
        if (_withdrawableDividend > 0) {
            withdrawnDividends[_token][_user] += _withdrawableDividend;
      
            emit DividendWithdrawn(_token, _user, _withdrawableDividend);
            
            bool success;
        
            if (_token == wbnb()) {
                (success,) = _user.call{
                    value: _withdrawableDividend
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
            _excludeFromDividends(pair);
    }
    
    function _swapTokensForBnb(
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
            block.timestamp + 5 minutes
        );
    }
    
    function _swapTokensForTokens(
        uint256 tokenAmount
    )
        private
    {
        uint256 previousBalance = address(this).balance;

        _swapTokensForBnb(tokenAmount);

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
                block.timestamp + 5 minutes
            );
    }

    function _getExpectedMinSwap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 slippage
    )
        private
        view
        returns (uint256)
    {
        IPancakePair pair = IPancakePair(
            IPancakeFactory(dexStruct.router.factory())
                .getPair(tokenIn, tokenOut)
        );
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

        require(result, "Approve pair failed");

        return dexStruct.router.removeLiquidityETH(
            address(this),
            IBEP20(dexStruct.pair).balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp + 5 minutes
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
            block.timestamp + 5 minutes
        );
    }
    
    function _swapAndSendDividends(uint256 tokens) private {
        uint256 dividends;

        if (rewardStruct.rewardToken == wbnb()) {
            _swapTokensForBnb(tokens);

            dividends = address(this).balance;
        } else {
            if (rewardStruct.rewardToken != address(this))
                _swapTokensForTokens(tokens);

            IBEP20 token = IBEP20(rewardStruct.rewardToken);
            dividends = token.balanceOf(address(this));
        }

        if (dividends > 0) {
            magnifiedDividendPerShare[rewardStruct.rewardToken] += 
                dividends * MAGNITUDE / totalSupply();
            totalDividendsDistributed[rewardStruct.rewardToken] += dividends;
        }
        
        emit SendDividends(dividends);
    }
}

