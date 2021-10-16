// SPDX-License-Identifier: MIT
// solidity only use integer, so for this example 1 coin is 1 * 10**2 = 100 to prevent decimal result that cannot displayed inside solidity
pragma solidity ^0.8.0;

contract BSC {
    uint256 public totalCoinSupply;
    uint256 taxToSeller;
    uint256 taxToDev;
    uint256 taxToBurn;

    struct People {
        string name;
        uint256 coinBalance;
    }
    mapping(string => People) public people;

    function setTotalSupply(uint256 _amount) public {
        totalCoinSupply = _amount;
    }

    function setPeopleData(string memory _name, uint256 _coinBalance) public {
        people[_name].name = _name;
        people[_name].coinBalance = _coinBalance;
    }

    function calcTaxToSeller(uint256 _coinAmount) private {
        people["seller"].coinBalance -= _coinAmount;
    }

    function calcTaxToDev(uint256 _coinAmount) private {
        taxToDev = (_coinAmount * 3) / 100;

        people["dev"].coinBalance += taxToDev;
    }

    function calcTaxBurn(uint256 _coinAmount) private {
        taxToBurn = (_coinAmount * 2) / 100;

        totalCoinSupply -= taxToBurn;
    }

    function sell(uint256 _coinAmount) public payable {
        require(
            _coinAmount <= people["seller"].coinBalance,
            "Not enough coin."
        );

        calcTaxToSeller(_coinAmount);
        calcTaxToDev(_coinAmount);
        calcTaxBurn(_coinAmount);
    }
}
