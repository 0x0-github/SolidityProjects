// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./IBEP20.sol";

interface IScholarDogeToken is IBEP20 {
    function wbnb() external view returns (address);
    function rewardToken() external view returns (address);
}
