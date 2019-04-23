pragma solidity 0.4.25;

import "./SCG.sol";
import "./DiceTRX.sol";


interface PortalInterface {
    function payReward(address to, uint256 amount, bool isTRXreward) external returns(bool success);
    function depositOf(address owner) external view returns (uint256);
    function updateTokenAddress(address tokenContract) external returns (bool success);

    event MintReward(address indexed to, uint256 amount);
    event MintRewardFinished();
}


contract Portal is PortalInterface, Roles {
    using SafeMath for uint;

    SCG public token;

    mapping(address => uint256) public deposits;

    uint256 public constant MAX_REWARD_SUPPLY = 512000000*(10**18);
    uint256 public rewardSupply;
    
    bool public mintingRewardFinished;

    constructor(address tokenContract) public {
        token = SCG(tokenContract);
    }

    modifier mintingRewardActive {
        require(!mintingRewardFinished);
        _;
    }

    function payReward(address to, uint256 amount, bool isTRXreward) external isActive onlyGameContract mintingRewardActive returns (bool) {
        (uint256 reward, uint periodReward) = calculateRewardParams(to, amount, isTRXreward);
        uint256 maxReward = periodReward.sub(rewardSupply);

        if (reward > maxReward) {
            reward = maxReward;
        }

        deposits[to] = deposits[to].add(amount);
        mintReward(to, amount);
        return true;
    }

    function calculateRewardParams(address to, uint256 amount, bool isTRXreward) private view returns (uint256 reward, uint periodReward) {
        uint step;
        uint stepReward;

        if (isTRXreward) {
            step = 50 * (10**18);
        } else {
            step =  1 * (10**18);
        }

        if (rewardSupply < 8000000 * (10**18)) {
            stepReward   =        10 * (10**18);
            periodReward =   8000000 * (10**18);
        } else if (rewardSupply < 32000000 * (10**18)) {
            stepReward   =         5 * (10**18);
            periodReward =  32000000 * (10**18);
        } else if (rewardSupply < 128000000 * (10**18)) {
            stepReward   =        25 * (10**17);
            periodReward = 128000000 * (10**18);
        } else {
            stepReward   =       125 * (10**16);
            periodReward =    MAX_REWARD_SUPPLY;
        }

        reward = (amount.add(depositOf(to).mod(step))).div(step).mul(stepReward);
    }

    function depositOf(address owner) public view returns (uint256) {
        return deposits[owner];
    }

    function updateTokenAddress(address tokenContract) external isActive onlyOwner returns (bool) {
        token = SCG(tokenContract);
        return true;
    }

    function mintReward(address to, uint256 amount) private {
        emit MintReward(to, amount);
        token.mint(to, amount);
        rewardSupply.add(amount);

        if (rewardSupply >= MAX_REWARD_SUPPLY) {
            finishMinting();
        }
    }

    function finishMinting() private {
        emit MintRewardFinished();
        mintingRewardFinished = true;
    }
}
