// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Client.sol";

/// @notice Minimal interface for the CCIP router.
/// @dev Matches the two functions used by this workshop repository.
interface IRouterClient {
    function getFee(uint64 destinationChainSelector, Client.EVM2AnyMessage calldata message) external view returns (uint256 fee);

    function ccipSend(uint64 destinationChainSelector, Client.EVM2AnyMessage calldata message) external payable returns (bytes32 messageId);
}
