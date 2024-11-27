// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owne2r, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function feeTo() external view returns (address);

}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!o");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "n0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenDistributor {
     address public _owner;
    constructor (address token, address mainContract) {
        _owner = msg.sender;
        IERC20(token).approve(msg.sender, ~uint256(0));
        IERC20(token).approve(mainContract, ~uint256(0));
    }

    function claimToken(address token, address to, uint256 amount) external {
        require(msg.sender == _owner, "!o");
        IERC20(token).transfer(to, amount);
    }
}

interface ISwapPair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function sync() external;

    function totalSupply() external view returns (uint);
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        return a + b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;
    
    struct UserInfo {
        uint256 buyAmount;
        uint256 lastRewardTime;
        address inviter;
    }

    // Constants
    uint256[10] private levelPercentages = [10, 8, 6, 4, 2, 10, 8, 6, 4, 2];
    uint256 public constant MAX_TRANSFER_LIMIT = 10000 * (10 ** 6);
    uint256 private constant MIN_SWAP_INTERVAL = 2 * 60;
    uint256 private constant DAILY_REWARD_RATE = 8;
    uint256 private constant MAX_BUY_AMOUNT = 20000 * (10 ** 18);
    uint256 public constant TOTAL_SUPPLY = 21_000_000;
    uint256 public constant CIRCULATION = 2_000_000;
    uint256 public constant RESERVED_FOR_MINING = TOTAL_SUPPLY - CIRCULATION;
    uint256 private constant MAX = ~uint256(0);

    // Mappings
    mapping(address => uint256) public _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) public _directDownlines;
    mapping(address => uint256) public lastSwapTime;    
    mapping(address => bool) private _feeWhiteList;
    mapping(address => UserInfo) private _userInfo;
    mapping(address => bool) public _excludeRewards;
    mapping(address => bool) public _preLPList;
    mapping(address => bool) public _swapPairList;
    mapping(address => address[]) public _binders;
    mapping(address => mapping(address => bool)) public _maybeInvitor;
    mapping(address => uint256) public _lastLPRewardTimes;
    mapping(address => uint256) private _userLPAmount;
    mapping(address => uint256) public lpProviderIndex;
    mapping(address => bool) public excludeLpProvider;


    // Addresses
    address public receiveAddress;
    address public fundAddress;
    address public devAddress;

    // Trade Management
    uint256 public _buyDevFee = 50;
    uint256 public _buyFundFee = 150;
    uint256 public _sellDestroyFee = 100;
    uint256 public _sellReservePoolFee = 100;
    uint256 public _removeLPFee = 200;

    // Liquidity Burn
    uint256 public percentForLPBurn = 25; //.25%
    bool public lpBurnEnabled = false;
    uint256 public lpBurnFrequency = 1 hours;
    uint256 public lastLpBurnTime;
    
    // Trade Management
    uint256 public startTradeBlock;
    uint256 public startAddLPBlock;  
    uint256 public _startTradeTime;

    // LP Management 
    uint256 public currentLPIndex;
    uint256 public progressLPBlock;
    uint256 public lpHoldCondition = 1000;
    uint256 public _rewardGas = 1000000;
    uint256 public lpRewardTimeDebt = 5 days;
    address public _lastMaybeAddLPAddress;
    uint256 public _lastMaybeAddLPAmount;
    address[] public lpProviders;
   

    // Token Metadata
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _tTotal;
    bool private inSwap;

    ISwapRouter public immutable _swapRouter;
    address public immutable _mainPair;
    address public  immutable _usdt;

    TokenDistributor public immutable _tokenDistributor;
 
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }
    modifier onlyWhiteList() {
        address msgSender = msg.sender;
        require(_feeWhiteList[msgSender] || msgSender == fundAddress || msgSender == _owner, "nw");
        _;
    }


    event AutoNukeLP();

    constructor (
        address RouterAddress, address usdtAddress,
        string memory Name, string memory Symbol, uint8 Decimals,
        address ReceiveAddress, address FundAddress, address DevAddress
    ){
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;


        ISwapRouter swapRouter = ISwapRouter(RouterAddress);
        _swapRouter = swapRouter;
        _allowances[address(this)][address(swapRouter)] = MAX;

        ISwapFactory swapFactory = ISwapFactory(swapRouter.factory());
        _usdt = usdtAddress;
        IERC20(_usdt).approve(address(swapRouter), MAX);
        address mainPair = swapFactory.createPair(address(this), _usdt);
        _swapPairList[mainPair] = true;
        _mainPair = mainPair;

        uint256 tokenDecimals = 10 ** Decimals;
        uint256 total = TOTAL_SUPPLY * tokenDecimals;
        uint256 receiveTotal = CIRCULATION * tokenDecimals;
        uint256 reserves = RESERVED_FOR_MINING * tokenDecimals;
        _tTotal = total;

        _balances[ReceiveAddress] = receiveTotal;
        emit Transfer(address(0), ReceiveAddress, receiveTotal);
        fundAddress = FundAddress;
        devAddress = DevAddress;
        receiveAddress = ReceiveAddress;

        _tokenDistributor = new  TokenDistributor(_usdt, address(this));
        address tokenDistributor = address(_tokenDistributor);
        _balances[tokenDistributor] = reserves;
        emit Transfer(address(0), tokenDistributor, reserves);

        _feeWhiteList[ReceiveAddress] = true;
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[address(swapRouter)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(0)] = true;
        _feeWhiteList[address(0x000000000000000000000000000000000000dEaD)] = true;
        _feeWhiteList[tokenDistributor] = true;

        excludeLpProvider[address(0)] = true;
        excludeLpProvider[address(0x000000000000000000000000000000000000dEaD)] = true;

        _excludeRewards[address(0)] = true;
        _excludeRewards[address(0x000000000000000000000000000000000000dEaD)] = true;
        _excludeRewards[address(this)] = true;
        _excludeRewards[tokenDistributor] = true;

        _excludeRewards[mainPair] = true;
        _excludeRewards[address(swapRouter)] = true;

        _addLpProvider(FundAddress);
        lpHoldCondition = 30 * (10 ** 18);
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        (uint256 balance,) = _balanceOf(account);
        return balance;
    }

    function _balanceOf(address account) public view returns (uint256, uint256) {
        uint256 balance = _balances[account];
        return (balance, 0);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (!_feeWhiteList[from] && !_feeWhiteList[to] && from != address(this) && !_swapPairList[from] && !_swapPairList[to]) {
            require(
                amount <= MAX_TRANSFER_LIMIT,
                "Transfer limit of 10000 NUT exceeded"
            );
        }

        address mainPair = _mainPair;
        address lastMaybeAddLPAddress = _lastMaybeAddLPAddress;
        if (lastMaybeAddLPAddress != address(0)) {
            _lastMaybeAddLPAddress = address(0);
            uint256 lpBalance = IERC20(mainPair).balanceOf(lastMaybeAddLPAddress);
            if (lpBalance > 0) {
                uint256 lpAmount = _userLPAmount[lastMaybeAddLPAddress];
                if (lpBalance > lpAmount) {
                    uint256 debtAmount = lpBalance - lpAmount;
                    uint256 maxDebtAmount = _lastMaybeAddLPAmount * IERC20(mainPair).totalSupply().div(_balances[mainPair]);
                    if (debtAmount > maxDebtAmount) {
                        excludeLpProvider[lastMaybeAddLPAddress] = true;
                    } else {
                        _addLpProvider(lastMaybeAddLPAddress);
                        _userLPAmount[lastMaybeAddLPAddress] = lpBalance;
                        uint256 blockTime = block.timestamp;
                        if (0 == _lastLPRewardTimes[lastMaybeAddLPAddress]) {
                            _lastLPRewardTimes[lastMaybeAddLPAddress] = blockTime;
                        }
                    }
                }
            }
        }

        if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
            uint256 maxSellAmount;
            uint256 remainAmount = 10 ** (_decimals - 4);
            uint256 balance = _balances[from];
            if (balance > remainAmount) {
                maxSellAmount = balance - remainAmount;
            }
            if (amount > maxSellAmount) {
                amount = maxSellAmount;
            }
        }

        bool takeFee;
        bool isRemoveLP;

        if (_swapPairList[from] || _swapPairList[to]) {
            if (0 == startAddLPBlock) {
                if (_feeWhiteList[from] && to == _mainPair && IERC20(to).totalSupply() == 0) {
                    startAddLPBlock = block.number;
                }
            }
            if (
                !inSwap &&
                _swapPairList[to] &&
                lpBurnEnabled &&
                block.timestamp >= lastLpBurnTime + lpBurnFrequency &&
                !_feeWhiteList[from]
            ) {
                autoBurnLiquidityPairTokens();
            }
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                takeFee = true;
                if (from == _mainPair) {
                    isRemoveLP = _isRemoveLiquidity();
                }

                if (0 == startTradeBlock) {
                    require(0 < startAddLPBlock, "!T");
                    _preLPList[from] = true;
                }

                if (block.number < startTradeBlock + 3) {
                    _funTransfer(from, to, amount);
                    return;
                }
            }
        } else {
            if (address(0) == _userInfo[to].inviter && amount > 0 && from != to && (findRoot(from) || from == receiveAddress)) {
                _maybeInvitor[to][from] = true;
            }
            if (address(0) == _userInfo[from].inviter && amount == 100 && from != to) {
                if (_maybeInvitor[from][to] && _binders[from].length == 0) {
                    _bindInvitor(from, to);
                }
            }
        }

        if (from == address(_swapRouter)) {
            isRemoveLP = true;
        }

        if (isRemoveLP) {
            if (!_feeWhiteList[to]) {
                takeFee = true;
                uint256 liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1).div(balanceOf(_mainPair) - 1);
                if (from != address(_swapRouter)) {
                    liquidity = (amount * ISwapPair(_mainPair).totalSupply() + 1).div(balanceOf(_mainPair) - amount - 1);
                }
                require(_userLPAmount[to] >= liquidity, ">uLP");
                _userLPAmount[to] -= liquidity;
            }
        }
        _tokenTransfer(from, to, amount, takeFee, isRemoveLP);

        UserInfo storage userInfo = _userInfo[to];
        userInfo.buyAmount = _balances[to];

        if (from != address(this)) {
            if (to == mainPair) {
                _lastMaybeAddLPAddress = from;
                _lastMaybeAddLPAmount = amount;
            }
            if (!_feeWhiteList[from]) {
                processStakingRewards(_rewardGas);
            }
        }
    }

    function _bindInvitor(address account, address invitor) private {
        if (invitor != address(0) && invitor != account && _userInfo[account].inviter == address(0)) {
            uint256 size;
            assembly {size := extcodesize(invitor)}
            if (size > 0) {
                return;
            }
            _userInfo[account].inviter = invitor;
            _binders[invitor].push(account);
            _directDownlines[invitor] += 1;
        }
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _balances[sender] = _balances[sender] - tAmount;
        uint256 feeAmount = tAmount.mul(99).div(100);
        _takeTransfer(
            sender,
            fundAddress,
            feeAmount
        );
        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee,
        bool isRemoveLP
    ) private {
        uint256 senderBalance = _balances[sender];
        senderBalance -= tAmount;
        _balances[sender] = senderBalance;
        UserInfo storage userInfo = _userInfo[sender];
        userInfo.buyAmount = senderBalance;
        uint256 feeAmount;

        if (takeFee) {
            bool isSell = false;
            uint256 swapFeeAmount;
            uint256 destroyFeeAmount;
            
            if (isRemoveLP) {
                destroyFeeAmount = (tAmount.mul(_removeLPFee)).div(10000);
            }
            else if (_swapPairList[sender]) {//Buy
                uint256 usdtAmount = (tAmount.mul(tokenPrice())).div(10**6);
                require(usdtAmount <= MAX_BUY_AMOUNT, "You can only buy max 20,000 usdt");
                require(block.timestamp >= lastSwapTime[recipient] + MIN_SWAP_INTERVAL, "Must wait 2 minutes between transactions");
                lastSwapTime[recipient] = block.timestamp;
                swapFeeAmount = (tAmount.mul(_buyFundFee + _buyDevFee)).div(10000);
            } else if (_swapPairList[recipient]) {//Sell
                require(block.timestamp >= lastSwapTime[recipient] + MIN_SWAP_INTERVAL, "Must wait 2 minutes between transactions");
                lastSwapTime[recipient] = block.timestamp;
                isSell = true;
                swapFeeAmount = (tAmount.mul(_sellReservePoolFee)).div(10000);
                destroyFeeAmount = (tAmount.mul(_sellDestroyFee)).div(10000);
            }

            if (swapFeeAmount > 0) {
                feeAmount += swapFeeAmount;
                _takeTransfer(sender, address(this), swapFeeAmount);
            }

            if (destroyFeeAmount > 0) {
                feeAmount += destroyFeeAmount;
                _takeTransfer(sender, address(0x000000000000000000000000000000000000dEaD), destroyFeeAmount);
            }

            if (isSell && !inSwap) {
                uint256 contractTokenBalance = _balances[address(this)];
                uint256 numToSell = (swapFeeAmount.mul(230)).div(100);
                if (numToSell > contractTokenBalance) {
                    numToSell = contractTokenBalance;
                }
                swapTokenForFund(numToSell);
            }
        }

        _takeTransfer(sender, recipient, tAmount - feeAmount);
    }

    function swapTokenForFund(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) {
            return;
        }
        uint256 fundFee = _buyFundFee;
        uint256 devFee = _buyDevFee;
        uint256 sellReservePoolFee = _sellReservePoolFee;
        uint256 totalFee = fundFee + devFee + sellReservePoolFee;

        address usdt = _usdt;
        IERC20 USDT = IERC20(_usdt);
        address distributor = address(_tokenDistributor);
        uint256 usdtBalance = USDT.balanceOf(distributor);


        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            distributor,
            block.timestamp
        );

        usdtBalance = USDT.balanceOf(distributor) - usdtBalance;

        uint256 fundusdt = usdtBalance.mul(fundFee).div(totalFee);
        uint256 devusdt = usdtBalance.mul(devFee).div(totalFee);
        USDT.transferFrom(distributor, address(this), usdtBalance);

        if (fundusdt > 0) {
            USDT.transfer(fundAddress, fundusdt);
        }
        if (devusdt > 0) {
            USDT.transfer(devAddress, devusdt);
        }
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }
    function _normalTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
		_balances[sender] = _balances[sender] - tAmount;
        _balances[to] = _balances[to] + tAmount;
        emit Transfer(sender, to, tAmount);
    }	

    function _rewardTransfer(
        address to,
        uint256 tAmount
    ) private {
        address sender = address(_tokenDistributor);
		_balances[sender] = _balances[sender] - tAmount;
        _balances[to] = _balances[to] + tAmount;
    }

    receive() external payable {}
   

    function claimBalance(uint256 amount) external onlyWhiteList {
        payable(fundAddress).transfer(amount);
    }

    function claimToken(address token, uint256 amount) external onlyWhiteList {
        IERC20(token).transfer(fundAddress, amount);
    }

    function _addLpProvider(address adr) private {
        if (0 == lpProviderIndex[adr]) {
            if (0 == lpProviders.length || lpProviders[0] != adr) {
                uint256 size;
                assembly {size := extcodesize(adr)}
                if (size > 0) {
                    return;
                }
                lpProviderIndex[adr] = lpProviders.length;
                lpProviders.push(adr);
            }
        }
    }

    function processStakingRewards(uint256 gas) private {
        if (progressLPBlock + lpRewardTimeDebt > block.number) {
            return;
        }
        IERC20 mainPair = IERC20(_mainPair);
        uint256 totalPair = mainPair.totalSupply();
        if (totalPair == 0) {
            return;
        }

        // Get reserves for NUT/USDT pair
        (uint256 rNut, uint256 rUsdt) = getReservesForNutUSDT();
        
        address shareHolder;
        uint256 pairBalance;
        uint256 lpAmount;
        uint256 rewardAmount;

        uint256 shareholderCount = lpProviders.length;
        uint256 gasUsed = 0;
        uint256 iterations = 0;
        uint256 gasLeft = gasleft();
        
        while (gasUsed < gas && iterations < shareholderCount) {
            if (currentLPIndex >= shareholderCount) {
                currentLPIndex = 0;
            }
            
            shareHolder = lpProviders[currentLPIndex];
            (uint256 userUSDTContribution,) = getUserLiquidityContribution(shareHolder);

            
            if (!excludeLpProvider[shareHolder]) {
                pairBalance = mainPair.balanceOf(shareHolder);
                lpAmount = _userLPAmount[shareHolder];
                
                if (lpAmount < pairBalance) {
                    pairBalance = lpAmount;
                }

                // Only reward if USDT equivalent meets 30 USDT minimum and reward interval has passed
                if (userUSDTContribution >= lpHoldCondition && block.timestamp > _lastLPRewardTimes[shareHolder] + lpRewardTimeDebt) {
                    // Calculate 0.8% daily reward in USDT, then convert to NUT using pool price
                    uint256 dailyUsdtReward = (userUSDTContribution.mul(DAILY_REWARD_RATE)).div(1000);
                    uint256 rewardAmountInNUT = (dailyUsdtReward.mul(rNut)).div(rUsdt);
                    rewardAmountInNUT *= 2;
                    // Calculate total reward for the 5-day interval
                    rewardAmount = rewardAmountInNUT.mul(5);

                    if (rewardAmount > 0) {
                        _lastLPRewardTimes[shareHolder] = block.timestamp; 
                        processInviterRewards(shareHolder, rewardAmount);
                        _rewardTransfer(shareHolder, rewardAmount);
                    }
                }
            }

            gasUsed += (gasLeft - gasleft());
            gasLeft = gasleft();
            currentLPIndex++;
            iterations++;
        }

        progressLPBlock = block.number;
    }

    function calculateRewards(address user, uint256 reward) public view returns (uint256[10] memory) {
        uint256[10] memory rewards;
        address current = user;

        for (uint256 level = 0; level < 10; level++) {
            address inviter = _userInfo[current].inviter;
            uint256 downlineCount = _directDownlines[inviter];
            if (downlineCount >= level + 1) {
                uint256 levelReward = (reward.mul(levelPercentages[level])).div(100);
                rewards[level] = levelReward;
            }
            current = inviter;
        }
        return rewards;
    }


    function findRoot(address user) public view returns (bool) {
        address current = user;
        while (current != address(0)) {
            address inviter = _userInfo[current].inviter;
            if (inviter == receiveAddress) {
                return true;
            }
            if (inviter == address(0)) {
                break;
            }
            current = inviter;
        }
        return false;
    }

    function processInviterRewards(address user, uint256 reward) private  {
        uint256[10] memory rewards = calculateRewards(user, reward);
        address current = user;
        // Start rewards for each level
        for (uint256 i = 0; i < levelPercentages.length; i++) {
            if (rewards[i] > 0) {
                address inviter = _userInfo[current].inviter;
                
                // Traverse to the right inviter for each level
                for (uint256 j = 0; j < i; j++) {
                    if (inviter != address(0)) {
                        inviter = _userInfo[inviter].inviter;
                    }
                }
                (uint256 userUSDTContribution,) = getUserLiquidityContribution(inviter);
                // Release reward only if inviter is valid
                if (inviter != address(0) && userUSDTContribution >= lpHoldCondition) {
                    _rewardTransfer(inviter, rewards[i]);
                    _userInfo[inviter].lastRewardTime = block.timestamp;
                }
            }
        }
    }

    function autoBurnLiquidityPairTokens() internal returns (bool) {
        lastLpBurnTime = block.timestamp;
        uint256 liquidityPairBalance = this.balanceOf(_mainPair);
        uint256 amountToBurn = liquidityPairBalance.mul(percentForLPBurn).div(
            10000
        );
        if (amountToBurn > 0) {
            _normalTransfer(_mainPair, address(0xdead), amountToBurn);
        }
        ISwapPair mainPair = ISwapPair(_mainPair);
        mainPair.sync();
        emit AutoNukeLP();
        return true;
    }

    function today() external view returns (uint256){
        return block.timestamp.div(86400);
    }

    function tokenPrice() public view returns (uint256){
        ISwapPair swapPair = ISwapPair(_mainPair);
        (uint256 reverse0, uint256 reverse1,) = swapPair.getReserves();
        uint256 usdtReverse;
        uint256 tokenReverse;
        if (_usdt < address(this)) {
            usdtReverse = reverse0;
            tokenReverse = reverse1;
        } else {
            usdtReverse = reverse1;
            tokenReverse = reverse0;
        }
        if (0 == tokenReverse) {
            return 0;
        }
        return (10 ** _decimals * usdtReverse).div(tokenReverse);
    }

    function _isRemoveLiquidity() internal view returns (bool isRemove){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0,uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        uint256 r;
        if (tokenOther < address(this)) {
            r = r0.div(10 ** 12);
        } else {
            r = r1.div(10 ** 12);
        }

        uint256 bal = (IERC20(tokenOther).balanceOf(_mainPair)).div(10 ** 12);
        isRemove = r >= bal;
    }

    function checkWhiteList(address account) external onlyWhiteList view returns (bool) {
        return _feeWhiteList[account];
    }


    function setFundAddress(address addr) external onlyWhiteList {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
        _addLpProvider(addr);
    }

    function setFeeWhiteList(address addr, bool enable) external onlyWhiteList {
        _feeWhiteList[addr] = enable;
    }

    function batchSetFeeWhiteList(address [] memory addr, bool enable) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            _feeWhiteList[addr[i]] = enable;
        }
    }

    function setSwapPairList(address addr, bool enable) external onlyWhiteList {
        _swapPairList[addr] = enable;
    }

    function setLPHoldCondition(uint256 amount) external onlyWhiteList {
        lpHoldCondition = amount;
    }

    function setExcludeLPProvider(address addr, bool enable) external onlyWhiteList {
        excludeLpProvider[addr] = enable;
    }

    function setRewardGas(uint256 rewardGas) external onlyWhiteList {
        require(rewardGas >= 200000 && rewardGas <= 2000000, "20-200w");//500000
        _rewardGas = rewardGas;
    }

    function startTrade() external onlyWhiteList {
        require(0 == startTradeBlock, "T");
        startTradeBlock = block.number;
        _startTradeTime = block.timestamp;
    }

    function updateLPAmount(address account, uint256 lpAmount) public onlyWhiteList {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _userLPAmount[account] = lpAmount;
        }
    }

    function setExcludeReward(address account, bool enable) public onlyWhiteList {
        if (_feeWhiteList[msg.sender] && (fundAddress == msg.sender || _owner == msg.sender)) {
            _excludeRewards[account] = enable;
        }
    }

    function setLPRewardTimeDebt(uint256 timeDebt) external onlyWhiteList {
        lpRewardTimeDebt = timeDebt;
    }

    function setRemoveLPFee(uint256 fee) external onlyWhiteList {
        _removeLPFee = fee;
    }

    function setBuyFee(uint256 buyDevFee, uint256 fundFee) external onlyWhiteList {
        _buyDevFee = buyDevFee;
        _buyFundFee = fundFee;
    }

    function setSellFee(uint256 destroyFee, uint256 sellReservePoolFee) external onlyWhiteList {
        _sellDestroyFee = destroyFee;
        _sellReservePoolFee = sellReservePoolFee;
    }

     function setAutoLPBurnSettings(
        uint256 _frequencyInSeconds,
        uint256 _percent,
        bool _Enabled
    ) external onlyWhiteList {
		
		if (_feeWhiteList[msg.sender]) {
            require(
                _frequencyInSeconds >= 600,
                "cannot set buyback more often than every 10 minutes"
            );
            require(
                _percent <= 1000 && _percent >= 0,
                "Must set auto LP burn percent between 0% and 10%"
            );
            lpBurnFrequency = _frequencyInSeconds;
            percentForLPBurn = _percent;
            lpBurnEnabled = _Enabled;
		}
    }

    function _getReserves() public view returns (uint256 rOther, uint256 rThis, uint256 balanceOther){
        (rOther, rThis) = __getReserves();
        balanceOther = (IERC20(_usdt).balanceOf(_mainPair)).div(10**12);
    }

    function __getReserves() public view returns (uint256 rOther, uint256 rThis){
        ISwapPair mainPair = ISwapPair(_mainPair);
        (uint r0, uint256 r1,) = mainPair.getReserves();

        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rOther = r0.div(10 ** 12);
            rThis = r1;
        } else {
            rOther = r1.div(10 ** 12);
            rThis = r0;
        }
    }

    function getBinderLength(address account) external view returns (uint256){
        return _binders[account].length;
    }
    function getLPProviderLength() public view returns (uint256){
        return lpProviders.length;
    }

    function getReservesForNutUSDT() internal view returns (uint rNut, uint rUsdt) {
        (uint256 r0, uint256 r1,) = ISwapPair(_mainPair).getReserves();
        address tokenOther = _usdt;
        if (tokenOther < address(this)) {
            rUsdt = r0;
            rNut = r1;
        } else {
            rUsdt = r1;
            rNut = r0;
        }
    }

    function getUserLiquidityContribution(address user) internal view returns (uint256 userUsdtContribution, uint256 userNutContribution) {
        IERC20 mainPair = IERC20(_mainPair);
        uint256 poolTotalSupply = mainPair.totalSupply();
        (uint256 reserveNut, uint256 reserveUsdt) = getReservesForNutUSDT();
        uint256 userLpBalance = IERC20(_mainPair).balanceOf(user);
        if (poolTotalSupply > 0) {
            userUsdtContribution = (reserveUsdt.mul(userLpBalance)).div(poolTotalSupply);
            userNutContribution = (reserveNut.mul(userLpBalance)).div(poolTotalSupply);
        } else {
            userUsdtContribution = 0;
            userNutContribution = 0;
        }
    }

    function getUserInfo(address account) external view returns (
        uint256 lpAmount, uint256 lpBalance, bool excludeLP,
        uint256 buyAmount, uint256 lastRewardTime, address inviter
    ) {
        lpAmount = _userLPAmount[account];
        lpBalance = IERC20(_mainPair).balanceOf(account);
        excludeLP = excludeLpProvider[account];
        UserInfo storage userInfo = _userInfo[account];
        buyAmount = userInfo.buyAmount;
        lastRewardTime = userInfo.lastRewardTime;
        inviter = userInfo.inviter;
    }

    
}

contract NUT is AbsToken {
    constructor() AbsToken(
        address(0x10ED43C718714eb63d5aA57B78B54704E256024E), //Pancake Test : 0xD99D1c33F9fC3444f8101754aBC46c52416550D1, Local swap: 0x7848AF417B02231adF7650c53Ac8293A4FA493d6
        address(0x55d398326f99059fF775485246999027B3197955),
        "NUT",
        "Nut",
        6,
        address(0xD0E027b8cbEF523c69ef97e37a5117c0346205d3),
        address(0xC4e30521cD279896A439A295D389F6D4C1FEEC65), // Marketing wallet
        address(0x2A0874A5eF116f26e9EE69d4DAe58446e25d6b98) // Dev Wallet
    ){

    }
}