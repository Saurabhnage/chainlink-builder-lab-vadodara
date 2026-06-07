// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {CCIPReceiver} from "../shared/ccip/CCIPReceiver.sol";
import {Client} from "../shared/ccip/Client.sol";

/// @title CcipReceiver
/// @notice Receives a text message from a CCIP sender contract on another chain.
contract CcipReceiver is CCIPReceiver, Ownable {
    address public trustedSender;
    uint64 public trustedSourceChainSelector;

    bytes32 public lastMessageId;
    address public lastSender;
    string public lastMessage;
    uint256 public messagesReceived;

    event TrustedRemoteSet(uint64 indexed sourceChainSelector, address indexed trustedSender);
    event MessageReceived(bytes32 indexed messageId, uint64 indexed sourceChainSelector, address indexed sender, string message);

    constructor(address routerAddress) CCIPReceiver(routerAddress) Ownable(msg.sender) {}

    function setTrustedRemote(uint64 sourceChainSelector, address sender) external onlyOwner {
        trustedSourceChainSelector = sourceChainSelector;
        trustedSender = sender;
        emit TrustedRemoteSet(sourceChainSelector, sender);
    }

    function _ccipReceive(Client.Any2EVMMessage calldata message) internal override {
        if (trustedSender != address(0)) {
            require(message.sourceChainSelector == trustedSourceChainSelector, "wrong source chain");
            address decodedSender = abi.decode(message.sender, (address));
            require(decodedSender == trustedSender, "wrong sender");
            lastSender = decodedSender;
        } else {
            lastSender = abi.decode(message.sender, (address));
        }

        lastMessageId = message.messageId;
        lastMessage = abi.decode(message.data, (string));
        messagesReceived += 1;

        emit MessageReceived(message.messageId, message.sourceChainSelector, lastSender, lastMessage);
    }
}
