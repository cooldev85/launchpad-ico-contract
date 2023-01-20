// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.6;

abstract contract Context {
	function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }   
	function _msgData() internal view virtual returns (bytes memory) {
		this; 
		return msg.data;
	}
}

abstract contract Ownable is Context {
	address private _owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
	constructor () {
		address msgSender = _msgSender();
		_owner = msgSender; 
		emit OwnershipTransferred(address(0), msgSender);
	}

	function owner() public view virtual returns (address) {
		return _owner;
	}
	modifier onlyOwner() {
		require(owner() == _msgSender(), "Ownable: caller is not the owner");
		_;
	}

	function renounceOwnership() public virtual onlyOwner {
		emit OwnershipTransferred(_owner, address(0));
		_owner = address(0);
	}

	function transferOwnership(address newOwner) public virtual onlyOwner {
		require(newOwner != address(0), "Ownable: new owner is the zero address");
		emit OwnershipTransferred(_owner, newOwner);
		_owner = newOwner;
	}
}

library SafeMath {
	function tryAdd (uint a,  uint b) internal pure returns (bool,  uint) {
		uint c = a + b;
		if (c < a) return (false, 0);
		return (true, c);
	}

	function trySub (uint a,  uint b) internal pure returns (bool,  uint) {
		if (b > a) return (false, 0);
		return (true, a - b);
	}

	function tryMul (uint a,  uint b) internal pure returns (bool,  uint) {
		if (a == 0) return (true, 0);
		uint c = a * b;
		if (c / a != b) return (false, 0);
		return (true, c);
	}

	function tryDiv (uint a,  uint b) internal pure returns (bool,  uint) {
		if (b == 0) return (false, 0);
		return (true, a / b);
	}

	function tryMod (uint a,  uint b) internal pure returns (bool,  uint) {
		if (b == 0) return (false, 0);
		return (true, a % b);
	}

	function add (uint a, uint b) internal pure returns (uint) {
		uint c = a + b;
		require(c >= a, "SafeMath: addition overflow");
		return c;
	}

	function sub (uint a, uint b) internal pure returns (uint) {
		require(b <= a, "SafeMath: subtraction overflow");
		return a - b;
	}

	function mul (uint a, uint b) internal pure returns (uint) {
		if (a == 0) return 0;
		uint c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");
		return c;
	}
	function div (uint a, uint b) internal pure returns (uint) {
		require(b > 0, "SafeMath: division by zero");
		return a / b;
	}

	function mod (uint a, uint b) internal pure returns (uint) {
		require(b > 0, "SafeMath: modulo by zero");
		return a % b;
	}

	function sub (uint a, uint b, string memory errorMessage) internal pure returns(uint) {
		require(b <= a, errorMessage);
		return a - b;
	}

	function div (uint a, uint b, string memory errorMessage) internal pure returns(uint) {
		require(b > 0, errorMessage);
		return a / b;
	}

	function mod (uint a, uint b, string memory errorMessage) internal pure returns(uint) {
		require(b > 0, errorMessage);
		return a % b;
	}
}

interface IERC20 {
	function name() external view returns(string memory);
	function symbol() external view returns(string memory);
	function decimals() external view returns(uint8);
	function totalSupply() external view returns(uint);

	function balanceOf(address account) external view returns(uint);
	function transfer(address recipient,    uint amount) external returns(bool);
	function allowance(address owner, address spender) external view returns(uint);
	function approve(address spender,   uint amount) external returns (bool);
	function transferFrom(address sender, address recipient,    uint amount) external returns (bool);
	
	event Transfer(address indexed from, address indexed to,    uint value);
	event Approval(address indexed owner, address indexed spender,  uint value);
}

