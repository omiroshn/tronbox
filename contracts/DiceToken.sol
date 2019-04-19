pragma solidity 0.4.25;

import "./Portal.sol";


interface DiceTokenInterface {
    function initGame(bytes32 hashServerSeed) external returns (uint gameId);
    function startGame(
        bytes32 clienSeed,
        uint tokenId,
        uint userBet,
        uint8 number,
        bool rollUnder,
        uint id) external returns (bool success);
    function finishGame(bytes32 serverSeed, uint id) external returns (bool success);
    function changeRTP(uint24 rtp, uint16 rtpDivider) external returns (bool success);
    function changeMinMaxBet(uint256 minBet, uint256 maxBet, uint tokenId) external returns (bool success);
    function addToken(address contractAddress, uint256 minBet, uint256 maxBet) external returns (uint tokenId);
    function updatePortalAddress(address portalContract) external returns (bool success);

    event InitGame(uint id);
    event StartGame(address player, uint betAmount, uint8 bet, bool rollUnder, uint id);
    event FinishGame(uint8 result, uint id);
    event PlayerWin(address player, uint amount);
    event ChangeRTP(uint24 rtp, uint16 rtpDivider);
    event ChangeMinMaxBet(uint256 minBet, uint256 maxBet, uint tokenId);
    event AddNewToken(address contractAddress, uint256 minBet, uint256 maxBet, uint id);
}


contract DiceToken is DiceTokenInterface, Roles {
    using SafeMath for uint;

    enum GameStatus { init, start, finish }

    struct GameStruct {
        bytes32 hashServerSeed;
        bytes32 serverSeed;
        bytes32 clienSeed;

        address userWallet;
        uint256 userBet;
        uint256 tokenId;

        uint8 number;
        bool rollUnder;
        uint8 result;

        uint256 reward;
        GameStatus status;
    }

    struct Token {
        address contractAddress;
        uint256 minBet;
        uint256 maxBet;
    }

    GameStruct[] public games;
    Token[] public tokens;

    Portal public portal;

    uint24 public rtp;
    uint16 public rtpDivider;

    constructor(address portalContract, uint24 _rtp, uint16 _rtpDivider) public {
        mainStatus = true;
        portal = Portal(portalContract);

        rtp = _rtp;
        rtpDivider = _rtpDivider;
    }

    modifier betInRange(uint tokenId) {
        require(tokens[tokenId].minBet <= msg.value && msg.value <= tokens[tokenId].maxBet, "Wrong bet value.");
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
        uint tokenId,
        uint userBet,
        uint8 number,
        bool rollUnder,
        uint id) external isActive onlyUser betInRange(tokenId) numberInRange(number, id) returns (bool) {
        GameStruct storage game = games[id];

        emit StartGame(msg.sender, userBet, number, rollUnder, id);
        game.status     = GameStatus.start;
        game.rollUnder  = rollUnder;
        game.userWallet = msg.sender;
        game.userBet    = userBet;
        game.tokenId    = tokenId;
        game.clienSeed  = clienSeed;
        game.number     = number;
        game.reward     = 0;

        return true;
    }

    function finishGame(
        bytes32 serverSeed,
        uint id) external isActive onlyOwner startedGame(id) rightServerSeed(serverSeed, id) returns (bool) {

        uint8 result = getResultNumber(games[id].clienSeed, games[id].serverSeed, games[id].rollUnder);
        uint multiplier = uint(rtp).mul(96).div(games[id].number);

        emit FinishGame(games[id].result, id);
        games[id].status = GameStatus.finish;
        games[id].serverSeed = serverSeed;
        games[id].result = result;

        if (( games[id].rollUnder && games[id].number <= result) ||
            (!games[id].rollUnder && games[id].number >= result)) {

            uint reward = games[id].userBet.mul(multiplier).div(rtpDivider);
            emit PlayerWin(games[id].userWallet, reward);
            games[id].reward = reward;
        } else {
            portal.calculateReward(games[id].userWallet, games[id].userBet);
        }

        return true;
    }

    function changeRTP(uint24 _rtp, uint16 _rtpDivider) external isActive onlyOwner returns (bool) {
        emit ChangeRTP(_rtp, _rtpDivider);
        rtp = _rtp;
        rtpDivider = _rtpDivider;
        return true;
    }

    function changeMinMaxBet(uint256 minBet, uint256 maxBet, uint tokenId) external isActive onlyOwner returns (bool) {
        emit ChangeMinMaxBet(minBet, maxBet, tokenId);
        tokens[tokenId].minBet = minBet;
        tokens[tokenId].maxBet = maxBet;
        return true;
    }

    function addToken(address contractAddress, uint256 minBet, uint256 maxBet) external isActive onlyOwner returns (uint tokenId) {
        tokenId = tokens.length;
        emit AddNewToken(contractAddress, minBet, maxBet, tokenId);
        tokens.push(Token(contractAddress, minBet, maxBet));
    }

    function updatePortalAddress(address portalContract) external isActive onlyOwner returns (bool) {
        portal = Portal(portalContract);
        return true;
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
