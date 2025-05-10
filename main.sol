// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockBlaster {
    uint8 public constant GRID_SIZE = 5;
    uint256 public gameId;

    enum GameState { WaitingForPlayer, InProgress, Finished }

    struct Game {
        address player1;
        address player2;
        mapping(address => uint8[3]) shots; // each player gets 3 shots
        mapping(address => uint8[GRID_SIZE][GRID_SIZE]) targets; // target positions
        GameState state;
        address winner;
    }

    mapping(uint256 => Game) public games;
    mapping(address => uint256) public activeGame;

    event GameCreated(uint256 indexed gameId, address indexed player1);
    event PlayerJoined(uint256 indexed gameId, address indexed player2);
    event ShotFired(uint256 indexed gameId, address indexed player, uint8 x, uint8 y);
    event GameFinished(uint256 indexed gameId, address indexed winner);

    modifier onlyPlayers(uint256 _gameId) {
        require(
            msg.sender == games[_gameId].player1 || msg.sender == games[_gameId].player2,
            "Not a player in this game"
        );
        _;
    }

    function createGame(uint8[GRID_SIZE][GRID_SIZE] calldata targetGrid) external {
        require(activeGame[msg.sender] == 0, "Already in a game");

        gameId++;
        Game storage g = games[gameId];
        g.player1 = msg.sender;
        g.targets[msg.sender] = targetGrid;
        g.state = GameState.WaitingForPlayer;

        activeGame[msg.sender] = gameId;
        emit GameCreated(gameId, msg.sender);
    }

    function joinGame(uint256 _gameId, uint8[GRID_SIZE][GRID_SIZE] calldata targetGrid) external {
        Game storage g = games[_gameId];
        require(g.state == GameState.WaitingForPlayer, "Game not joinable");
        require(g.player2 == address(0), "Game full");

        g.player2 = msg.sender;
        g.targets[msg.sender] = targetGrid;
        g.state = GameState.InProgress;

        activeGame[msg.sender] = _gameId;
        emit PlayerJoined(_gameId, msg.sender);
    }

    function fire(uint256 _gameId, uint8 shotIndex, uint8 x, uint8 y) external onlyPlayers(_gameId) {
        Game storage g = games[_gameId];
        require(g.state == GameState.InProgress, "Game not in progress");
        require(shotIndex < 3, "Invalid shot index");

        g.shots[msg.sender][shotIndex] = (x * GRID_SIZE) + y;
        emit ShotFired(_gameId, msg.sender, x, y);

        // If both players have fired all 3 shots, finish game
        if (_allShotsMade(g)) {
            _finishGame(_gameId);
        }
    }

    function _allShotsMade(Game storage g) internal view returns (bool) {
        return
            g.shots[g.player1][2] != 0 || g.shots[g.player2][2] != 0; // shot index 2 must be set for both
    }

    function _finishGame(uint256 _gameId) internal {
        Game storage g = games[_gameId];
        uint256 p1Hits = _countHits(g, g.player1, g.player2);
        uint256 p2Hits = _countHits(g, g.player2, g.player1);

        if (p1Hits > p2Hits) {
            g.winner = g.player1;
        } else if (p2Hits > p1Hits) {
            g.winner = g.player2;
        } else {
            g.winner = address(0); // draw
        }

        g.state = GameState.Finished;
        activeGame[g.player1] = 0;
        activeGame[g.player2] = 0;

        emit GameFinished(_gameId, g.winner);
    }

    function _countHits(Game storage g, address shooter, address targetOwner) internal view returns (uint256 hits) {
        for (uint8 i = 0; i < 3; i++) {
            uint8 shot = g.shots[shooter][i];
            uint8 x = shot / GRID_SIZE;
            uint8 y = shot % GRID_SIZE;
            if (g.targets[targetOwner][x][y] == 1) {
                hits++;
            }
        }
    }

    function getPlayerShots(uint256 _gameId, address player) external view returns (uint8[3] memory) {
        return games[_gameId].shots[player];
    }

    function getTargetGrid(uint256 _gameId, address player) external view returns (uint8[GRID_SIZE][GRID_SIZE] memory) {
        return games[_gameId].targets[player];
    }
}
