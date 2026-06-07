// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import "./Client.sol";

/// @notice Simple receiver base contract that only allows the configured router to call ccipReceive.
abstract contract CCIPReceiver {
    error OnlyRouter(address caller);

    address internal immutable i_router;

    constructor(address router) {
        i_router = router;
    }

    modifier onlyRouter() {
        if (msg.sender != i_router) {
            revert OnlyRouter(msg.sender);
        }
        _;
    }

    function ccipReceive(Client.Any2EVMMessage calldata message) external virtual onlyRouter {
        _ccipReceive(message);
    }

    function _ccipReceive(Client.Any2EVMMessage calldata message) internal virtual;
}
