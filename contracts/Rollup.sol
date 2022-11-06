pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "./Verifier.sol";

contract Rollup is TurboVerifier, Test {
    uint256 public winner;
    bytes32 private eventHash;

    // TODO: Remove FFI
    /* 
    Player actions are logged with: 
    - sender's address
    - block timestamp
    - a unit to move
    - the new goal position for that unit
    Note that the address and timestamp are enforced by the contract.
    */
    function move(uint256 unit, uint256 newGoalX, uint256 newGoalY) public {
        string[] memory inputs = new string[](3);
        inputs[0] = "npx";
        inputs[1] = "ts-node";
        inputs[2] = "test/utils/hashEvent.ts";

        eventHash = bytes32(vm.ffi(inputs));
    }

    function settle(bytes memory proof) public {
        require(this.verify(proof), "Invalid proof");
        // require(eventHash == abi.decode(proof, (bytes32[2]))[0], "Incorrect event hash");

        winner = abi.decode(proof, (uint256[2]))[1];
    }
}