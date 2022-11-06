pragma solidity ^0.8.15;

import "./Verifier.sol";

contract Rollup is TurboVerifier {
    uint256 public winner;

    function settle(bytes memory proof) public {
        require(this.verify(proof), "Invalid proof");

        uint256[2] memory inputs = abi.decode(proof, (uint256[2]));
        winner = inputs[1];
    }
}