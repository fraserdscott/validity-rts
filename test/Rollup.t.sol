pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Rollup, N_EVENTS} from "contracts/Rollup.sol";

contract RollupTest is Test {
    Rollup rollup;

    function setUp() external {
        rollup = new Rollup();
    }

    function testMove() external {
        uint256 lobbyId = 0;

        rollup.createLobby(
            block.timestamp,
            60,
            [
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000
            ]
        );

        bytes32 expectedEventHash;
        (, , , , bytes32 eventHash, uint256 eventCount) = rollup.lobbies(0);
        assertEq(eventHash, expectedEventHash);
        assertEq(eventCount, 0);

        for (uint256 i = 1; i <= N_EVENTS; i++) {
            rollup.move(lobbyId, 0, 0, 0);

            (, , , , bytes32 eventHash, uint256 eventCount) = rollup.lobbies(
                lobbyId
            );
            assertTrue(eventHash != expectedEventHash);
            assertEq(eventCount, i);

            expectedEventHash = eventHash;
        }

        vm.expectRevert("Max number of events reached");
        rollup.move(lobbyId, 0, 0, 0);
    }

    function testSettle() external {
        uint256 lobbyId = 0;

        rollup.createLobby(
            block.timestamp,
            60,
            [
                0x0000000000000000000000000000000000000000,
                0x0000000000000000000000000000000000000000
            ]
        );

        for (uint256 i = 1; i <= N_EVENTS; i++) {
            rollup.move(lobbyId, 0, 0, 0);
        }

        string[] memory inputs = getBasicProofRequest();
        inputs[3] = "build1";
        bytes memory proof = vm.ffi(inputs);

        vm.warp(100);
        rollup.settle(lobbyId, proof);
    }

    function getBasicProofRequest() public pure returns (string[] memory) {
        string[] memory inputs = new string[](4);
        inputs[0] = "npx";
        inputs[1] = "ts-node";
        inputs[2] = "test/utils/ffiProof.ts";
        return inputs;
    }
}
