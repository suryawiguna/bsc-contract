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

contract EXTSellContract {
    AggregatorV3Interface internal priceFeed;
    
    address public owner;
    uint256 public totalSupply;
    uint256 _decimal = 18;
    uint256 taxPercentage = 10;
    
    mapping(uint => People) public people;
    
    struct People {
        address _address;
        string name;
        uint256 coinBalance;
        uint256 usdBalance;
    }
    
    constructor() {
        totalSupply = 10000000;
        
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        
        people[1]._address = 0xfC2f41Dd41eE7166F13FE1D6E84D06e1797A14C7;
        people[1].name = "Seller";
        people[1].coinBalance = 3500;
        people[1].usdBalance = 4500;
        
        people[0]._address = owner;
        people[0].name = "Owner";
        people[0].coinBalance = totalSupply - people[1].coinBalance;
        people[0].usdBalance = 25000;
        
    }
    
    function getLatestPrice() public view returns (uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        return uint256(price / 10**8); // need to multiply with 10**10 to make same upscaling with the token
    }
    
    function getTotalPrice(uint256 _coinAmount) private view returns (uint256, uint256) {
        uint256 latestPrice = getLatestPrice();
        uint256 totalPrice = latestPrice * _coinAmount;
        return (latestPrice, totalPrice);
    }
    
    function calcTaxSeller(uint256 _coinAmount) private {
        // 5% for seller
        (,uint256 totalPrice) = getTotalPrice(_coinAmount); // get total selling price
        uint256 tax = (totalPrice * 5) / 100; // 10% - 5% tax applied to seller
        uint256 sellProfit = totalPrice - tax; // profit earned from selling
        
        // set new balance for seller
        uint256 coinBalance = ( people[1].coinBalance * 10**_decimal ) - _coinAmount;
        uint256 usdbalance = ( people[1].usdBalance * 10**_decimal ) + sellProfit;
        
        // downscalling to show real amount
        people[1].coinBalance = coinBalance / 10**_decimal;
        people[1].usdBalance = usdbalance / 10**_decimal;
    }

    function calcTaxOwner(uint256 _coinAmount) private {
        // 3% for owner
        (,uint256 totalPrice) = getTotalPrice(_coinAmount); // get total selling price
        uint256 profit = (totalPrice * 3) / 100; // 3% profit form selling
        
        /**
         * adding coin amount to owner (simulate if only the owner & seller that have the coin), 
         * so if seller sell the coin it transfered to owner
        */ 
        uint256 coinBalance = ( people[0].coinBalance * 10**_decimal ) + _coinAmount;
        uint256 usdBalance = ( people[0].usdBalance * 10**_decimal ) + profit; // adding profit to usd balance owner
        
        // downscalling to show real amount
        people[0].coinBalance = coinBalance / 10**_decimal;
        people[0].usdBalance = usdBalance / 10**_decimal;
    }

    function burnSupply(uint256 _coinAmount) private {
        // 2% to burn
        uint256 coinToBurn = ( _coinAmount * 2 ) / 100; // calculate coin to burn
        
        // burn total supply
        uint256 coinBalance = ( people[0].coinBalance * 10**_decimal ) - coinToBurn;
        uint256 currentTotalSupply = ( totalSupply * 10**_decimal ) - coinToBurn;
        
        // downscalling to show real amount
        people[0].coinBalance = coinBalance / 10**_decimal;
        totalSupply = currentTotalSupply / 10**_decimal;
    }

    function sell(uint256 coinAmount) public payable {
        uint256 _coinAmount = coinAmount * 10**_decimal; // upscalling for calculation
        
        calcTaxSeller(_coinAmount);
        calcTaxOwner(_coinAmount);
        burnSupply(_coinAmount);
    }
}