contract ERC20 is Context, IERC20 {
	using SafeMath for uint;
	mapping (address => uint) private _balances;
	mapping (address => mapping (address => uint)) private _allowances;
	uint private _totalSupply;
	string private _name;
	string private _symbol;
	uint8 private _decimals;
	constructor (string memory name_, string memory symbol_)  {
		_name = name_;
		_symbol = symbol_;
		_decimals = 18;
	}
	function name() public view virtual override returns (string memory) {
		return _name;
	}

	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	function decimals() public view virtual override returns (uint8) {
		return _decimals;
	}

	function totalSupply() public view virtual override returns(uint) {
		return _totalSupply;
	}
	function balanceOf(address account) public view virtual override returns(uint) {
		return _balances[account];
	}

	function transfer(address recipient,    uint amount) public virtual override returns (bool) {
		_transfer(_msgSender(), recipient, amount);
		return true;
	}

	function allowance(address owner, address spender) public view virtual override returns(uint) {
		return _allowances[owner][spender];
	}

	function approve(address spender,   uint amount) public virtual override returns (bool) {
		_approve(_msgSender(), spender, amount);
		return true;
	}

	function transferFrom(address sender, address recipient,uint amount) public virtual override returns (bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
		return true;
	}

	function increaseAllowance(address spender, uint addedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
		return true;
	}

	function decreaseAllowance(address spender, uint subtractedValue) public virtual returns (bool) {
		_approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
		return true;
	}

	function _transfer(address sender, address recipient,   uint amount) internal virtual {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");

		_beforeTokenTransfer(sender, recipient, amount);

		_balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}

	function _mint(address account, uint amount) internal virtual {
		require(account != address(0), "ERC20: mint to the zero address");
		_beforeTokenTransfer(address(0), account, amount);
		_totalSupply = _totalSupply.add(amount);
		_balances[account] = _balances[account].add(amount);
		emit Transfer(address(0), account, amount);
	}

	function _burn(address account, uint amount) internal virtual {
		require(account != address(0), "ERC20: burn from the zero address");
		_beforeTokenTransfer(account, address(0), amount);
		_balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
		_totalSupply = _totalSupply.sub(amount);
		emit Transfer(account, address(0), amount);
	}

	function _approve(address owner, address spender,   uint amount) internal virtual {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");

		_allowances[owner][spender] = amount;
		emit Approval(owner, spender, amount);
	}

	function _setupDecimals(uint8 decimals_) internal virtual {
		_decimals = decimals_;
	}

	function _beforeTokenTransfer(address from, address to, uint amount) internal virtual { }
}

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
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}

abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
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
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}

contract TokenLock is OwnableUpgradeable, IERC20 {
  ERC20 public token;
  uint256 public depositDeadline;
  uint256 public lockDuration;

  string public name;
  string public symbol;
  uint256 public override totalSupply;
  mapping(address => uint256) public override balanceOf;

  /// Withdraw amount exceeds sender's balance of the locked token
  error ExceedsBalance();
  /// Deposit is not possible anymore because the deposit period is over
  error DepositPeriodOver();
  /// Withdraw is not possible because the lock period is not over yet
  error LockPeriodOngoing();
  /// Could not transfer the designated ERC20 token
  error TransferFailed();
  /// ERC-20 function is not supported
  error NotSupported();

  function initialize(
    address _owner,
    address _token,
    uint256 _depositDeadline,
    uint256 _lockDuration,
    string memory _name,
    string memory _symbol
  ) public initializer {
    __Ownable_init();
    transferOwnership(_owner);
    token = ERC20(_token);
    depositDeadline = _depositDeadline;
    lockDuration = _lockDuration;
    name = _name;
    symbol = _symbol;
    totalSupply = 0;
  }

  /// @dev Deposit tokens to be locked until the end of the locking period
  /// @param amount The amount of tokens to deposit
  function deposit(uint256 amount) public {
    if (block.timestamp > depositDeadline) {
      revert DepositPeriodOver();
    }

    balanceOf[msg.sender] += amount;
    totalSupply += amount;

    if (!token.transferFrom(msg.sender, address(this), amount)) {
      revert TransferFailed();
    }

    emit Transfer(msg.sender, address(this), amount);
  }

  /// @dev Withdraw tokens after the end of the locking period or during the deposit period
  /// @param amount The amount of tokens to withdraw
  function withdraw(uint256 amount) public {
    if (
      block.timestamp > depositDeadline &&
      block.timestamp < depositDeadline + lockDuration
    ) {
      revert LockPeriodOngoing();
    }
    if (balanceOf[msg.sender] < amount) {
      revert ExceedsBalance();
    }

    balanceOf[msg.sender] -= amount;
    totalSupply -= amount;

    if (!token.transfer(msg.sender, amount)) {
      revert TransferFailed();
    }

    emit Transfer(address(this), msg.sender, amount);
  }

  /// @dev Returns the number of decimals of the locked token
  function decimals() public view returns (uint8) {
    return token.decimals();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 transfer is not supported
  function transfer(address, uint256) external pure override returns (bool) {
    revert NotSupported();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 allowance is not supported
  function allowance(address, address)
    external
    pure
    override
    returns (uint256)
  {
    revert NotSupported();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 approve is not supported
  function approve(address, uint256) external pure override returns (bool) {
    revert NotSupported();
  }

  /// @dev Lock claim tokens are non-transferrable: ERC-20 transferFrom is not supported
  function transferFrom(
    address,
    address,
    uint256
  ) external pure override returns (bool) {
    revert NotSupported();
  }
}