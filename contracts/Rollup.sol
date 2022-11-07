pragma solidity ^0.8.15;

import "./Verifier.sol";

uint256 constant N_PLAYERS = 2;
uint256 constant PRIZE = 1 ether;

contract Rollup is TurboVerifier {
    struct Lobby {
        address winner;
        bool withdrawn;
        address[N_PLAYERS] players;
    }
    
    Lobby[] public lobbies;

    event Move(
        uint256 lobby,
        address account,
        uint256 timestamp,
        uint256 unit,
        uint256 newGoalX,
        uint256 newGoalY
    );

    function createLobby(
        address[N_PLAYERS] calldata players
    ) public {
        Lobby memory lobby;
        lobby.players = players;
        
        lobbies.push(lobby);
    }

    /* 
    Player actions are logged with: 
    - sender's address
    - block timestamp
    - a unit to move
    - the new goal position for that unit
    Note that the address and timestamp are enforced by the contract.
    */
    function move(
        uint256 lobby,
        uint256 unit,
        uint256 newGoalX,
        uint256 newGoalY
    ) public {
        emit Move(lobby, msg.sender, block.timestamp, unit, newGoalX, newGoalY);
    }

    function settle(uint256 index, bytes memory proof) public {
        Lobby storage lobby = lobbies[index];

        require(this.verify(proof), "Invalid proof");
      
        lobby.winner = address(uint160(abi.decode(proof, (uint256[2]))[1]));
    }

    function withdraw(uint256 index) public {
        Lobby storage lobby = lobbies[index];

        require(!lobby.withdrawn, "Winner has aleady withdrawn reward");
        lobby.withdrawn = true;

        (bool success, ) = lobby.winner.call{value: PRIZE}("");
        require(success, "ETH Transfer failed");
    }
}
