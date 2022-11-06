pragma solidity ^0.8.15;

import "./Verifier.sol";

contract Rollup is TurboVerifier {
    uint256 public winner;

    function settle(bytes memory proof) public {
        uint256[1] memory inputs = abi.decode(proof, (uint256[1]));
        require(this.verify(proof));
        winner = inputs[0];
    }

}