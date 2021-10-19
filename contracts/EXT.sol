// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract EXT is ERC20Burnable {
    constructor() ERC20("Example Token", "EXT") {
        _mint(msg.sender, 10000000 * (10**uint256(decimals())));
    }
}
