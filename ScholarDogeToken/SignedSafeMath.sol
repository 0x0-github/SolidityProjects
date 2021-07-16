// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

library SignedSafeMath {
    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);

        return uint256(a);
    }
}
