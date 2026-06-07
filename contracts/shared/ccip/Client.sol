// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

/// @notice Minimal CCIP client library used for workshop-friendly sender and receiver contracts.
/// @dev The structure names and encodings mirror the official Chainlink CCIP API.
library Client {
    struct EVMTokenAmount {
        address token;
        uint256 amount;
    }

    struct Any2EVMMessage {
        bytes32 messageId;
        uint64 sourceChainSelector;
        bytes sender;
        bytes data;
        EVMTokenAmount[] destTokenAmounts;
    }

    struct EVM2AnyMessage {
        bytes receiver;
        bytes data;
        EVMTokenAmount[] tokenAmounts;
        address feeToken;
        bytes extraArgs;
    }

    struct EVMExtraArgsV1 {
        uint256 gasLimit;
    }

    /// @dev Official CCIP encodes the V1 extra args with a selector tag.
    bytes4 internal constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;

    function _argsToBytes(EVMExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
        return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
    }
}
