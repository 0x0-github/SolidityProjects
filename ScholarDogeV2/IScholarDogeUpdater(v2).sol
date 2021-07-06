// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IScholarDogeUpdater {
    function initializeContract(address sdoge, address treasury) external;
  	
  	function setRewardFee(uint8 rewardFee_) external;
    
    function setLiquidityFee(uint8 liquidityFee_) external;
    
    function setTreasuryFee(uint8 treasuryFee_) external;
    
    function setBurnFee(uint8 burnFee_) external;
    
    function excludeFromFees(address account, bool excluded) external;
    
    function setMaxSellTxAmount(uint256 amount) external;
    
    function setMaxHoldAmount(uint256 amount) external;
    
    function setTreasury(address treasury) external;
    
    function setSwapAndLiquifyEnabled(bool enabled) external;
    
    function setRewardSystemEnabled(bool enabled) external;
    
    function setBurnSystemEnabled(bool enabled) external;
    
    function setMinToSwap(uint128 minToSwap_) external;
    
    function setRewardToken(address token) external;

    function updateGasForProcessing(uint256 newValue) external;
    
    function rewardFee() external view returns (uint8);
    
    function treasuryFee() external view returns (uint8);
    
    function burnFee() external view returns (uint8);
    
    function swapAndLiquifyEnabled() external view returns (bool);
    
    function rewardSystemEnabled() external view returns (bool);
    
    function burnSystemEnabled() external view returns (bool);
    
    function minToSwap() external view returns (uint128);
    
    function rewardToken() external view returns (address);
    
    function maxSellTxAmount() external view returns (uint256);
    
    function maxHoldAmount() external view returns (uint256);
    
    function gasForProcessing() external view returns (uint256);
    
    function treasury() external view returns (address);
    
    function isExcludedFromFees(address account)
        external
        view
        returns (bool);
    
    function totalFees() external view returns (uint8);
}
