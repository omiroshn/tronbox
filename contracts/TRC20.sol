pragma solidity 0.4.25;

import "./SafeMath.sol";
import "./Roles.sol";


/**
 * @title TRC20 interface
 */
interface TRC20Interface {
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


/**
 * @title Standard TRC20 token
 * @dev Implementation of the basic standard token.
 */ 
contract TRC20 is TRC20Interface {
    using SafeMath for uint256;

    uint256 public totalSupply;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowed;

    function() public payable {
        revert();
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param tokenOwner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address tokenOwner) public view returns (uint256) {
        return balances[tokenOwner];
    }

    /**
     * @dev Function to check the amount of tokens that an tokenOwner allowed to a
     * spender.
     * @param tokenOwner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for
     * the spender.
     */
    function allowance(address tokenOwner, address spender) public view returns (uint256) {
        return allowed[tokenOwner][spender];
    }

    /**
     * @dev transfer token for a specified address
     * @param to The address to transfer to.
     * @param tokens The amount to be transferred.
     */
    function transfer(address to, uint256 tokens) public returns (bool) {
        require(to != address(0));
        require(tokens <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens
     * on behalf of msg.sender. Beware that changing an allowance with this
     * method brings the risk that someone may use both the old and the new
     * allowance by unfortunate transaction ordering. One possible solution to
     * mitigate this race condition is to first reduce the spender's allowance
     * to 0 and set the desired value afterwards:
     * @param spender The address which will spend the funds.
     * @param tokens The amount of tokens to be spent.
    */
    function approve(address spender, uint256 tokens) public returns (bool) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param tokens uint256 the amount of tokens to be transferred
    */
    function transferFrom(address from, address to, uint256 tokens) public returns (bool) {
        require(to != address(0));
        require(tokens <= balances[from]);
        require(tokens <= allowed[from][msg.sender]);

        balances[from] = balances[from].sub(tokens);
        balances[to] = balances[to].add(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
}
