pragma solidity ^0.8.15;

import "./Verifier.sol";

uint256 constant N_EVENTS = 10000;
uint256 constant N_PLAYERS = 2;
uint256 constant PRIZE = 1 ether;

contract Rollup is TurboVerifier {
    enum UnitType {
        NINJA,
        WIZARD
    }

    struct Lobby {
        uint256 startTimestamp;
        uint256 duration;
        uint256 winner;
        bool withdrawn;
        bytes32 eventHash;
        uint256 eventCount;
        address[N_PLAYERS] players;
    }

    Lobby[] public lobbies;

    event LobbyCreated(
        uint256 indexed lobbyId,
        uint256 startTimestamp,
        uint256 duration
    );
    event LobbySettled(
        uint256 indexed lobbyId,
        uint256 winner
    );
    event Move(
        uint256 indexed lobbyId,
        address indexed account,
        uint256 timestamp,
        uint256 unit,
        uint256 newGoalX,
        uint256 newGoalY
    );

    function createLobby(
        uint256 startTimestamp,
        uint256 duration,
        address[N_PLAYERS] calldata players
    ) public {
        Lobby memory lobby;
        lobby.startTimestamp = startTimestamp;
        lobby.duration = duration;
        lobby.players = players;

        emit LobbyCreated(lobbies.length, startTimestamp, duration);

        lobbies.push(lobby);
    }

    function move(
        uint256 lobbyId,
        uint256 unit,
        uint256 newGoalX,
        uint256 newGoalY
    ) public {
        Lobby storage lobby = lobbies[lobbyId];

        require(lobby.eventCount < N_EVENTS, "Max number of events reached");
        lobby.eventCount++;
        lobby.eventHash = bytes32(uint256(lobby.eventHash) + uint256(uint160(msg.sender)) + block.timestamp + unit + newGoalX + newGoalY);

        emit Move(lobbyId, msg.sender, block.timestamp, unit, newGoalX, newGoalY);
    }

    function settle(uint256 lobbyId, bytes memory proof) public {
        Lobby storage lobby = lobbies[lobbyId];
        
        bytes32 eventHash = abi.decode(proof, (bytes32[1]))[0];
        require(block.timestamp > lobby.startTimestamp + lobby.duration, "Lobby is not ready to settle");
        require(eventHash == lobby.eventHash, "Incorrect eventHash");
        require(this.verify(proof), "Invalid proof");

        uint256 winner = abi.decode(proof, (uint256[2]))[1];
        lobby.winner = winner;

        emit LobbySettled(lobbyId, winner);
    }

    function getPlayers(uint256 index)
        public
        view
        returns (address[N_PLAYERS] memory)
    {
        return lobbies[index].players;
    }
}
