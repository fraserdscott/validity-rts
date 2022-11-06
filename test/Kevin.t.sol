pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

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
        inputs[3] = "p";
        inputs[4] = "0";
        bytes memory proof = vm.ffi(inputs);
        console2.logBytes(proof);
        rollup.settle(proof);
        assertEq(rollup.winner(), 0);
    }
}