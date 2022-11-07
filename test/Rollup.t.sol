pragma solidity ^0.8.15;

import "forge-std/Test.sol";

import {Rollup, PRIZE} from "contracts/Rollup.sol";

contract RollupTest is Test {
    Rollup rollup;

    function setUp() external {
        rollup = new Rollup();
    }

    function testMove() external {
        rollup.move(0, 0, 0, 0);
    }
}
