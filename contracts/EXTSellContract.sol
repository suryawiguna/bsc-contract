// SPDX-License-Identifier: MIT
/**
 * Network: Binance Smart Chain
 * Aggregator: BNB/USD
 * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
 * references:
 *  - https://docs.chain.link/docs/binance-smart-chain-addresses/#BSC%20Testnet
 *  - https://docs.binance.org/smart-chain/developer/deploy/remix.html
 */

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./EXT.sol";

contract EXTSellContract {
    AggregatorV3Interface internal priceFeed;
    using SafeMath for uint256;

    // Toc to USD price (using BNB / USD)
    address public owner;
    uint256 public totalSupply;
    uint256 taxToSeller;
    uint256 taxToDev;
    uint256 taxToBurn;
    uint256 _decimal = 18;
    uint256 taxPercentage = 10;
    uint256 tax;

    mapping(uint256 => People) public people;

    struct People {
        address _address;
        string name;
        uint256 coinBalance;
        uint256 usdBalance;
    }

    constructor() {
        totalSupply = 10000000 * 10**_decimal;

        owner = msg.sender;
        priceFeed = AggregatorV3Interface(
            0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
        );

        people[0]._address = owner;
        people[0].name = "Owner";
        people[0].coinBalance = 150 * 10**_decimal;
        people[0].usdBalance = 2500 * 10**_decimal;

        people[1]._address = 0xfC2f41Dd41eE7166F13FE1D6E84D06e1797A14C7;
        people[1].name = "Seller";
        people[1].coinBalance = 50 * 10**_decimal;
        people[1].usdBalance = 550 * 10**_decimal;
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 10**10); // need to multiply with 10**10 to make same upscaling with the token
    }

    // function transfer(address _recipient, uint256 _amount) public payable returns (uint256 tokenAmount) {
    //     (bool sent) = extToken.transfer(_recipient, _amount);
    //     require(sent, "Failed to transfer token to user");
    //     return tokenAmount;
    // }

    function getTotalCoinPrice(uint256 _coinAmount)
        private
        view
        returns (uint256)
    {
        uint256 totalPrice = getLatestPrice() * _coinAmount;
        return totalPrice;
    }

    function calcTaxSeller(uint256 _coinAmount) private {
        // 5% for seller
        uint256 sellProfit = getTotalCoinPrice(_coinAmount) -
            (getTotalCoinPrice(_coinAmount).mul(5).div(100));

        people[1].coinBalance = people[1].coinBalance - _coinAmount;
        people[1].usdBalance = people[1].usdBalance + sellProfit;
    }

    function calcTaxOwner(uint256 _coinAmount) private {
        // 3% for owner
        uint256 profit = getTotalCoinPrice(_coinAmount).mul(3).div(100);

        people[0].usdBalance = people[0].usdBalance + profit;
    }

    function burnSupply(uint256 _coinAmount) private {
        // 2% to burn
        uint256 usdToBurn = getTotalCoinPrice(_coinAmount).mul(2).div(100);
        uint256 coinToBurn = usdToBurn.div(getLatestPrice());

        // burn supply
        totalSupply = totalSupply - coinToBurn;
    }

    function sell(uint256 _coinAmount) public {
        calcTaxSeller(_coinAmount);
        calcTaxOwner(_coinAmount);
        burnSupply(_coinAmount);
    }
}
