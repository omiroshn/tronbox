pragma solidity 0.4.25;

import "./MintableToken.sol";


contract SCG is MintableToken {
    string public constant NAME = "SCG";
    string public constant SYMBOL = "SCG token";
    uint8 public constant DECIMALS = 18;
}
