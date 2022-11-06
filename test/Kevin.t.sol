pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Rollup} from "contracts/Rollup.sol";

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

    function testLabouji() external {
        string[] memory inputs = getBasicProofRequest();
        inputs[3] = "build1";
        inputs[4] = "0";
        bytes memory proof = vm.ffi(inputs);
        rollup.settle(proof);
        assertEq(rollup.winner(), 0);
    }

    function testMove() external {
        rollup.move(0, 0, 0);
    }
}