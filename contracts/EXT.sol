// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

// deployed token address: 0x8dCcE72C607a31c22cc6bC2f76cB5B285B442DA1
contract EXT is ERC20Burnable {
    constructor () ERC20("Example Token", "EXT") {
        _mint(msg.sender, 10000000 * (10 ** uint256(decimals())));
    }
}
