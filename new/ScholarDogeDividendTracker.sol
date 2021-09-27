// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./Ownable.sol";
import "./EnumerableMap.sol";
import "./IScholarDogeToken.sol";
import "./IBEP20.sol";

contract ScholarDogeDividendTracker is Ownable {
    using EnumerableMap for EnumerableMap.Map;
    
    uint256 private constant MAGNITUDE = 2**128;
    uint256 private constant SDOGE_SUPPLY = 1000000000 * (10**9);
    
    address public immutable sdoge;

    mapping(address => uint256) private magnifiedDividendPerShare;
    mapping(address => mapping(address => int256))
        private magnifiedDividendCorrections;

    mapping(address => mapping(address => uint256)) private withdrawnDividends;
    mapping(address => uint256) public totalDividendsDistributed;
    
    // Used gas for withdraw, can be updated as it may change
    uint32 private withdrawGas = 6000;
    
    // use by default 250,000 gas to process auto-claiming dividends
    uint32 private claimGas = 250000;
    
    uint32 public claimWait;
    
    uint64 public minTokensForDividends;

    EnumerableMap.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping(address => bool) private excludedFromDividends;

    mapping(address => mapping(address => uint256)) private lastClaimTimes;

    event MinTokensForDividendsUpdated(uint256 _min);
    
    event ExcludeFromDividends(address indexed account);
    
    event ClaimWaitUpdated(uint256 newValue, uint256 oldValue);

    event DividendWithdrawn(
        address indexed reward,
        address indexed account,
        uint256 amount
    );
    
    event DividendsDistributed(
        address indexed reward,
        address indexed account,
        uint256 amount
    );
    
    event Claim(address indexed account, uint256 amount);
    
    event WithdrawGasUpdated(uint256 gas);

    constructor(address _sdoge) {
        sdoge = _sdoge;
    	claimWait = 3600;
        minTokensForDividends = 10000 * (10**9); //must hold 10000+ tokens
    }
    
    receive() external payable onlyOwner {
        _distributeDividends(IScholarDogeToken(sdoge).wbnb(), msg.value);
    }
    
    function receiveTokens(
        address _token,
        uint256 _collected
    )
        external
        onlyOwner
    {
        _distributeDividends(_token, _collected);
    }
    
    function updateWithdrawGas(uint32 gas) external onlyOwner {
        require(
            gas > 0, 
            "$SDOGE_DT: <= 0"
        );
        
        withdrawGas = gas;
        
        emit WithdrawGasUpdated(gas);
    }
    
    function setMinTokensForDividends(uint64 _min)
        external
        onlyOwner
    {
        require(_min > 0, "min == 0");
        require(_min <= SDOGE_SUPPLY / 100, "min > 1% supply");
        
        minTokensForDividends = _min;
        
        emit MinTokensForDividendsUpdated(_min);
    }
    
    function updateClaimWait(uint32 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86400,
            "$SDOGE_DT: 1h < claimWait < 24h"
        );
        
        emit ClaimWaitUpdated(newClaimWait, claimWait);
        
        claimWait = newClaimWait;
    }

    function excludeFromDividends(address account)
        external
        onlyOwner
    {
        _excludeFromDividends(account);

        emit ExcludeFromDividends(account);
    }

    function getNumberOfTokenHolders() external view returns (uint256) {
        return tokenHoldersMap.length();
    }
    
    function withdrawDividend(address _token) public {
        _withdrawDividendOfUser(payable(msg.sender), _token);
    }

    function getAccount(address _account, address _token)
        public
        view
        returns (
            int256 index,
            int256 iterationsUntilProcessed,
            uint256 withdrawableDividends,
            uint256 totalDividends,
            uint256 lastClaimTime,
            uint256 nextClaimTime,
            uint256 secondsUntilAutoClaimAvailable
        )
    {
        index = tokenHoldersMap.indexOfKey(_account);

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
            = withdrawableDividendOf(_account, _token);
        totalDividends
            = accumulativeDividendOf(_account, _token);
        lastClaimTime = lastClaimTimes[_token][_account];
        nextClaimTime = lastClaimTime > 0 ? lastClaimTime + claimWait : 0;
        secondsUntilAutoClaimAvailable = nextClaimTime > block.timestamp ?
            nextClaimTime - block.timestamp : 0;
    }
    
    function withdrawableDividendOf(address _owner, address _token)
        public
        view
        returns (uint256)
    {
        return (
            accumulativeDividendOf(_owner, _token) < withdrawnDividends[_token][_owner] ||
            excludedFromDividends[_owner]
        ) ? 0 : accumulativeDividendOf(_owner, _token) - withdrawnDividends[_token][_owner];
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
        uint256 balance = (
            _token == IScholarDogeToken(sdoge).rewardToken() &&
            !excludedFromDividends[_owner]
        ) ? IBEP20(sdoge).balanceOf(_owner) : tokenHoldersMap.get(_owner, _token);

        return uint256(int256(magnifiedDividendPerShare[_token] * balance)
            + magnifiedDividendCorrections[_token][_owner]) / MAGNITUDE;
    }
    
    function getTokenHolderMap(address _owner, address _token) public view returns (uint256) {
        return tokenHoldersMap.get(_owner, _token);
    }

    function updateShare(
        address from,
        address to,
        uint256 amount
    )
        external
    {
        address rewardToken = IScholarDogeToken(sdoge).rewardToken();
        int256 _magCorrection = int256(
            magnifiedDividendPerShare[rewardToken] * amount);
        
        if (!excludedFromDividends[from]) {
            magnifiedDividendCorrections[rewardToken][from] += _magCorrection;
                
            _processBalance(payable(from));
        }
        
        if (!excludedFromDividends[to]) {
            magnifiedDividendCorrections[rewardToken][to] -= _magCorrection;
                
            _processBalance(payable(to));
        }
    }

    function process(uint256 gas) public returns (uint256, uint256) {
    	uint256 numberOfTokenHolders = tokenHoldersMap.length();
        uint256 gasLeft = gasleft();

        if (numberOfTokenHolders == 0)
            return (0, lastProcessedIndex);

        uint256 maxGas = gas == 0 ? claimGas : gas;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 _lastProcessedIndex = lastProcessedIndex;
        address rewardToken
            = IScholarDogeToken(sdoge).rewardToken();

        while (gasUsed < maxGas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= numberOfTokenHolders)
                _lastProcessedIndex = 0;

            address account = tokenHoldersMap.keyAt(_lastProcessedIndex);

            if (_canAutoClaim(lastClaimTimes[rewardToken][account]))
                _processAccount(payable(account), rewardToken);

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft)
                gasUsed = gasUsed + gasLeft - newGasLeft;

            gasLeft = newGasLeft;
        }
        
        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, lastProcessedIndex);
    }

    function processAccount(
        address payable account,
        address token
    )
        public
        onlyOwner
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
        excludedFromDividends[account] = true;
        
        address rewardToken
            = IScholarDogeToken(sdoge).rewardToken();

        magnifiedDividendCorrections[rewardToken][account]
            += int256(magnifiedDividendPerShare[rewardToken]
                * IBEP20(sdoge).balanceOf(account));
        
        tokenHoldersMap.remove(account, rewardToken);
    }
    
    function _canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)
            return false;

        return block.timestamp - lastClaimTime >= claimWait;
    }
    
    function _distributeDividends(
        address _token,
        uint256 _amount
    )
        internal
    {
        if (_amount > 0) {
            magnifiedDividendPerShare[_token] += 
                _amount * MAGNITUDE / SDOGE_SUPPLY;
            totalDividendsDistributed[_token] += _amount;
            
            emit DividendsDistributed(_token, msg.sender, _amount);
        }
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
        
            if (_token == IScholarDogeToken(sdoge).wbnb()) {
                (success,) = _user.call{
                    value: _withdrawableDividend,
                    gas: withdrawGas
                }("");
            } else {
                success = IBEP20(_token).transfer(_user, _withdrawableDividend);
            }
            
    
            if (!success) {
                withdrawnDividends[_token][_user] -= _withdrawableDividend;
            
                return 0;
            }
    
            return _withdrawableDividend;
        }

        return 0;
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
    
    function _processBalance(address account) private {
        uint256 balance = IBEP20(sdoge).balanceOf(account);
        address rewardToken
            = IScholarDogeToken(sdoge).rewardToken();
        
        if (balance > minTokensForDividends) {
            tokenHoldersMap.set(account, rewardToken, balance);
        } else {
            tokenHoldersMap.remove(account, rewardToken);
        }
    }
}

