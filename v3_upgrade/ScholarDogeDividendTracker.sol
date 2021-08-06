// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./DividendPayingToken2.sol";
import "./Ownable.sol";
import "./IterableMapping.sol";

contract ScholarDogeDividendTracker2 is DividendPayingToken2, Ownable {
    using SafeMath for uint256;
    using SignedSafeMath for int256;
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;

    mapping (address => bool) public excludedFromDividends;

    mapping(address => mapping(address => uint256)) public lastClaimTimes;

    uint256 public claimWait;
    uint256 public immutable minimumTokenBalanceForDividends;

    event ExcludeFromDividends(address indexed account);

    event ClaimWaitUpdated(uint256 indexed newValue, uint256 indexed oldValue);

    event Claim(address indexed account, uint256 amount, bool indexed automatic);

    event WithdrawGasUpdated(uint256 gas);

    constructor(address _sdoge)
    	DividendPayingToken2(_sdoge, "$SDOGE_Dividend_Tracker", "$SDOGE_DT")
    {
        claimWait = 60;//3600;
        //must hold 10000+ tokens
        minimumTokenBalanceForDividends = 10000 * (10**9);
    }

    function receiveTokens(
        address _token,
        uint256 _collected
    )
        external
        override
        onlyOwner
    {
        _distributeDividends(_token, _collected);
    }

    function addRewardToken(address _token) public override onlyOwner {
        super.addRewardToken(_token);
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

    function withdrawDividend(address) public pure override {
        require(
            false,
            "$SDOGE_DT: Use claim from $SDOGE"
        );
    }

    function _transfer(address, address, uint256) internal pure override {
        require(
            false,
            "$SDOGE_DT: Can't transfer"
        );
    }

    function excludeFromDividends(address account) external onlyOwner {
        require(!excludedFromDividends[account]);

        excludedFromDividends[account] = true;

        _setBalance(account, 0);
        tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }

    function getNumberOfTokenHolders() external view returns(uint256) {
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

    function getAccountAtIndex(uint256 index)
        public
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
        if (index >= tokenHoldersMap.size()) {
            return (
            0x0000000000000000000000000000000000000000,
            -1,
            -1,
            0,
            0,
            0,
            0,
            0
            );
        }

        address account = tokenHoldersMap.getKeyAtIndex(index);

        return getAccount(account, sdoge.getRewardToken());
    }

    function canAutoClaim(uint256 lastClaimTime) private view returns (bool) {
        if (lastClaimTime > block.timestamp)  {
            return false;
        }

        return block.timestamp - lastClaimTime >= claimWait;
    }

    function setBalance(
        address payable account,
        uint256 newBalance
    )
        external
        onlyOwner
    {
        if (excludedFromDividends[account])
            return;

        if (newBalance >= minimumTokenBalanceForDividends) {
            _setBalance(account, newBalance);
            tokenHoldersMap.set(account, newBalance);
        } else {
            _setBalance(account, 0);
            tokenHoldersMap.remove(account);
        }

        processAccount(account, sdoge.getRewardToken(), true);
    }

    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;
        uint256 gasLeft = gasleft();

        if (numberOfTokenHolders == 0 || gasLeft < gas)
            return (0, 0, lastProcessedIndex);

        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            lastProcessedIndex++;

            if (lastProcessedIndex >= tokenHoldersMap.keys.length)
                lastProcessedIndex = 0;

            address account = tokenHoldersMap.keys[lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[sdoge.getRewardToken()][account]))
                if (processAccount(payable(account), sdoge.getRewardToken(), true))
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

}

