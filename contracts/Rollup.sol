pragma solidity ^0.8.15;

import "./Verifier.sol";

uint256 constant N_EVENTS = 10000000;
uint256 constant PRIZE = 1 ether;

contract Rollup is TurboVerifier {
    uint256 public eventCount;
    bytes32 public eventHash;
    address public winner;
    bool public withdrawn;

    event Move(address account, uint256 timestamp, uint256 unit, uint256 newGoalX, uint256 newGoalY);

    // TODO: Remove FFI
    /* 
    Player actions are logged with: 
    - sender's address
    - block timestamp
    - a unit to move
    - the new goal position for that unit
    Note that the address and timestamp are enforced by the contract.
    */
    function move(
        uint256 unit,
        uint256 newGoalX,
        uint256 newGoalY
    ) public {
        require(eventCount < N_EVENTS, "Rollup is full");
        eventCount++;

        // string[] memory inputs = new string[](4);
        // inputs[0] = "npx";
        // inputs[1] = "ts-node";
        // inputs[2] = "test/utils/hashEvent.ts";
        // inputs[3] = vm.toString(eventHash);
        // eventHash = bytes32(vm.ffi(inputs));

        emit Move(msg.sender, block.timestamp, unit, newGoalX, newGoalY);
    }

    function settle(bytes memory proof) public {
        require(this.verify(proof), "Invalid proof");
        require(
            eventHash == abi.decode(proof, (bytes32[1]))[0],
            "Incorrect event hash"
        );

        winner = address(uint160(abi.decode(proof, (uint256[2]))[1]));
    }

    function withdraw() public {
        require(!withdrawn, "Winner has aleady withdrawn reward");
        withdrawn = true;
        
        (bool success,) = winner.call{value: PRIZE}("");
        require(success, "ETH Transfer failed");
    }
}
