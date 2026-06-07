// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IRouterClient} from "../shared/ccip/IRouterClient.sol";
import {Client} from "../shared/ccip/Client.sol";

/// @title CcipSender
/// @notice Sends a string payload through CCIP from a source chain to a receiver contract.
/// @dev Uses native gas for fees to keep the workshop setup lighter.
contract CcipSender is Ownable {
    IRouterClient public immutable router;
    uint64 public destinationChainSelector;
    address public receiver;
    uint256 public gasLimit;

    event DestinationUpdated(uint64 destinationChainSelector, address receiver, uint256 gasLimit);
    event MessageSent(bytes32 indexed messageId, uint64 indexed destinationChainSelector, address indexed receiver, string message, uint256 feeWei);

    constructor(address routerAddress, uint64 _destinationChainSelector, address receiverAddress, uint256 _gasLimit)
        Ownable(msg.sender)
    {
        require(routerAddress != address(0), "router required");
        require(receiverAddress != address(0), "receiver required");

        router = IRouterClient(routerAddress);
        destinationChainSelector = _destinationChainSelector;
        receiver = receiverAddress;
        gasLimit = _gasLimit;
    }

    function setDestination(uint64 _destinationChainSelector, address receiverAddress, uint256 _gasLimit) external onlyOwner {
        require(receiverAddress != address(0), "receiver required");
        destinationChainSelector = _destinationChainSelector;
        receiver = receiverAddress;
        gasLimit = _gasLimit;
        emit DestinationUpdated(_destinationChainSelector, receiverAddress, _gasLimit);
    }

    function sendMessage(string calldata text) external payable returns (bytes32 messageId) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(text),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            feeToken: address(0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: gasLimit}))
        });

        uint256 fee = router.getFee(destinationChainSelector, message);
        require(msg.value >= fee, "not enough native token for CCIP fee");

        messageId = router.ccipSend{value: fee}(destinationChainSelector, message);

        if (msg.value > fee) {
            (bool refunded, ) = payable(msg.sender).call{value: msg.value - fee}("");
            require(refunded, "refund failed");
        }

        emit MessageSent(messageId, destinationChainSelector, receiver, text, fee);
    }

    function estimateFee(string calldata text) external view returns (uint256 fee) {
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(text),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            feeToken: address(0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: gasLimit}))
        });

        fee = router.getFee(destinationChainSelector, message);
    }

    receive() external payable {}
}
