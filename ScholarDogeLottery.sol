//SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0 < 0.8.0;

pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/token/ERC20/SafeERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/proxy/Initializable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.4.0/contracts/access/Ownable.sol";

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * This library is a version of Open Zeppelin's SafeMath, modified to support
 * unsigned 32 bit integers.
 */
library SafeMath16 {
  /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */
  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint16 c = a - b;

    return c;
  }

  /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */
  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint16 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint16 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function mod(uint16 a, uint16 b) internal pure returns (uint16) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 *
 * This library is a version of Open Zeppelin's SafeMath, modified to support
 * unsigned 32 bit integers.
 */
library SafeMath8 {
  /**
    * @dev Returns the addition of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `+` operator.
    *
    * Requirements:
    * - Addition cannot overflow.
    */
  function add(uint8 a, uint8 b) internal pure returns (uint8) {
    uint8 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
    * @dev Returns the subtraction of two unsigned integers, reverting on
    * overflow (when the result is negative).
    *
    * Counterpart to Solidity's `-` operator.
    *
    * Requirements:
    * - Subtraction cannot overflow.
    */
  function sub(uint8 a, uint8 b) internal pure returns (uint8) {
    require(b <= a, "SafeMath: subtraction overflow");
    uint8 c = a - b;

    return c;
  }

  /**
    * @dev Returns the multiplication of two unsigned integers, reverting on
    * overflow.
    *
    * Counterpart to Solidity's `*` operator.
    *
    * Requirements:
    * - Multiplication cannot overflow.
    */
  function mul(uint8 a, uint8 b) internal pure returns (uint8) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint8 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
    * @dev Returns the integer division of two unsigned integers. Reverts on
    * division by zero. The result is rounded towards zero.
    *
    * Counterpart to Solidity's `/` operator. Note: this function uses a
    * `revert` opcode (which leaves remaining gas untouched) while Solidity
    * uses an invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function div(uint8 a, uint8 b) internal pure returns (uint8) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath: division by zero");
    uint8 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
    * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
    * Reverts when dividing by zero.
    *
    * Counterpart to Solidity's `%` operator. This function uses a `revert`
    * opcode (which leaves remaining gas untouched) while Solidity uses an
    * invalid opcode to revert (consuming all remaining gas).
    *
    * Requirements:
    * - The divisor cannot be zero.
    */
  function mod(uint8 a, uint8 b) internal pure returns (uint8) {
    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}

interface IPancakeV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    
    function allPairs(uint) external view returns (address pair);
    
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    
    function setFeeToSetter(address) external;
}

interface IPancakeV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IPancakeV2Router02 is IPancakeV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IPancakeV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface ILotteryNFT {
    function getTotalSupply() external view returns(uint256);

    function getTicketNumbers(
        uint256 _ticketID
    ) 
        external 
        view 
        returns(uint8[] memory);

    function getOwnerOfTicket(
        uint256 _ticketID
    ) 
        external 
        view 
        returns(address);

    function getTicketClaimStatus(
        uint256 _ticketID
    ) 
        external 
        view
        returns(bool);

    function batchMint(
        address _to,
        uint256 _lottoID,
        uint8 _numberOfTickets,
        uint8[] calldata _numbers,
        uint8 sizeOfLottery
    )
        external
        returns(uint256[] memory);

    function claimTicket(uint256 _ticketId, uint256 _lotteryId) external returns(bool);
}

interface IScholarDogeToken {
    function getMaxTxAmount() external view returns (uint256);
}

interface IRandomNumberGenerator {

    /** 
     * Requests randomness from a user-provided seed
     */
    function getRandomNumber(
        uint256 lotteryId,
        uint256 userProvidedSeed
    ) 
        external 
        returns (bytes32 requestId);
}

contract ScholarDogeLottery is Ownable, Initializable {
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using SafeERC20 for IERC20;
    using Address for address;
    
    // Represents the status of the lottery
    enum Status { 
        NotStarted,
        Open,
        Closed,
        Completed
    }
    
    // All the needed info around a lottery
    struct LotteryInfo {
        uint256 lotteryID;
        Status lotteryStatus;
        uint256 prizePoolInSdoge;
        uint256 prizePoolInBnb;
        uint256 costPerTicket;
        uint256 bnbCostPerTicket;
        uint8[] prizeDistribution;
        uint256 startingTimestamp;
        uint256 closingTimestamp;
        uint8[] winningNumbers;
        uint8 sizeOfLottery;
        uint8 maxValidRange;
    }
    
    // Testnet: 0xa555fC018435bef5A13C6c6870a9d4C11DEC329C
    address public constant MAINNET_VRF_COORD
        = 0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31;
    // Testnet: 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06
    address public constant LINK_TOKEN
        = 0x404460C6A5EdE2D891e8297795264fDe62ADBB75;
    // Testnet: 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186
    bytes32 public constant KEY_HASH
        = 0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c;
    // Testnet: 100000000000000000
    uint256 public constant LINK_FEES = 200000000000000000;

    // Requires a min amount to refund in order to avoid
    // gas cost abuses
    uint256 public constant MIN_REFUND
        = 20000000000000000;

    // Security for widrawing all contracts funds added to
    // end time of the last lottery (letting everyone
    // withdrawing their rewards)
    uint256 public constant EMERGENCY_WITHDRAW_TIMEOUT
        = 1 days;

    // Instance of ScholarDogeToken (first currency for lotto)
    IERC20 internal erc20;
    ILotteryNFT internal nft;
    IRandomNumberGenerator internal randomGenerator;
    // Main net: 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Test net: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    IPancakeV2Router02 public router;
    
    uint256 public lotteryIdCounter;
    
    bytes32 internal requestId;
    
    bool public autoRefillLink = true;
    uint16 public constant MAGIC_NB = 256;
    // Base config
    uint8 public lotteryCombination = 15;
    uint8 public lotteryNumberSize = 4;
    uint8 public lotteryNumberRange = 15;
    uint8[] public prizeDistribution = [5, 10, 20, 50];
    uint256 public costPerTicket = 1000000000;
    uint256 public lotteryTimeout = 1 minutes;
    uint256 public lotteryDuration = 5 minutes;
    
    uint256 public linkAmountToBuy = LINK_FEES.mul(5);
    
    // Defines the fees for purchasing tickets with BNB
    uint8 public bnbFeePercent = 10;
    // Defines the % of collected fees
    uint8 public lotteryFeePercent = 15;
    
    uint256 public collectedFeesErc20;
    uint256 public collectedFeesBnb;

    // Lottery ID's to info
    mapping(uint256 => LotteryInfo) internal allLotteries;

    event NewBatchMint(
        address indexed minter,
        uint256[] ticketIDs,
        uint8[] numbers,
        uint256 totalCost
    );

    event RequestNumbers(uint256 lotteryId, bytes32 requestId);
    
    event UpdatedBnbFeePercent(uint256 newPercent);
    
    event UpdatedLotteryFeePercent(uint256 newPercent);
    
    event UpdatedRouter(address newAddress);
    
    event UpdatedLotteryConfig(
        uint8 numberSize,
        uint8 numberRange,
        uint8[] prizeDistribution,
        uint256 costPerTicket,
        uint256 lotteryTimeout,
        uint256 lotteryDuration
    );
    
    event UpdatedLinkAmountToBuy(uint256 newValue);
    
    event UpdatedAutoRefillLink(bool newValue);
    
    event EmergencyWithdrawExecuted(uint256 erc20, uint256 bnb);
    
    event LotteryFeeCollected(uint256 erc20, uint256 bnb);
    
    event LotteryOpen(uint256 lotteryId, uint256 ticketSupply);

    event LotteryClose(uint256 lotteryId, uint256 ticketSupply);

    modifier onlyRandomGenerator() {
        require(
            msg.sender == address(randomGenerator),
            "Only random generator"
        );
        _;
    }

     modifier notContract() {
        require(!address(msg.sender).isContract(), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
       _;
    }

    constructor(address _erc20) public {
        require(
            _erc20 != address(0),
            "Contracts cannot be 0 address"
        );
        
        router
            = IPancakeV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        erc20 = IERC20(_erc20);
    }

    function initialize(
        address _lotteryNFT,
        address _randomNumberGenerator
    ) 
        external 
        initializer
        onlyOwner() 
    {
        require(
            _lotteryNFT != address(0) &&
            _randomNumberGenerator != address(0),
            "Contracts cannot be 0 address"
        );

        nft = ILotteryNFT(_lotteryNFT);
        randomGenerator = IRandomNumberGenerator(_randomNumberGenerator);
    }

    function costToBuyTickets(
        uint256 _lotteryId,
        uint256 _numberOfTickets
    ) 
        public 
        view 
        returns (uint256[2] memory totalCost) 
    {
        uint256 pricePer = allLotteries[_lotteryId].costPerTicket;
        uint256 bnbPricePer = allLotteries[_lotteryId].bnbCostPerTicket;
        
        return [
            pricePer.mul(_numberOfTickets),
            bnbPricePer.mul(_numberOfTickets)
        ];
    }

    function getBasicLotteryInfo(uint256 _lotteryId)
        external
        view
        returns(LotteryInfo memory)
    {
        return allLotteries[_lotteryId]; 
    }

    function getMaxRange() external view returns(uint16) {
        return allLotteries[lotteryIdCounter].maxValidRange;
    }

    function updateRouter(address _router)
        external
        onlyOwner()
    {
        require(
            _router != address(0x0),
            "Cannot set router to 0 address"
        );

        router = IPancakeV2Router02(_router);

        emit UpdatedRouter(_router);
    }
    
    function updateLotteryConfig(
        uint8 _numberSize,
        uint8 _numberRange,
        uint8[] calldata _prizeDistribution,
        uint256 _costPerTicket,
        uint256 _lotteryTimeout,
        uint256 _lotteryDuration
    )
        external
        onlyOwner
    {
        require(_numberSize > 0, "Number size must be > 0");
        require(_numberRange > 0, "Number range must be > 0");
        require(_costPerTicket > 0, "Ticket cost must be > 0");
        require(_lotteryDuration > 0, "Lottery duration must be > 0");
        require(
            _prizeDistribution.length == _numberSize,
            "Prize distribution must match lottery number size"
        );
        
        lotteryNumberSize = _numberSize;
        lotteryNumberRange = _numberRange;
        prizeDistribution = _prizeDistribution;
        costPerTicket = _costPerTicket;
        lotteryTimeout = _lotteryTimeout;
        lotteryDuration = _lotteryDuration;
        
        _calculateCombination();
    }

    function setLinkAmountToBuy(uint256 _amount)
        external
        onlyOwner()
    {
        linkAmountToBuy = _amount;

        emit UpdatedLinkAmountToBuy(_amount);
    }
    
    function setAutoRefillLink(bool _enabled)
        external
        onlyOwner()
    {
        autoRefillLink = _enabled;

        emit UpdatedAutoRefillLink(_enabled);
    }
    
    function updateLotteryBnbFeePercent(uint8 _newPercent)
        external 
        onlyOwner() 
    {
        require(
            _newPercent <= 25,
            "BNB fees should be lower or equal to 25"
        );
        
        bnbFeePercent = _newPercent;
        
        emit UpdatedBnbFeePercent(_newPercent);
    }
    
    function updateLotteryFeePercent(uint8 _newPercent)
        external
        onlyOwner()
    {
        require(
            _newPercent <= 25,
            "Lottery fees should be lower or equal to 25"
        );

        lotteryFeePercent = _newPercent;
        
        emit UpdatedLotteryFeePercent(_newPercent);
    }
    
    function drawWinningNumbers(
        uint256 _lotteryId, 
        uint256 _seed
    ) 
        external 
        onlyOwner() 
    {
        // Checks that the lottery is past the closing block
        require(
            allLotteries[_lotteryId].closingTimestamp <= block.timestamp,
            "Cannot set winning numbers during lottery"
        );
        // Checks lottery numbers have not already been drawn
        require(
            allLotteries[_lotteryId].lotteryStatus == Status.Open,
            "Lottery State incorrect for draw"
        );

        // Sets lottery status to closed
        allLotteries[_lotteryId].lotteryStatus = Status.Closed;
        // Requests a random number from the generator
        requestId = randomGenerator.getRandomNumber(_lotteryId, _seed);
        
        collectedFeesErc20 = collectedFeesErc20.add(
            allLotteries[_lotteryId].prizePoolInSdoge.mul(
                lotteryFeePercent).div(100));
        collectedFeesBnb = collectedFeesErc20.add(
            allLotteries[_lotteryId].prizePoolInSdoge.mul(
                lotteryFeePercent).div(100));

        // Emits that random number has been requested
        emit RequestNumbers(_lotteryId, requestId);
    }

    function numbersDrawn(
        uint256 _lotteryId,
        bytes32 _requestId, 
        uint256 _randomNumber
    )
        external
        onlyRandomGenerator()
    {
        require(
            allLotteries[_lotteryId].lotteryStatus == Status.Closed,
            "Draw numbers first"
        );

        if (requestId == _requestId) {
            allLotteries[_lotteryId].lotteryStatus = Status.Completed;
            allLotteries[_lotteryId].winningNumbers = _split(_randomNumber);
        }
        
        if (autoRefillLink)
            _refillGeneratorWithLink(_getAproxLinkBnbCost());

        emit LotteryClose(_lotteryId, nft.getTotalSupply());
    }
    
    function createNewConfiguredLottery(
        uint256[2] calldata _prizePool
    ) 
        external
        onlyOwner()
        returns (uint256)
    {
        uint256 lotteryStart = block.timestamp.add(lotteryTimeout);

        return createNewLottery(
            prizeDistribution,
            _prizePool,
            costPerTicket,
            lotteryStart,
            lotteryStart.add(lotteryDuration),
            lotteryNumberSize,
            lotteryNumberRange
        );
    }

    function createNewLottery(
        uint8[] memory _prizeDistribution,
        uint256[2] memory _prizePool,
        uint256 _costPerTicket,
        uint256 _startingTimestamp,
        uint256 _closingTimestamp,
        uint8 _sizeOfLotteryNumbers,
        uint8 _maxValidNumberRange
    )
        public
        onlyOwner()
        returns (uint256 lotteryId)
    {
        require(
            _prizeDistribution.length == _sizeOfLotteryNumbers,
            "Invalid distribution"
        );

        uint256 prizeDistributionTotal = 0;

        for (uint256 j = 0; j < _prizeDistribution.length; j++) {
            prizeDistributionTotal = prizeDistributionTotal.add(
                uint256(_prizeDistribution[j])
            );
        }
        
        // Ensuring that prize distribution total is in the bounds
        require(
            prizeDistributionTotal == uint(100).sub(lotteryFeePercent),
            "Prize distribution must mat lottery fee percent"
        );
        require(
            _prizePool[0] != 0 && _costPerTicket != 0,
            "Prize or cost cannot be 0"
        );
        require(
            _startingTimestamp != 0 &&
            _startingTimestamp < _closingTimestamp,
            "Timestamps for lottery invalid"
        );

        // Incrementing lottery ID 
        lotteryIdCounter = lotteryIdCounter.add(1);
        lotteryId = lotteryIdCounter;

        // Saving data in struct
        LotteryInfo memory newLottery = LotteryInfo(
            lotteryId,
            (_startingTimestamp >= block.timestamp) ?
                Status.Open : Status.NotStarted,
            _prizePool[0],
            _prizePool[1],
            _costPerTicket,
            _convertTicketPriceToBnb(_costPerTicket),
            _prizeDistribution,
            _startingTimestamp,
            _closingTimestamp,
            new uint8[](_sizeOfLotteryNumbers),
            _sizeOfLotteryNumbers,
            _maxValidNumberRange
        );

        allLotteries[lotteryId] = newLottery;

        // Emitting important information around new lottery.
        emit LotteryOpen(
            lotteryId, 
            nft.getTotalSupply()
        );
    }
    
    function emergencyWithdraw(
        uint256 _erc20Amount,
        uint256 _bnbAmount
    )
        public
        onlyOwner()
    {
        LotteryInfo memory last = allLotteries[lotteryIdCounter];
        
        require(
            last.lotteryStatus == Status.Completed,
            "Emergency withdraw only possible when completed"
        );
        require(
            block.timestamp >= last.closingTimestamp.add(
                EMERGENCY_WITHDRAW_TIMEOUT),
            "Need to wait before emergency withdrawing"
        );
        
        _withdrawErc20(msg.sender, _erc20Amount);
        _withdrawBnb(msg.sender, _bnbAmount);
        
        emit EmergencyWithdrawExecuted(_erc20Amount, _bnbAmount);
    }
    
    function withdrawFees(
        uint256 _erc20Amount,
        uint256 _bnbAmount
    )
        external
        onlyOwner()
    {
        require(
            _erc20Amount <= collectedFeesErc20,
            "Can't withdraw more ERC20 than collected"
        );
        require(
            _bnbAmount <= collectedFeesBnb,
            "Can't withdraw more BNB than collected"
        );
        
        collectedFeesErc20 = 0;
        collectedFeesBnb = 0;
        
        _withdrawErc20(msg.sender, _erc20Amount);
        _withdrawBnb(msg.sender, _bnbAmount);
        
        emit LotteryFeeCollected(_erc20Amount, _bnbAmount);
    }

    function batchBuyLotteryTicket(
        uint256 _lotteryId,
        uint8 _numberOfTickets,
        uint8[] calldata _chosenNumbersForEachTicket
    )
        external
        payable
        notContract()
    {
        uint256 currentTime = block.timestamp;
        // Ensuring the lottery is within a valid time
        require(
            currentTime >= allLotteries[_lotteryId].startingTimestamp,
            "Invalid time for mint:start"
        );
        require(
            currentTime < allLotteries[_lotteryId].closingTimestamp,
            "Invalid time for mint:end"
        );
        
        if (
            allLotteries[_lotteryId].lotteryStatus == Status.NotStarted && 
            allLotteries[_lotteryId].startingTimestamp >= currentTime
        ) {
            allLotteries[_lotteryId].lotteryStatus = Status.Open;
        }

        require(
            allLotteries[_lotteryId].lotteryStatus == Status.Open,
            "Lottery not in state for mint"
        );
        require(
            _numberOfTickets <= 50,
            "Batch mint too large"
        );

        // Ensuring that there are the right amount of chosen numbers
        require(
            _chosenNumbersForEachTicket.length
                == _numberOfTickets.mul(allLotteries[_lotteryId].sizeOfLottery),
            "Invalid chosen numbers"
        );

        uint256[2] memory totalCost
            = costToBuyTickets(_lotteryId, _numberOfTickets);
        
        // Checks if paying with bnb
        if (msg.value > 0) {
            require(
                msg.value >= totalCost[1],
                "Not enough BNB provided"
            );
            
            // Checks if too much money has been sent
            uint256 excedent = msg.value.sub(totalCost[1]);
            
            // If so, refunds
            if (excedent > MIN_REFUND) {
                (bool result,)
                    = address(msg.sender).call{value: excedent}("");
                    
                    require(
                        result,
                        "BNB excedent refund failed"
                    );
            }
        } else {
            // Transfers the required erc20 to this contract
            erc20.transferFrom(
                msg.sender, 
                address(this), 
                totalCost[0]
            );
        }

        // Batch mints the user their tickets
        uint256[] memory ticketIds = nft.batchMint(
            msg.sender,
            _lotteryId,
            _numberOfTickets,
            _chosenNumbersForEachTicket,
            allLotteries[_lotteryId].sizeOfLottery
        );

        // Emitting event with all information
        emit NewBatchMint(
            msg.sender,
            ticketIds,
            _chosenNumbersForEachTicket,
            (totalCost[0] != 0) ? totalCost[0] : totalCost[1]
        );
    }

    function batchClaimRewards(
        uint256 _lotteryId, 
        uint256[] calldata _tokenIds
    )
        external 
        notContract()
    {
        require(
            _tokenIds.length <= 50,
            "Batch claim too large"
        );
        // Checking the lottery is in a valid time for claiming
        require(
            allLotteries[_lotteryId].closingTimestamp <= block.timestamp,
            "Wait till end to claim"
        );
        // Checks the lottery winning numbers are available 
        require(
            allLotteries[_lotteryId].lotteryStatus == Status.Completed,
            "Winning Numbers not chosen yet"
        );

        // Creates a storage for all winnings
        uint256 totalPrize = 0;
        uint256 totalPrizeBnb = 0;

        // Loops through each submitted token
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            // Checks user is owner (will revert entire call if not)
            require(
                nft.getOwnerOfTicket(_tokenIds[i]) == msg.sender,
                "Only the owner can claim"
            );

            // If token has already been claimed, skip token
            if (nft.getTicketClaimStatus(_tokenIds[i]))
                continue;

            // Claims the ticket (will only revert if numbers invalid)
            require(
                nft.claimTicket(_tokenIds[i], _lotteryId),
                "Numbers for ticket invalid"
            );

            // Getting the number of matching tickets
            uint8 matchingNumbers = _getNumberOfMatching(
                nft.getTicketNumbers(_tokenIds[i]),
                allLotteries[_lotteryId].winningNumbers
            );

            // Getting the prize amount for those matching tickets
            (
                uint256 prizeAmount,
                uint256 prizeAmountBnb
            )= _prizeForMatching(matchingNumbers, _lotteryId);

            // Removing the prize amount from the pool
            allLotteries[_lotteryId].prizePoolInSdoge
                = allLotteries[_lotteryId].prizePoolInSdoge.sub(prizeAmount);
            allLotteries[_lotteryId].prizePoolInBnb
                = allLotteries[_lotteryId].prizePoolInBnb.sub(prizeAmountBnb);
            totalPrize = totalPrize.add(prizeAmount);
            totalPrizeBnb = totalPrizeBnb.add(prizeAmountBnb);
        }
        
        _withdrawErc20(msg.sender, totalPrize);
        _withdrawBnb(msg.sender, totalPrizeBnb);
    }
    
    function _withdrawErc20(address _recipient, uint256 _amount) internal {
        uint256 maxTxAmount = IScholarDogeToken(address(erc20)).getMaxTxAmount();
        
        // Checks if higher than max (imposed by $SDOGE)
        if (_amount > maxTxAmount) {
            // May cost a lot of gas if lots of tokens to widthdraw
            // but this have few probabilities to happen
            while (_amount > 0) {
                uint256 toWithdraw = _amount >= maxTxAmount
                    ? maxTxAmount : _amount;
                _amount = _amount.sub(toWithdraw);
                
                erc20.transfer(
                    _recipient, 
                    toWithdraw
                );
            }
        } else {
            erc20.transfer(
            _recipient, 
            _amount
            );
        }
    }
    
    function _withdrawBnb(address _recipient, uint256 _amount) internal {
        (bool result,)
            = address(_recipient).call{value: _amount}("");
        
        require(
            result,
            "BNB withdrawal failed");
    }

    function _getNumberOfMatching(
        uint8[] memory _usersNumbers, 
        uint8[] memory _winningNumbers
    )
        internal
        pure
        returns (uint8 noOfMatching)
    {
        // Loops through all winning numbers
        for (uint8 i = 0; i < _winningNumbers.length; i++) {
            // If the winning numbers and user numbers match
            if(_usersNumbers[i] == _winningNumbers[i]) {
                // The number of matching numbers incrases
                noOfMatching += 1;
            }
        }
    }

    function _prizeForMatching(
        uint8 _noOfMatching,
        uint256 _lotteryId
    ) 
        internal  
        view
        returns(uint256, uint256) 
    {
        uint256 prize = 0;
        uint256 prizeBnb = 0;

        // If user has no matching numbers their prize is 0
        if (_noOfMatching == 0)
            return (0, 0);

        // Getting the percentage of the pools the user has won
        uint256 perOfPool
            = allLotteries[_lotteryId].prizeDistribution[_noOfMatching-1];

        // Timesing the percentage one by the pool
        prize = allLotteries[_lotteryId].prizePoolInSdoge.mul(perOfPool);
        prizeBnb = allLotteries[_lotteryId].prizePoolInBnb.mul(perOfPool);

        // Returning the prize divided by 100 (as the prize distribution is scaled)
        return (prize.div(100), prizeBnb.div(100));
    }
    
    function _factorial(uint256 nb) internal pure returns (uint256) {
        if (nb == 0) {
            return 1;
        } else {
            return nb.mul(_factorial(nb.sub(1)));
        }
    }
    
    function _calculateCombination() internal pure {
        
    }
    
    function _generateNumberIndexKey(uint8[] memory number) 
        internal
        pure
        returns (uint64[] memory)
    {
        uint64[] memory tempNumber;
        
        for (uint8 i = 0; i < lotteryNumberSize; ++i) {
            tempNumber[i] = number[i];
        }

        uint64[] memory result;
        
        for (uint16 i = 0; i < lotteryCombination.sub(1); ++i) {
            uint256 tmpResult;
            
            for (uint8 j = 0; j < lotteryNumberSize; ++j) {
                
            }
        }
 
        result[0] = tempNumber[0].mul(MAGIC_NB ** 6).add(MAGIC_NB ** 5)
            .add(tempNumber[1].mul(MAGIC_NB ** 4)).add(2.mul(MAGIC_NB ** 3))
            .add(tempNumber[2].mul(MAGIC_NB ** 2)).add(3.mul(MAGIC_NB))
            .add(tempNumber[3]);

        result[1] = tempNumber[0].mul(MAGIC_NB ** 4).add(MAGIC_NB)
            .add(tempNumber[1].mul(MAGIC_NB ** 2)).add(2.mul(MAGIC_NB))
            .add(tempNumber[2]);
        result[2] = tempNumber[0].mul(MAGIC_NB ** 4).add(MAGIC_NB ** 3)
            .add(tempNumber[1].mul(MAGIC_NB ** 2)).add(3.mul(MAGIC_NB))
            .add(tempNumber[3]);
        result[3] = tempNumber[0].mul(MAGIC_NB ** 4).add(2.mul(MAGIC_NB ** 3))
            .add(tempNumber[2].mul(MAGIC_NB ** 2)).add(3.mul(MAGIC_NB))
            .add(tempNumber[3]);
        result[4] = MAGIC_NB ** 5.add(tempNumber[1].mul(MAGIC_NB ** 4))
            .add(2.mul(MAGIC_NB ** 3)).add(tempNumber[2].mul(MAGIC_NB ** 2))
            .add(3.mul(MAGIC_NB)).add(tempNumber[3]);

        result[5] = tempNumber[0].mul(MAGIC_NB ** 2).add(MAGIC_NB)
            .add(tempNumber[1]);
        result[6] = tempNumber[0].mul(MAGIC_NB ** 2).add(2.mul(MAGIC_NB))
            .add(tempNumber[2]);
        result[7] = tempNumber[0].mul(MAGIC_NB ** 2).add(3.mul(MAGIC_NB))
            .add(tempNumber[3]);
        result[8] = MAGIC_NB ** 3.add(tempNumber[1].mul(MAGIC_NB ** 2))
            .add(2.mul(MAGIC_NB)).add(tempNumber[2]);
        result[9] = MAGIC_NB ** 3.add(tempNumber[1].mul(MAGIC_NB ** 2))
            .add(3.mul(MAGIC_NB)).add(tempNumber[3]);
        result[10] = 2.add(MAGIC_NB ** 3).add(tempNumber[2].mul(MAGIC_NB ** 2))
            .add(3.mul(MAGIC_NB)).add(tempNumber[3]);

        return result;
    }
    
    // calculate price based on pair reserves
    function _convertTicketPriceToBnb(uint256 price)
        public
        view
        returns (uint256)
    {
        uint256 taxedPrice
            = price.add(price.mul(bnbFeePercent).div(100));
        IPancakeV2Pair pair = IPancakeV2Pair(IPancakeV2Factory(router.factory())
            .getPair(address(erc20), router.WETH()));
        (uint256 left, uint256 right,) = pair.getReserves();
        (uint256 tokenRes, uint256 bnbRes) = (address(erc20) < router.WETH()) ?
        (left, right) : (right, left);

        return taxedPrice.mul(bnbRes).div(tokenRes);
    }

    function _split(
        uint256 _randomNumber
    ) 
        internal
        view 
        returns(uint8[] memory) 
    {
        uint8 sizeOfLottery = allLotteries[lotteryIdCounter].sizeOfLottery;
        uint8 maxValidRange = allLotteries[lotteryIdCounter].maxValidRange;
        // Temparary storage for winning numbers
        uint8[] memory winningNumbers
            = new uint16[](sizeOfLottery);

        // Loops the size of the number of tickets in the lottery
        for(uint i = 0; i < sizeOfLottery; i++){
            // Encodes the random number with its position in loop
            bytes32 hashOfRandom = keccak256(abi.encodePacked(_randomNumber, i));
            // Casts random number hash into uint256
            uint256 numberRepresentation = uint256(hashOfRandom);

            // Sets the winning number position to a uint of random hash number
            winningNumbers[i] = uint8(numberRepresentation.mod(maxValidRange));
        }
        
        
        return winningNumbers;
    }
    
    function _refillGeneratorWithLink(uint256 value) internal {
        address[] memory path = new address[](2);
        
        path[0] = router.WETH();
        path[1] = LINK_TOKEN;
        
        router.swapETHForExactTokens{value: value}(
            linkAmountToBuy,
            path,
            address(randomGenerator),
            block.timestamp)[1];
    }
    
    function _getAproxLinkBnbCost() public view returns (uint256) {
        uint256 margin = linkAmountToBuy.mul(10).div(100);
        uint256 amountWithMargin = linkAmountToBuy.add(margin);
        address token = LINK_TOKEN;
        IPancakeV2Pair pair
            = IPancakeV2Pair(IPancakeV2Factory(router.factory())
                .getPair(token, router.WETH()));
        (uint256 left, uint256 right,) = pair.getReserves();
        (uint256 linkRes, uint256 bnbRes)
            = (address(erc20) < router.WETH()) ?
            (left, right) : (right, left);
        
        return amountWithMargin.mul(bnbRes).div(linkRes);
    }
    
    fallback() external payable {
    }
    
    receive() external payable {
    }
}
