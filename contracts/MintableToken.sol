pragma solidity 0.4.25;

import "./TRC20.sol";


/**
 * @title Mintable TRC20 token interface
 */
interface MintableTokenInterface {
    function mint(address to, uint256 amount) external returns (bool);
    function finishMinting() external returns (bool);

    event Mint(address indexed to, uint256 amount);
    event MintFinished(); 
}


/**
 * @title Mintable TRC20 token
 * @dev Implementation of mintable TRC20 token
 */
contract MintableToken is MintableTokenInterface, TRC20, Roles {
    bool public mintingFinished;

    constructor() public {
        mintingFinished = false;
    }

    modifier mintingActive {
        require(!mintingFinished);
        _;
    }

    function mint(address to, uint256 amount) external onlySaleAgent mintingActive returns (bool) {
        totalSupply = totalSupply.add(amount);
        balances[to] = balances[to].add(amount);
        emit Mint(to, amount);
        return true;
    }

    /**
    * @dev Function to stop minting new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() external onlySaleAgent mintingActive returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}
