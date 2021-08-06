// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

/// @title Dividend-Paying Token Optional Interface
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev OPTIONAL functions for a dividend-paying token contract.
interface IDividendPayingTokenOptional2 {
    function withdrawableDividendOf(address _owner, address _token)
        external
        view
        returns (uint256);

    function withdrawnDividendOf(address _owner, address _token)
        external
        view
        returns (uint256);

    function accumulativeDividendOf(address _owner, address _token)
        external
        view
        returns (uint256);
}
