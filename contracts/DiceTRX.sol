pragma solidity 0.4.25;

import "./Portal.sol";


interface DiceTRXInterface {
    function initGame(bytes32 hashServerSeed) external returns (uint gameId);
    function startGame(
        bytes32 clienSeed,
        uint8 number,
        bool rollUnder,
        uint id) external payable returns (bool success);
    function finishGame(bytes32 serverSeed, uint id) external returns (bool success);
    function changeRTP(uint24 rtp, uint16 rtpDivider) external returns (bool success);
    function changeMinMaxBet(uint256 minBet, uint256 maxBet) external returns (bool success);
    function updatePortalAddress(address portalContract) external returns (bool success);
    function getBalance() external view returns (uint256 balance);

    event InitGame(uint id);
    event StartGame(address player, uint betAmount, uint8 bet, bool rollUnder, uint id);
    event FinishGame(uint8 result, uint id);
    event PlayerWin(address player, uint amount);
    event ChangeRTP(uint24 rtp, uint16 rtpDivider);
    event ChangeMinMaxBet(uint256 minBet, uint256 maxBet);
    event DepoositContract(uint256 amount);
}


contract DiceTRX is DiceTRXInterface, Roles {
    using SafeMath for uint;

    enum GameStatus { init, start, finish }

    struct GameStruct {
        bytes32 hashServerSeed;
        bytes32 serverSeed;
        bytes32 clienSeed;

        address userWallet;
        uint256 userBet;

        uint8 number;
        bool rollUnder;
        uint8 result;

        GameStatus status;
    }

    GameStruct[] public games;

    Portal public portal;

    uint24 public rtp;
    uint16 public rtpDivider;

    uint256 public minBet;
    uint256 public maxBet;

    constructor(address portalContract, uint24 _rtp, uint16 _rtpDivider, uint256 _minBet, uint256 _maxBet) public {
        mainStatus = true;
        portal = Portal(portalContract);

        rtp = _rtp;
        rtpDivider = _rtpDivider;
        minBet = _minBet;
        maxBet = _maxBet;
    }

    modifier betInRange {
        require(minBet <= msg.value && msg.value <= maxBet, "Wrong bet value.");
        _;
    }

    modifier numberInRange(uint8 number, uint id) {
        if (games[id].rollUnder) {
            require(1 <= number && number <= 95, "Wrong number value.");
        } else {
            require(4 <= number && number <= 98, "Wrong number value.");
        }
        _;
    }

    modifier startedGame(uint id) {
        require(games[id].status == GameStatus.start, "Game not started yet.");
        _;
    }

    modifier rightServerSeed(bytes32 serverSeed, uint id) {
        require(keccak256(abi.encodePacked(serverSeed)) == games[id].hashServerSeed, "Wrong server seed.");
        _;
    }

    function initGame(bytes32 hashServerSeed) external isActive onlyOwner returns (uint gameId) {
        GameStruct memory game;
        game.status = GameStatus.init;
        game.hashServerSeed = hashServerSeed;
        
        emit InitGame(games.length);
        games.push(game);

        gameId = games.length - 1;
    }

    function startGame(
        bytes32 clienSeed,
        uint8 number,
        bool rollUnder,
        uint id) external isActive payable onlyUser betInRange numberInRange(number, id) returns (bool) {
        GameStruct storage game = games[id];

        emit StartGame(msg.sender, msg.value, number, rollUnder, id);
        game.status     = GameStatus.start;
        game.rollUnder  = rollUnder;
        game.userWallet = msg.sender;
        game.userBet    = msg.value;
        game.clienSeed  = clienSeed;
        game.number     = number;

        return true;
    }

    function finishGame(
        bytes32 serverSeed,
        uint id) external isActive onlyOwner startedGame(id) rightServerSeed(serverSeed, id) returns (bool) {

        uint8 result = getResultNumber(games[id].clienSeed, games[id].serverSeed, games[id].rollUnder);
        uint multiplier = uint(rtp).mul(96).div(games[id].number);

        games[id].status = GameStatus.finish;
        games[id].serverSeed = serverSeed;
        games[id].result = result;
        emit FinishGame(games[id].result, id);

        if (( games[id].rollUnder && games[id].number <= result) ||
            (!games[id].rollUnder && games[id].number >= result)) {

            uint reward = games[id].userBet.mul(multiplier).div(rtpDivider);
            emit PlayerWin(games[id].userWallet, reward);
            games[id].userWallet.transfer(reward);
        } else {
            portal.payReward(games[id].userWallet, games[id].userBet, true);
            owner.transfer(games[id].userBet);
        }

        return true;
    }

    function changeRTP(uint24 _rtp, uint16 _rtpDivider) external isActive onlyOwner returns (bool) {
        emit ChangeRTP(_rtp, _rtpDivider);
        rtp = _rtp;
        rtpDivider = _rtpDivider;
        return true;
    }

    function changeMinMaxBet(uint256 _minBet, uint256 _maxBet) external isActive onlyOwner returns (bool) {
        emit ChangeMinMaxBet(_minBet, _maxBet);
        minBet = _minBet;
        maxBet = _maxBet;
        return true;
    }

    function updatePortalAddress(address portalContract) external isActive onlyOwner returns (bool) {
        portal = Portal(portalContract);
        return true;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function() external payable {
        emit DepoositContract(msg.value);
    }

    function getResultNumber(
        bytes32 clienSeed,
        bytes32 serverSeed,
        bool rollUnder) private pure returns (uint8 number) {
        bytes32 hash = keccak256(abi.encodePacked(uint(clienSeed) + uint(serverSeed)));

        uint8 numberFromRNG = uint8((uint(hash[0])
            + uint(hash[1] << 8)
            + uint(hash[2] << 16)
            + uint(hash[3] << 24)) % 96);

        if (rollUnder) {
            number = 1 + numberFromRNG;
        } else {
            number = 4 + numberFromRNG;
        }
    }
}
