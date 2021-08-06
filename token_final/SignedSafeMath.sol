// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SignedSafeMath {
    int256 private constant MIN_INT256 = int256(1) << 255;
    
    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}
