// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IRainfallOracle {
    function rainfallMm() external view returns (uint256);
    function lastUpdatedAt() external view returns (uint256);
}

/// @title WeatherInsurance
/// @notice A simplified parametric insurance example.
/// @dev If rainfall falls below the threshold, the farmer receives a fixed payout.
contract WeatherInsurance is Ownable, ReentrancyGuard {
    IRainfallOracle public immutable oracle;
    address public immutable farmer;
    uint256 public immutable rainfallThresholdMm;
    uint256 public immutable payoutWei;

    bool public policyPurchased;
    bool public payoutExecuted;
    uint256 public premiumWei;
    uint256 public lastObservedRainfallMm;

    event PolicyPurchased(address indexed farmer, uint256 premiumWei);
    event WeatherEvaluated(uint256 rainfallMm, uint256 thresholdMm, bool payoutTriggered);
    event PayoutExecuted(address indexed farmer, uint256 payoutWei);

    constructor(
        address oracleAddress,
        address farmerAddress,
        uint256 thresholdMm,
        uint256 payoutAmountWei
    ) payable Ownable(msg.sender) {
        require(oracleAddress != address(0), "oracle required");
        require(farmerAddress != address(0), "farmer required");
        require(payoutAmountWei > 0, "payout required");
        require(msg.value >= payoutAmountWei, "fund contract with payout reserve");

        oracle = IRainfallOracle(oracleAddress);
        farmer = farmerAddress;
        rainfallThresholdMm = thresholdMm;
        payoutWei = payoutAmountWei;
    }

    function purchasePolicy() external payable {
        require(msg.sender == farmer, "only farmer");
        require(!policyPurchased, "already purchased");
        require(msg.value > 0, "premium required");

        policyPurchased = true;
        premiumWei = msg.value;

        emit PolicyPurchased(msg.sender, msg.value);
    }

    function evaluateAndPayout() external nonReentrant {
        require(policyPurchased, "policy not purchased");
        require(!payoutExecuted, "already settled");

        uint256 rainfall = oracle.rainfallMm();
        lastObservedRainfallMm = rainfall;

        bool shouldPay = rainfall < rainfallThresholdMm;
        emit WeatherEvaluated(rainfall, rainfallThresholdMm, shouldPay);

        if (shouldPay) {
            payoutExecuted = true;
            (bool sent, ) = payable(farmer).call{value: payoutWei}("");
            require(sent, "payout transfer failed");
            emit PayoutExecuted(farmer, payoutWei);
        }
    }

    function currentCoverageStatus() external view returns (bool insured, bool eligibleForPayout, uint256 rainfallMm_) {
        insured = policyPurchased;
        rainfallMm_ = oracle.rainfallMm();
        eligibleForPayout = insured && !payoutExecuted && rainfallMm_ < rainfallThresholdMm;
    }

    receive() external payable {}
}
