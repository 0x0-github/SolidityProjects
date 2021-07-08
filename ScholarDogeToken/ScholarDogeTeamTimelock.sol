// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./SafeBEP20.sol";
import "./SafeMath.sol";

/**
 * @dev A token holder contract that will allow a beneficiary to extract
 * a % of tokens after a given interval time.
 */
contract ScholarDogeTeamTimelock {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;
    
    // Defines the release interval
    uint8 constant public RELEASE_PERCENTAGE = 4;
    
    // Defines the release interval
    uint256 constant public RELEASE_INTERVAL = 15 days;
    
    uint256 public releaseAmount;
    
    uint256 public nextWithdraw = block.timestamp;
    
    uint256 public baseTokenAmount;

    // BEP20 basic token contract being held
    IBEP20 public token;

    // beneficiary of tokens after they are released
    address public beneficiary;

    constructor (IBEP20 _token, address _beneficiary) {
        token = _token;
        beneficiary = _beneficiary;
    }
    
    /**
     * @notice Transfers tokens held by timelock to beneficiary.
     */
    function release() external virtual {
        require(
            block.timestamp >= nextWithdraw,
            "ScholarDogeTeamTimelock: before release time"
        );
            
        nextWithdraw = nextWithdraw.add(RELEASE_INTERVAL);
        
        if (baseTokenAmount == 0)
            baseTokenAmount = token.balanceOf(address(this));

        uint256 amount = getReleaseAmount();

        require(
            amount > 0,
            "ScholarDogeTeamTimelock: no tokens to release"
        );

        token.safeTransfer(beneficiary, amount);
        _withdrawRewards(address(0x0));
    }
    
    function getReleaseAmount() public view returns (uint256) {
        uint256 amount = baseTokenAmount.mul(RELEASE_PERCENTAGE).div(100);
        
        if (amount > token.balanceOf(address(this)))
            amount = token.balanceOf(address(this));
            
        return amount;
    }
    
    function _withdrawRewards(address _token) private {
        // If 0x0 = BNB
        if (_token == address(0x0)) {
            uint256 bnbBalance = address(this).balance;
        
            if (bnbBalance > 0) {
                (bool success,) = beneficiary.call{value: bnbBalance}("");
                
                require(
                    success,
                    "ScholarDogeTeamTimelock: Failed tranfering BNB from fees"
                );
            }
        } else {
            IBEP20 rewardToken = IBEP20(_token);
            
            rewardToken.safeTransfer(
                beneficiary,
                rewardToken.balanceOf(address(this))
            );
        }
    }
}
