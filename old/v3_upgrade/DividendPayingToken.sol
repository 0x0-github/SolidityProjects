// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./BEP20.sol";
import "./SafeMath.sol";
import "./SignedSafeMath.sol";
import "./IDividendPayingToken2.sol";
import "./IDividendPayingTokenOptional2.sol";
import "./IScholarDogeToken.sol";

/// @title Dividend-Paying Token
/// @author Roger Wu (https://github.com/roger-wu)
/// @dev A mintable ERC20 token that allows anyone to pay
/// and distribute bnb to token holders as dividends and 
/// allows token holders to withdraw their dividends.
/// Reference: the source code of PoWH3D:
/// https://etherscan.io/address/0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe#code
contract DividendPayingToken2 is 
    BEP20,
    IDividendPayingToken2,
    IDividendPayingTokenOptional2
{
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 constant internal magnitude = 2**128;
    
    IScholarDogeToken public immutable sdoge;

    mapping(address => uint256) internal magnifiedDividendPerShare;
    
    // Used gas for withdraw, can be updated as it may change
    uint256 internal withdrawGas = 6000;
    
    uint64 internal rewardTokenCount;
    
    mapping(address => bool) internal addedTokens;
    
    address[] public rewardTokens;

    mapping(address => mapping(address => int256))
        internal magnifiedDividendCorrections;
    mapping(address => mapping(address => uint256))
        internal withdrawnDividends;

    mapping(address => uint256) internal totalDividendsDistributed;
    
    event RewardTokenAdded(address indexed rewardToken);

    constructor(address _sdoge, string memory _name, string memory _symbol)
        BEP20(_name, _symbol)
    {
        sdoge = IScholarDogeToken(_sdoge);
    }

    receive() external override payable {
        _distributeDividends(sdoge.wbnb(), msg.value);
    }
    
    function receiveTokens(
        address _token,
        uint256 _collected
    )
        external
        virtual
        override
    {
        _distributeDividends(_token, _collected);
    }
    
    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
    
    function addRewardToken(address _token) public virtual {
        if (!addedTokens[_token]) {
            addedTokens[_token] = true;
            rewardTokens.push(_token);
            rewardTokenCount++;
        
            emit RewardTokenAdded(_token);
        }
    }
    
    function _distributeDividends(
        address _token,
        uint256 _amount
    )
        internal
    {
        require(totalSupply() > 0);
        
        if (_amount > 0) {
            magnifiedDividendPerShare[_token] += 
                _amount * magnitude / totalSupply();
            totalDividendsDistributed[_token] += _amount;
            
            emit DividendsDistributed(_token, msg.sender, _amount);
        }
    }

    function withdrawDividend(address _token) public virtual override {
        _withdrawDividendOfUser(payable(msg.sender), _token);
    }

    function _withdrawDividendOfUser(address payable _user, address _token)
        internal
        virtual
        returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(_user, _token);
    
        if (_withdrawableDividend > 0) {
            withdrawnDividends[_token][_user] += _withdrawableDividend;
      
            emit DividendWithdrawn(_token, _user, _withdrawableDividend);
            
            bool success;
        
            if (_token == sdoge.wbnb()) {
                (success,) = _user.call{
                    value: _withdrawableDividend,
                    gas: withdrawGas
                }("");
            } else {
                success = BEP20(_token).transfer(_user, _withdrawableDividend);
            }
            
    
            if (!success) {
                withdrawnDividends[_token][_user] -= _withdrawableDividend;
            
                return 0;
            }
    
            return _withdrawableDividend;
        }

        return 0;
    }
    
    function dividendOf(address _owner, address _token)
        public
        view
        override
        returns (uint256)
    {
        return withdrawableDividendOf(_owner, _token);
    }
    
    function withdrawableDividendOf(address _owner, address _token)
        public
        view
        override
        returns (uint256)
    {
        return accumulativeDividendOf(_owner, _token)
            - withdrawnDividends[_token][_owner];
    }
    
    function withdrawnDividendOf(address _owner, address _token)
        public
        view
        override
        returns (uint256)
    {
        return withdrawnDividends[_token][_owner];
    }

    function accumulativeDividendOf(address _owner, address _token)
        public
        view
        override
        returns (uint256)
    {
        return ((magnifiedDividendPerShare[_token] * balanceOf(_owner)).toInt256Safe()
            + magnifiedDividendCorrections[_token][_owner]).toUint256Safe() / magnitude;
    }

    function _transfer(address from, address to, uint256 value)
        internal
        virtual
        override
    {
        super._transfer(from, to, value);

        int256 _magCorrection
            = (magnifiedDividendPerShare[sdoge.getRewardToken()] * value).toInt256Safe();
            
        magnifiedDividendCorrections[sdoge.getRewardToken()][from]
            += _magCorrection;
        magnifiedDividendCorrections[sdoge.getRewardToken()][to]
            -= _magCorrection;
    }

    function _mint(address account, uint256 value) internal override {
        super._mint(account, value);

        magnifiedDividendCorrections[sdoge.getRewardToken()][account]
            -= (magnifiedDividendPerShare[sdoge.getRewardToken()] * value).toInt256Safe();
    }

    function _burn(address account, uint256 value) internal override {
        super._burn(account, value);

        magnifiedDividendCorrections[sdoge.getRewardToken()][account]
            += (magnifiedDividendPerShare[sdoge.getRewardToken()] * value).toInt256Safe();
    }

    function _setBalance(address account, uint256 newBalance) internal {
        uint256 currentBalance = balanceOf(account);

        if (newBalance > currentBalance) {
            uint256 mintAmount = newBalance - currentBalance;
        
            _mint(account, mintAmount);
        } else if (newBalance < currentBalance) {
            uint256 burnAmount = currentBalance - newBalance;
        
            _burn(account, burnAmount);
        }
    }
}
