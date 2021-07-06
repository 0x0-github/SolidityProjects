//SPDX-License-Identifier: MIT

pragma solidity >= 0.6.0 < 0.8.0;

pragma experimental ABIEncoderV2;

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
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
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
        returns(uint16[] memory);

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
        uint16[] calldata _numbers,
        uint8 sizeOfLottery
    )
        external
        returns(uint256[] memory);

    function claimTicket(uint256 _ticketId, uint256 _lotteryId) external returns(bool);
}

interface IScholarAidToken {
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

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !Address.isContract(address(this));
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal virtual {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract ScholarAidLottery is Ownable, Initializable {
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
        uint256 prizePoolInSaid;
        uint256 prizePoolInBnb;
        uint256 costPerTicket;
        uint256 bnbCostPerTicket;
        uint8[] prizeDistribution;
        uint256 startingTimestamp;
        uint256 closingTimestamp;
        uint16[] winningNumbers;
        uint8 sizeOfLottery;
        uint16 maxValidRange;
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

    // Instance of ScholarAidToken (first currency for lotto)
    IERC20 internal erc20_;
    ILotteryNFT internal nft_;
    IRandomNumberGenerator internal randomGenerator_;
    // Main net: 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    // Test net: 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    IPancakeV2Router02 public router_;
    
    uint256 private lotteryIdCounter_;
    
    bytes32 internal requestId_;
    
    bool public autoRefillLink = true;
    
    uint8 public constant MAX_WIDRAW_LOOP = 10;
    
    // Base config
    uint8 public lotteryNumberSize = 4;
    uint16 public lotteryNumberRange = 15;
    uint256 public lotteryTimeout = 1 minutes;
    uint256 public lotteryDuration = 5 minutes;
    uint8[] public prizeDistribution = [5, 10, 20, 50];
    uint256 public costPerTicket = 1000000000;
    
    uint256 public linkAmountToBuy = LINK_FEES.mul(5);
    
    // Defines the fees for purchasing tickets with BNB
    uint8 public bnbFeePercent_ = 10;
    // Defines the % of collected fees
    uint8 public lotteryFeePercent_ = 15;
    
    uint256 public collectedFeesErc20;
    uint256 public collectedFeesBnb;

    // Lottery ID's to info
    mapping(uint256 => LotteryInfo) internal allLotteries_;

    event NewBatchMint(
        address indexed minter,
        uint256[] ticketIDs,
        uint16[] numbers,
        uint256 totalCost
    );

    event RequestNumbers(uint256 lotteryId, bytes32 requestId);
    
    event UpdatedBnbFeePercent(uint256 newPercent);
    
    event UpdatedLotteryFeePercent(uint256 newPercent);
    
    event UpdatedRouter(address newAddress);
    
    event UpdatedLotteryNumberSize(uint8 newValue);
    
    event UpdatedLotteryNumberRange(uint16 newValue);
    
    event UpdatedLotteryTimeout(uint256 newValue);
    
    event UpdatedLotteryDuration(uint256 newValue);
    
    event UpdatedPrizeDistribution(uint8[] newValue);
    
    event UpdatedCostPerTicket(uint256 newValue);
    
    event UpdatedLinkAmountToBuy(uint256 newValue);
    
    event UpdatedAutoRefillLink(bool newValue);
    
    event EmergencyWithdrawExecuted(uint256 erc20, uint256 bnb);
    
    event LotteryFeeCollected(uint256 erc20, uint256 bnb);
    
    event LotteryOpen(uint256 lotteryId, uint256 ticketSupply);

    event LotteryClose(uint256 lotteryId, uint256 ticketSupply);

    modifier onlyRandomGenerator() {
        require(
            msg.sender == address(randomGenerator_),
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
        
        router_
            = IPancakeV2Router02(0xD99D1c33F9fC3444f8101754aBC46c52416550D1);
        erc20_ = IERC20(_erc20);
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

        nft_ = ILotteryNFT(_lotteryNFT);
        randomGenerator_ = IRandomNumberGenerator(_randomNumberGenerator);
    }

    function costToBuyTickets(
        uint256 _lotteryId,
        uint256 _numberOfTickets
    ) 
        public 
        view 
        returns (uint256[2] memory totalCost) 
    {
        uint256 pricePer = allLotteries_[_lotteryId].costPerTicket;
        uint256 bnbPricePer = allLotteries_[_lotteryId].bnbCostPerTicket;
        
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
        return allLotteries_[_lotteryId]; 
    }

    function getMaxRange() external view returns(uint16) {
        return allLotteries_[lotteryIdCounter_].maxValidRange;
    }

    function updateRouter(address _router)
        external
        onlyOwner()
    {
        require(
            _router != address(0x0),
            "Cannot set router to 0 address"
        );

        router_ = IPancakeV2Router02(router_);

        emit UpdatedRouter(_router);
    }
    
    function setLotteryNumberSize(uint8 size) external onlyOwner() {
        require(size > 0, "Size must be greater than 0");
        
        lotteryNumberSize = size;
        
        emit UpdatedLotteryNumberSize(size);
    }
    
    function setLotteryNumberRange(uint16 range) external onlyOwner() {
        require(range > 0, "Range must be greater than 0");
        
        lotteryNumberRange = range;
        
        emit UpdatedLotteryNumberRange(range);
    }
    
    function setLotteryTimeout(uint256 timeout) external onlyOwner() {
        require(timeout > 0, "Timeout must be greater than 0");
        
        lotteryTimeout = timeout;
        
        emit UpdatedLotteryTimeout(timeout);
    }
    
    function setLotteryDuration(uint256 duration) external onlyOwner() {
        require(duration > 0, "Duration must be greater than 0");
        
        lotteryDuration = duration;
        
        emit UpdatedLotteryDuration(duration);
    }
    
    function setPrizeDistribution(uint8[] memory distribution)
        external
        onlyOwner()
    {
        require(distribution.length == lotteryNumberSize,
            "Distribution must match to lottery size");
        
        prizeDistribution = distribution;
        
        emit UpdatedPrizeDistribution(distribution);
    }
    
    function setCostPerTicket(uint256 cost) external onlyOwner() {
        require(cost > 0, "Cost must be greater than 0");
        
        costPerTicket = cost;
        
        emit UpdatedCostPerTicket(cost);
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
        
        bnbFeePercent_ = _newPercent;
        
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

        lotteryFeePercent_ = _newPercent;
        
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
            allLotteries_[_lotteryId].closingTimestamp <= block.timestamp,
            "Cannot set winning numbers during lottery"
        );
        // Checks lottery numbers have not already been drawn
        require(
            allLotteries_[_lotteryId].lotteryStatus == Status.Open,
            "Lottery State incorrect for draw"
        );

        // Sets lottery status to closed
        allLotteries_[_lotteryId].lotteryStatus = Status.Closed;
        // Requests a random number from the generator
        requestId_ = randomGenerator_.getRandomNumber(_lotteryId, _seed);
        
        collectedFeesErc20 = collectedFeesErc20.add(
            allLotteries_[_lotteryId].prizePoolInSaid.mul(
                lotteryFeePercent_).div(100));
        collectedFeesBnb = collectedFeesErc20.add(
            allLotteries_[_lotteryId].prizePoolInSaid.mul(
                lotteryFeePercent_).div(100));

        // Emits that random number has been requested
        emit RequestNumbers(_lotteryId, requestId_);
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
            allLotteries_[_lotteryId].lotteryStatus == Status.Closed,
            "Draw numbers first"
        );

        if (requestId_ == _requestId) {
            allLotteries_[_lotteryId].lotteryStatus = Status.Completed;
            allLotteries_[_lotteryId].winningNumbers = _split(_randomNumber);
        }
        
        if (autoRefillLink)
            _refillGeneratorWithLink(_getAproxLinkBnbCost());

        emit LotteryClose(_lotteryId, nft_.getTotalSupply());
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
        uint16 _maxValidNumberRange
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
            prizeDistributionTotal == uint(100).sub(lotteryFeePercent_),
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
        lotteryIdCounter_ = lotteryIdCounter_.add(1);
        lotteryId = lotteryIdCounter_;

        // Saving data in struct
        LotteryInfo memory newLottery = LotteryInfo(
            lotteryId,
            (_startingTimestamp >= block.timestamp) ?
                Status.Open : Status.NotStarted,
            _prizePool[0],
            _prizePool[1],
            _costPerTicket,
            convertTicketPriceToBnb(_costPerTicket),
            _prizeDistribution,
            _startingTimestamp,
            _closingTimestamp,
            new uint16[](_sizeOfLotteryNumbers),
            _sizeOfLotteryNumbers,
            _maxValidNumberRange
        );

        allLotteries_[lotteryId] = newLottery;

        // Emitting important information around new lottery.
        emit LotteryOpen(
            lotteryId, 
            nft_.getTotalSupply()
        );
    }
    
    function withdrawErc20(address _recipient, uint256 _amount) internal {
        uint256 maxTxAmount = IScholarAidToken(address(erc20_)).getMaxTxAmount();
        
        // Checks if higher than max (imposed by SAID)
        if (_amount > maxTxAmount) {
            // May cost a lot of gas if lots of tokens to widthdraw
            // but this have few probabilities to happen
            while (_amount > 0) {
                uint256 toWithdraw = _amount >= maxTxAmount
                    ? maxTxAmount : _amount;
                _amount = _amount.sub(toWithdraw);
                
                erc20_.transfer(
                    _recipient, 
                    toWithdraw
                );
            }
        } else {
            erc20_.transfer(
            _recipient, 
            _amount
            );
        }
    }
    
    function withdrawBnb(address _recipient, uint256 _amount) internal {
        (bool result,)
            = address(_recipient).call{value: _amount}("");
        
        require(
            result,
            "BNB withdrawal failed");
    }
    
    function emergencyWithdraw(
        uint256 _erc20Amount,
        uint256 _bnbAmount
    )
        public
        onlyOwner()
    {
        LotteryInfo memory last = allLotteries_[lotteryIdCounter_];
        
        require(
            last.lotteryStatus == Status.Completed,
            "Emergency withdraw only possible when completed"
        );
        require(
            block.timestamp >= last.closingTimestamp.add(
                EMERGENCY_WITHDRAW_TIMEOUT),
            "Need to wait before emergency withdrawing"
        );
        
        withdrawErc20(msg.sender, _erc20Amount);
        withdrawBnb(msg.sender, _bnbAmount);
        
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
        
        withdrawErc20(msg.sender, _erc20Amount);
        withdrawBnb(msg.sender, _bnbAmount);
        
        emit LotteryFeeCollected(_erc20Amount, _bnbAmount);
    }

    function batchBuyLotteryTicket(
        uint256 _lotteryId,
        uint8 _numberOfTickets,
        uint16[] calldata _chosenNumbersForEachTicket
    )
        external
        payable
        notContract()
    {
        uint256 currentTime = block.timestamp;
        // Ensuring the lottery is within a valid time
        require(
            currentTime >= allLotteries_[_lotteryId].startingTimestamp,
            "Invalid time for mint:start"
        );
        require(
            currentTime < allLotteries_[_lotteryId].closingTimestamp,
            "Invalid time for mint:end"
        );
        
        if (
            allLotteries_[_lotteryId].lotteryStatus == Status.NotStarted && 
            allLotteries_[_lotteryId].startingTimestamp >= currentTime
        ) {
            allLotteries_[_lotteryId].lotteryStatus = Status.Open;
        }

        require(
            allLotteries_[_lotteryId].lotteryStatus == Status.Open,
            "Lottery not in state for mint"
        );
        require(
            _numberOfTickets <= 50,
            "Batch mint too large"
        );

        // Ensuring that there are the right amount of chosen numbers
        require(
            _chosenNumbersForEachTicket.length
                == _numberOfTickets.mul(allLotteries_[_lotteryId].sizeOfLottery),
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
            erc20_.transferFrom(
                msg.sender, 
                address(this), 
                totalCost[0]
            );
        }

        // Batch mints the user their tickets
        uint256[] memory ticketIds = nft_.batchMint(
            msg.sender,
            _lotteryId,
            _numberOfTickets,
            _chosenNumbersForEachTicket,
            allLotteries_[_lotteryId].sizeOfLottery
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
        uint256[] calldata _tokeIds
    )
        external 
        notContract()
    {
        require(
            _tokeIds.length <= 50,
            "Batch claim too large"
        );
        // Checking the lottery is in a valid time for claiming
        require(
            allLotteries_[_lotteryId].closingTimestamp <= block.timestamp,
            "Wait till end to claim"
        );
        // Checks the lottery winning numbers are available 
        require(
            allLotteries_[_lotteryId].lotteryStatus == Status.Completed,
            "Winning Numbers not chosen yet"
        );

        // Creates a storage for all winnings
        uint256 totalPrize = 0;
        uint256 totalPrizeBnb = 0;

        // Loops through each submitted token
        for (uint256 i = 0; i < _tokeIds.length; i++) {
            // Checks user is owner (will revert entire call if not)
            require(
                nft_.getOwnerOfTicket(_tokeIds[i]) == msg.sender,
                "Only the owner can claim"
            );

            // If token has already been claimed, skip token
            if (nft_.getTicketClaimStatus(_tokeIds[i]))
                continue;

            // Claims the ticket (will only revert if numbers invalid)
            require(
                nft_.claimTicket(_tokeIds[i], _lotteryId),
                "Numbers for ticket invalid"
            );

            // Getting the number of matching tickets
            uint8 matchingNumbers = _getNumberOfMatching(
                nft_.getTicketNumbers(_tokeIds[i]),
                allLotteries_[_lotteryId].winningNumbers
            );

            // Getting the prize amount for those matching tickets
            (
                uint256 prizeAmount,
                uint256 prizeAmountBnb
            )= _prizeForMatching(matchingNumbers, _lotteryId);

            // Removing the prize amount from the pool
            allLotteries_[_lotteryId].prizePoolInSaid
                = allLotteries_[_lotteryId].prizePoolInSaid.sub(prizeAmount);
            allLotteries_[_lotteryId].prizePoolInBnb
                = allLotteries_[_lotteryId].prizePoolInBnb.sub(prizeAmountBnb);
            totalPrize = totalPrize.add(prizeAmount);
            totalPrizeBnb = totalPrizeBnb.add(prizeAmountBnb);
        }
        
        withdrawErc20(msg.sender, totalPrize);
        withdrawBnb(msg.sender, totalPrizeBnb);
    }

    function _getNumberOfMatching(
        uint16[] memory _usersNumbers, 
        uint16[] memory _winningNumbers
    )
        internal
        pure
        returns (uint8 noOfMatching)
    {
        // Loops through all wimming numbers
        for (uint256 i = 0; i < _winningNumbers.length; i++) {
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
            = allLotteries_[_lotteryId].prizeDistribution[_noOfMatching-1];

        // Timesing the percentage one by the pool
        prize = allLotteries_[_lotteryId].prizePoolInSaid.mul(perOfPool);
        prizeBnb = allLotteries_[_lotteryId].prizePoolInBnb.mul(perOfPool);

        // Returning the prize divided by 100 (as the prize distribution is scaled)
        return (prize.div(100), prizeBnb.div(100));
    }
    
    // calculate price based on pair reserves
    function convertTicketPriceToBnb(uint256 price)
        public
        view
        returns (uint)
    {
        uint256 taxedPrice
            = price.add(price.mul(bnbFeePercent_).div(100));
        IPancakeV2Pair pair = IPancakeV2Pair(IPancakeV2Factory(router_.factory())
            .getPair(address(erc20_), router_.WETH()));
        (uint left, uint right,) = pair.getReserves();
        (uint tokenRes, uint bnbRes) = (address(erc20_) < router_.WETH()) ?
        (left, right) : (right, left);

        return taxedPrice.mul(bnbRes).div(tokenRes);
    }

    function _split(
        uint256 _randomNumber
    ) 
        internal
        view 
        returns(uint16[] memory) 
    {
        uint8 sizeOfLottery = allLotteries_[lotteryIdCounter_].sizeOfLottery;
        uint16 maxValidRange = allLotteries_[lotteryIdCounter_].maxValidRange;
        // Temparary storage for winning numbers
        uint16[] memory winningNumbers
            = new uint16[](sizeOfLottery);

        // Loops the size of the number of tickets in the lottery
        for(uint i = 0; i < sizeOfLottery; i++){
            // Encodes the random number with its position in loop
            bytes32 hashOfRandom = keccak256(abi.encodePacked(_randomNumber, i));
            // Casts random number hash into uint256
            uint256 numberRepresentation = uint256(hashOfRandom);

            // Sets the winning number position to a uint16 of random hash number
            winningNumbers[i] = uint16(numberRepresentation.mod(maxValidRange));
        }
        
        
        return winningNumbers;
    }
    
    function _refillGeneratorWithLink(uint value) internal {
        address[] memory path = new address[](2);
        
        path[0] = router_.WETH();
        path[1] = LINK_TOKEN;
        
        router_.swapETHForExactTokens{value: value}(
            linkAmountToBuy,
            path,
            address(randomGenerator_),
            block.timestamp)[1];
    }
    
    function _getAproxLinkBnbCost() public view returns (uint256) {
        uint margin = linkAmountToBuy.mul(10).div(100);
        uint amountWithMargin = linkAmountToBuy.add(margin);
        address token = LINK_TOKEN;
        IPancakeV2Pair pair
            = IPancakeV2Pair(IPancakeV2Factory(router_.factory())
                .getPair(token, router_.WETH()));
        (uint left, uint right,) = pair.getReserves();
        (uint linkRes, uint bnbRes)
            = (address(erc20_) < router_.WETH()) ?
            (left, right) : (right, left);
        
        return amountWithMargin.mul(bnbRes).div(linkRes);
    }
    
    fallback() external payable {
    }
    
    receive() external payable {
    }
}
