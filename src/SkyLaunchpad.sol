// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "solmate/src/tokens/ERC20.sol";

contract SkyLaunchpad is ERC20 {
    constructor() ERC20("SkyLaunchpad", "SKY", 18) {
        _mint(msg.sender, 1_000_000_000 * 1e18); // 1B
    }
}