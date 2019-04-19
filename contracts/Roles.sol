pragma solidity 0.4.25;


/**
 * @title Roles interface
 */
interface RolesInterface {
    function transferOwnership(address _newOwner) external;
    function acceptOwnership() external;
    function setDiceTRXContract(address newDiceTRXContract) external;
    function setSaleAgent(address newSaleAgnet) external;
    function setMainStatus(bool status) external;

    event OwnershipTransferred(address indexed _from, address indexed _to);
    event ChangeDiceTRXContract(address indexed newDiceTRXContract);
    event ChangeSaleAgent(address indexed newSaleAgnet);
    event ChangeMainStatus(bool mainStatus);
}


/**
 * @title Roles
 * @dev The Roles contract has an owner and saleAgent address, and provides
 * basic authorization control functions, this simplifies the implementation
 * of "user permissions".
 */
contract Roles is RolesInterface {
    address public owner;
    address public newOwner;
    address public saleAgent;

    address public diceTRXContract;

    bool public mainStatus;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyGameContract {
        require(msg.sender == diceTRXContract);
        _;
    }

    modifier onlySaleAgent {
        require(msg.sender == saleAgent);
        _;
    }

    modifier onlyUser {
        require(msg.sender != saleAgent && msg.sender != owner);

        address sender = msg.sender;
        uint size;
        assembly { size := extcodesize(sender) }

        require(size == 0);
        _;
    }

    modifier isActive {
        require(mainStatus);
        _;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() external {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function setDiceTRXContract(address newDiceTRXContract) external onlyOwner {
        emit ChangeDiceTRXContract(newDiceTRXContract);
        diceTRXContract = newDiceTRXContract;
    }

    function setSaleAgent(address newSaleAgnet) external onlyOwner {
        emit ChangeSaleAgent(newSaleAgnet);
        saleAgent = newSaleAgnet;
    }

    function setMainStatus(bool status) external onlyOwner {
        emit ChangeMainStatus(status);
        mainStatus = status;
    }
}
