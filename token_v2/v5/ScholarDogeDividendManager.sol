// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./Ownable.sol";
import "./IterableMapping.sol";
import "./IBEP20.sol";
import "./IScholarDogeToken.sol";

contract ScholarDogeDividendManager is Ownable {
    using IterableMapping for IterableMapping.Map;

    uint256 constant internal magnitude = 2**128;
    
    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    
    uint32 public claimWait;
    uint64 public minTokensForDividends;
    
    IScholarDogeToken public immutable sdoge;
    
    // Below are associated to the reward tokens (first key)
    mapping(address => uint256) internal magnifiedDividendPerShare;
    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;

    mapping(address => mapping(address => uint256))
        internal withdrawnDividends;
    mapping(address => uint256) internal totalDividendsDistributed;
    
    mapping(address => bool) public excludedFromDividends;

    mapping(address => mapping(address => uint256)) internal lastClaimTimes;
    
    event ExcludeFromDividends(address indexed account);
    
    event MinTokensForDividendsUpdated(uint64 _min);
    
    event ClaimWaitUpdated(uint32 newValue);

    event DividendsDistributed(address token, uint256 amount);
    
    event DividendWithdrawn(
        address indexed token,
        address indexed to,
        uint256 amount
    );
    
    event Processed(
        uint256 iterations,
        uint256 lastProcessedIndex,
        uint256 gas
    );
    
    event Claim(address indexed account, uint256 amount);
    
    constructor(address _sdoge) {
        sdoge = IScholarDogeToken(_sdoge);
        claimWait = 60;//3600;
        //must hold 10000+ tokens
        minTokensForDividends = 10000 * (10**9);
    }
    
    receive() external payable {
        _distributeDividends(sdoge.wbnb(), msg.value);
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

    function setMinTokensForDividends(uint64 _min)
        external
        onlyOwner
    {
        require(_min > 0, "min == 0");
        require(
            _min <= IBEP20(owner()).totalSupply() / 100,
            "min > 1% supply"
        );
        
        minTokensForDividends = _min;
        
        emit MinTokensForDividendsUpdated(_min);
    }
    
    function updateClaimWait(uint32 newClaimWait) external onlyOwner {
        require(
            newClaimWait >= 3600 && newClaimWait <= 86400,
            "$SDOGE_DT: 1h < claimWait < 24h"
        );
        
        emit ClaimWaitUpdated(newClaimWait);
        
        claimWait = newClaimWait;
    }
    
    function excludeFromDividends(address account)
        external
        onlyOwner
    {
        require(!excludedFromDividends[account]);

        excludedFromDividends[account] = true;

        magnifiedDividendCorrections[sdoge.rewardToken()][account]
            += _toInt256Safe(magnifiedDividendPerShare[account]
                * IBEP20(owner()).balanceOf(account));
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function claimDividends(
        address _owner,
        address _token
    )
        external
        onlyOwner
    {
        _processAccount(
            _owner,
            _token
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
        return _toUint256Safe(_toInt256Safe(magnifiedDividendPerShare[_token]
            * IBEP20(owner()).balanceOf(_owner))
            + magnifiedDividendCorrections[_token][_owner]) / magnitude;
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
    
    function process(uint256 claimGas)
        external
    {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        uint256 gasLeft = gasleft();

        if (numberOfTokenHolders == 0)
            return;

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 _lastProcessedIndex = lastProcessedIndex;
        address rewardToken = sdoge.rewardToken();

        while (gasUsed < claimGas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length)
                _lastProcessedIndex = 0;

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (_canAutoClaim(lastClaimTimes[rewardToken][account]))
                _processAccount(account, rewardToken);
                
            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft)
                gasUsed = gasUsed + gasLeft - newGasLeft;

            gasLeft = newGasLeft;
        }
        
        lastProcessedIndex = _lastProcessedIndex;

        emit Processed(iterations, lastProcessedIndex, claimGas);
    }
    
    function updateShareAndTransfer(
        address from,
        address to,
        uint256 amount
    )
        external
        onlyOwner
    {
        address rewardToken = sdoge.rewardToken();
        int256 _magCorrection = _toInt256Safe(
            magnifiedDividendPerShare[rewardToken] * amount);
        
        if (!excludedFromDividends[from]) {
            magnifiedDividendCorrections[rewardToken][from]
                += _magCorrection;
                
            _processBalance(from, rewardToken);
        }
        
        if (!excludedFromDividends[to]) {
            magnifiedDividendCorrections[rewardToken][to]
                -= _magCorrection;
                
            _processBalance(to, rewardToken);
        }
    }
    
    function _processBalance(
        address account,
        address rewardToken
    )
        private
    {
        uint256 balance = sdoge.balanceOf(account);
        
        if (balance > minTokensForDividends) {
            tokenHoldersMap.set(account, balance);
            _processAccount(account, rewardToken);
        } else {
            tokenHoldersMap.remove(account);
        }
    }
    
    function _toUint256Safe(int256 a)
        private
        pure
        returns (uint256)
    {
        require(a >= 0);

        return uint256(a);
    }
    
    function _toInt256Safe(uint256 a)
        private
        pure
        returns (int256)
    {
        int256 b = int256(a);

        require(b >= 0);

        return b;
    }
    
    function _distributeDividends(
        address token,
        uint256 amount
    )
        private
    {
        if (amount > 0) {
            magnifiedDividendPerShare[token] += 
                amount * magnitude / IBEP20(owner()).totalSupply();
            totalDividendsDistributed[token] += amount;
            
            emit DividendsDistributed(token, amount);
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
        
            if (_token == sdoge.wbnb()) {
                (success,) = _user.call{
                    value: _withdrawableDividend
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
    {
        uint256 amount = _withdrawDividendOfUser(account, token);

        if (amount > 0) {
            lastClaimTimes[token][account] = block.timestamp;

            emit Claim(account, amount);
        }
    }

    function _canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp - lastClaimTime >= claimWait;
    }
}
