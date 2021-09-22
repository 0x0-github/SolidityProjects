// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./BEP20.sol";
import "./IPancakeRouter02.sol";
import "./IPancakePair.sol";
import "./IPancakeFactory.sol";

contract TestToken is BEP20 {
    uint256 public immutable supply;
    
    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _supply
    )
        BEP20(_name, _symbol)
    {
        supply = _supply;
        
        _mint(msg.sender, _supply);
    }
    
    function totalSupply() public view virtual override returns (uint256) {
        return supply;
    }
}

contract PoolUtils {
    IPancakeRouter02 public router
        = IPancakeRouter02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        
    receive() external payable {
    }
        
    function sendToken(
        address token,
        uint256 amount
    )
        public
    {
        require(
            BEP20(token).transfer(msg.sender, amount),
            "sendToken failed"
        );
    }
    
    function sendBnb(uint256 amount) public {
       (bool result,) =  msg.sender.call{value: amount}("");
       
       require(
            result,
            "sendBnb failed"
        );
    }

    function swapTokensForBnb(
        address token,
        uint256 tokenAmount
    )
        public
    {
        // generate the dex pair path of token -> wbnb
        address[] memory path = new address[](2);

        path[0] = token;
        path[1] = router.WETH();

        BEP20(token).approve(address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of BNB
            path,
            address(this),
            block.timestamp
        );
    }
    
    function swapTokensForTokens(
        address tokenIn,
        uint256 amountIn,
        address tokenOut
    )
        public
    {
        uint256 previousBalance = address(this).balance;
        
        swapTokensForBnb(tokenIn, amountIn);
        
        uint256 toTransfer = address(this).balance - previousBalance;
        
        // generate the dex pair path of token -> wbnb
        address[] memory path = new address[](2);

        path[0] = router.WETH();
        path[1] = tokenOut;

        // make the swap
        router
            .swapExactETHForTokensSupportingFeeOnTransferTokens
                {value: toTransfer}(
                    0, // accept any amount of tokens
                    path,
                    address(this),
                    block.timestamp
                );
    }
    
    function removeLiquidity(address token1, address token2)
        public
        returns (uint256 amountToken, uint256 amountBnb)
    {
        IBEP20 pair
            = IBEP20(IPancakeFactory(router.factory()).getPair(token1, token2));
        bool result = pair.approve(address(router),
                pair.balanceOf(address(this)));
                
        require(result, "Approve pair failed");
            
        return router.removeLiquidity(
            token1,
            token2,
            pair.balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp
        );
    }
    
    function removeLiquidityBnb(address token)
        public
        returns (uint256 amountToken, uint256 amountBnb)
    {
        IBEP20 pair
            = IBEP20(IPancakeFactory(router.factory()).getPair(token, router.WETH()));
        bool result = pair.approve(address(router),
                pair.balanceOf(address(this)));
                
        require(result, "Approve pair failed");
            
        return router.removeLiquidityETH(
            token,
            pair.balanceOf(address(this)),
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(
        address token1,
        uint256 amount1,
        address token2,
        uint256 amount2
    ) 
        public
    {
        BEP20(token1).approve(address(router), amount1);
        BEP20(token1).approve(address(router), amount1);

        router.addLiquidity(
            token1,
            token2,
            amount1,
            amount2,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    
    function addLiquidityBnb(
        address token,
        uint256 amountToken,
        uint256 amountBnb
    ) 
        public
    {
        BEP20(token).approve(address(router), amountToken);

        router.addLiquidityETH{value: amountBnb}(
            token,
            amountToken,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );
    }
    
}

contract ScholarDogeTestDispatcher {
    uint8 public constant MAX_CLAIMS = 3;
    // 0.01%
    uint8 public constant CLAIM_SHARE = 1;
    
    address public immutable sdoge;
    
    uint256 public immutable testTokenAmount;
    
    mapping(address => uint256) public claims;
    
    constructor(address _sdoge, uint256 _testTokenAmount) {
        sdoge = _sdoge;
        testTokenAmount = _testTokenAmount;
    }
    
    function claim() public {
        require(
            ++claims[msg.sender] <= MAX_CLAIMS,
            "Max claims for this address"
        );
        
        bool result
            = IBEP20(sdoge).transfer(msg.sender, testTokenAmount * CLAIM_SHARE / 1000);
        
        require(result, "$SDOGE transfer failed");
    }

}
