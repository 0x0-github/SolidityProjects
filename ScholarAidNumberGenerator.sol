//SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0 < 0.8.0;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

interface ILottery {
    function getMaxRange() external view returns(uint32);

    function numbersDrawn(
        uint256 _lotteryId,
        bytes32 _requestId, 
        uint256 _randomNumber
    ) 
        external;
}

contract ScholarAidNumberGenerator is VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    address internal requester;
    uint256 public randomResult;
    uint256 public currentLotteryId;

    address public lottery;
    
    modifier onlyLottery() {
        require(
            msg.sender == lottery,
            "Only Lottery can call function"
        );

        _;
    }

    constructor(
        address _vrfCoordinator,
        address _linkToken,
        address _lottery,
        bytes32 _keyHash,
        uint256 _fee
    )
        public
        VRFConsumerBase(
            _vrfCoordinator, 
            _linkToken  
        )
    {
        keyHash = _keyHash;
        fee = _fee; 
        lottery = _lottery;
    }
    
    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(
        uint256 lotteryId,
        uint256 userProvidedSeed
    ) 
        public 
        onlyLottery()
        returns (bytes32 requestId) 
    {
        require(keyHash != bytes32(0), "Must have valid key hash");
        require(
            LINK.balanceOf(address(this)) >= fee, 
            "Not enough LINK - fill contract with faucet"
        );

        requester = msg.sender;
        currentLotteryId = lotteryId;

        return requestRandomness(keyHash, fee, userProvidedSeed);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    )
        internal
        override
    {
        ILottery(requester).numbersDrawn(
            currentLotteryId,
            requestId,
            randomness
        );

        randomResult = randomness;
    }
}
