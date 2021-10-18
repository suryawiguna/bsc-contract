// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract BSC {
    AggregatorV3Interface internal priceFeed;
    using SafeMath for uint256;
    
    /**
     * Network: Binance Smart Chain
     * Aggregator: BNB/USD
     * Address: 0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE
     */
    constructor() payable {
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE);
    }
    
    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (,int price,,,) = priceFeed.latestRoundData();
        return price;
    }
    
    uint256 public totalCoinSupply;
    uint256 taxToSeller;
    uint256 taxToDev;
    uint256 taxToBurn;
    uint256 _decimal = 6;

    struct People {
        string name;
        uint256 coinBalance;
    }
    mapping(string => People) public people;

    function setTotalSupply(uint256 _amount) public {
        totalCoinSupply = _amount.mul(10**_decimal);
    }

    function setPeopleData(string memory _name, uint256 _coinBalance) public {
        people[_name].name = _name;
        people[_name].coinBalance = _coinBalance.mul(10**_decimal);
    }

    function calcTaxToSeller(uint256 _coinAmount) private {
        // 5% cut from seller
        people["seller"].coinBalance = people["seller"].coinBalance.sub(_coinAmount);
    }

    function calcTaxToDev(uint256 _coinAmount) private {
        // 3% go to dev & marketing
        taxToDev = _coinAmount.mul(10**_decimal).mul(3).div(100, "ERROR: _coinAmount is too small").div(10**_decimal);

        people["dev"].coinBalance = people["dev"].coinBalance.add(taxToDev);
    }

    function calcTaxBurn(uint256 _coinAmount) private {
        // 2% will burn (copped)
        taxToBurn = _coinAmount.mul(10**_decimal).mul(2).div(100, "ERROR: _coinAmount is too small").div(10**_decimal);

        totalCoinSupply = totalCoinSupply.sub(taxToBurn);
    }

    function sell(uint256 _coinAmount) public payable {
        _coinAmount = _coinAmount.mul(10**_decimal);
        
        require(
            _coinAmount <= people["seller"].coinBalance,
            "Not enough coin."
        );

        calcTaxToSeller(_coinAmount);
        calcTaxToDev(_coinAmount);
        calcTaxBurn(_coinAmount);
    }
}
