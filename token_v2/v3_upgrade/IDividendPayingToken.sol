// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

/// @title Dividend-Paying Token Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev An interface for a dividend-paying token contract.
interface IDividendPayingToken2 {
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

    function dividendOf(
        address _owner,
        address _token
    )
        external
        view
        returns (uint256);

    receive() external payable;
    
    function receiveTokens(
        address _token,
        uint256 _collected
    )
        external;

    function withdrawDividend(address _token) external;
}
