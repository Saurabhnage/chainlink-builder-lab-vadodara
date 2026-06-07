// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title PriceFeedConsumer
/// @notice Reads ETH/USD and optional BTC/USD price feeds from Chainlink.
/// @dev This version is intentionally simple so first-time Solidity developers can read it line by line.
contract PriceFeedConsumer is Ownable {
    AggregatorV3Interface public immutable ethUsdFeed;
    AggregatorV3Interface public immutable btcUsdFeed;

    event PriceRead(string symbol, int256 answer, uint256 normalizedPrice, uint8 decimals, uint80 roundId, uint256 updatedAt);

    constructor(address ethUsdFeedAddress, address btcUsdFeedAddress) Ownable(msg.sender) {
        require(ethUsdFeedAddress != address(0), "ETH feed is required");
        ethUsdFeed = AggregatorV3Interface(ethUsdFeedAddress);
        btcUsdFeed = AggregatorV3Interface(btcUsdFeedAddress);
    }

    function latestEthUsd() public view returns (int256 answer, uint8 decimals, uint80 roundId, uint256 updatedAt) {
        (roundId, answer, , updatedAt, ) = ethUsdFeed.latestRoundData();
        require(answer > 0, "ETH feed returned invalid answer");
        decimals = ethUsdFeed.decimals();
    }

    function latestBtcUsd() public view returns (int256 answer, uint8 decimals, uint80 roundId, uint256 updatedAt) {
        require(address(btcUsdFeed) != address(0), "BTC feed not configured");
        (roundId, answer, , updatedAt, ) = btcUsdFeed.latestRoundData();
        require(answer > 0, "BTC feed returned invalid answer");
        decimals = btcUsdFeed.decimals();
    }

    function ethUsdIn18Decimals() external view returns (uint256) {
        (int256 answer, uint8 decimals, , ) = latestEthUsd();
        return _scale(answer, decimals);
    }

    function btcUsdIn18Decimals() external view returns (uint256) {
        (int256 answer, uint8 decimals, , ) = latestBtcUsd();
        return _scale(answer, decimals);
    }

    function compareEthToBtc() external view returns (uint256 ethPrice18, uint256 btcPrice18, uint256 ethPerBtcRatio18) {
        ethPrice18 = this.ethUsdIn18Decimals();
        btcPrice18 = this.btcUsdIn18Decimals();
        ethPerBtcRatio18 = btcPrice18 == 0 ? 0 : (ethPrice18 * 1e18) / btcPrice18;
    }

    function _scale(int256 answer, uint8 decimals) internal pure returns (uint256) {
        require(answer > 0, "Negative price");
        uint256 price = uint256(answer);
        if (decimals < 18) {
            return price * (10 ** (18 - decimals));
        }
        if (decimals > 18) {
            return price / (10 ** (decimals - 18));
        }
        return price;
    }
}
