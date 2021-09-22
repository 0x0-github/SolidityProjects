// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

interface IScholarDogeToken {
    function wbnb() external view returns (address);
    function getRewardToken() external view returns (address);
}

