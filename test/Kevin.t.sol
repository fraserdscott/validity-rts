pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Rollup, N_EVENTS} from "contracts/Rollup.sol";

contract RollupTest is Test {
    Rollup rollup;

    function setUp() external {
        rollup = new Rollup();
    }

    function getBasicProofRequest() public pure returns (string[] memory) {
        string[] memory inputs = new string[](5);
        inputs[0] = "npx";
        inputs[1] = "ts-node";
        inputs[2] = "test/utils/ffiProof.ts";
        return inputs;
    }

    function testHash() external {
        // 1st hashing
        string[] memory inputs1 = new string[](4);
        inputs1[0] = "npx";
        inputs1[1] = "ts-node";
        inputs1[2] = "test/utils/hashEvent.ts";
        inputs1[3] = "0x0";

        bytes32 eventHash1 = bytes32(vm.ffi(inputs1));
        assertEq(
            eventHash1,
            0x2c729831018de76e33a44b4bfe882bfe8fbd8fd32afef5b9840de12a68267c8e
        );

        // 2nd hashing
        inputs1[3] = vm.toString(eventHash1);
        bytes32 eventHash2 = bytes32(vm.ffi(inputs1));

        assertEq(
            eventHash2,
            0x04f25586928254a8eb920473dd6147b510bac8653c5a92c041a610b281767ba3
        );

        // 3rd hashing
        inputs1[3] = vm.toString(eventHash2);
        bytes32 eventHash3 = bytes32(vm.ffi(inputs1));

        assertEq(
            eventHash3,
            0x13c09cc66880af8ecd8135bde8ba6fb22865bfcab3b6d30952293aa3533f4dea
        );
    }

    function testMove() external {
        bytes32 expectedEventHash;
        assertEq(rollup.eventHash(), expectedEventHash);

        for (uint256 i; i < N_EVENTS; i++) {
            rollup.move(0, 0, 0);

            assertTrue(rollup.eventHash() != expectedEventHash);
            expectedEventHash = rollup.eventHash();
        }

        vm.expectRevert("Rollup is full");
        rollup.move(0, 0, 0);
    }

    function testSettle() external {
        // Fill the rollup events
        for (uint256 i; i < N_EVENTS; i++) {
            rollup.move(0, 0, 0);
        }

        string[] memory inputs = getBasicProofRequest();
        inputs[3] = "build1";
        inputs[4] = "0";
        bytes memory proof = vm.ffi(inputs);
        rollup.settle(proof);
        assertEq(rollup.winner(), 0);
    }
}
