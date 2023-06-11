// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // get eth price in term of usd
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (, int price, , , ) = priceFeed.latestRoundData();

        // check price zeros
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethPriceUsd = (ethPrice * ethAmount) / 1e18;
        return ethPriceUsd;
    }
}
