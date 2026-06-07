// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MockOracle
/// @notice A tiny oracle simulator that stores a rainfall value onchain.
/// @dev Used to teach oracle-driven insurance without introducing offchain infrastructure.
contract MockOracle is Ownable {
    uint256 public rainfallMm;
    uint256 public lastUpdatedAt;

    event RainfallUpdated(uint256 rainfallMm, uint256 lastUpdatedAt);

    constructor(uint256 initialRainfallMm) Ownable(msg.sender) {
        rainfallMm = initialRainfallMm;
        lastUpdatedAt = block.timestamp;
    }

    function setRainfallMm(uint256 newRainfallMm) external onlyOwner {
        rainfallMm = newRainfallMm;
        lastUpdatedAt = block.timestamp;
        emit RainfallUpdated(newRainfallMm, lastUpdatedAt);
    }
}
