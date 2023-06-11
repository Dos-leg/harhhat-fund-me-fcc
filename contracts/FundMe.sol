// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./PriceConverter.sol";
import "hardhat/console.sol";

error FundMe__NotOwner();

/// @title A contract for crowd funding
/// @author Jon Snow
/// @notice This contract is to demo a simple funding contract
/// @dev This implements price feeds as our library
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] public s_funders;
    mapping(address => uint256) public s_addressToAmountFunded;

    address public immutable i_owner;
    AggregatorV3Interface public s_priceFeed;

    // function that modified by a modifier will execute modifier first
    modifier onlyOwner() {
        // require(msg.sender == i_owner, NotOwner());
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        // condition check below. it means, if don't meet the condition require
        // the whole tx will be rolled back; however, gas already spend cannot be returned
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        console.log("fund value: ");
        console.log(msg.value);
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            s_addressToAmountFunded[s_funders[funderIndex]] = 0;
        }
        s_funders = new address[](0);
        // 三种不同发送代币的方式，分别为transfer、send、call
        // transfer , will rollback when failed
        // payable(msg.sender).transfer(address(this).balance);
        // send , will not rollback when failed, howerver return true or false
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call , call any function with infos, return true or false and returnedData
        (bool callSuccess, ) = msg.sender.call{value: address(this).balance}(
            ""
        );
        require(callSuccess, "Call failed");
        // call is recommended way to send token
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(
        address funder
    ) public view returns (uint256) {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
