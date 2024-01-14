// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {TestConfig as test} from "./TestConfig.s.sol";

contract HelperConfig {
    function getConstructorConfig() internal pure returns (test.Config memory) {
        uint256 supply = 1e5 ether;
        address tokenA = address(0x100);
        address tokenB = address(0x200);
        address ownerA = address(0x300);
        address ownerB = address(0x400);
        test.Config memory config = test.Config(
            tokenA,
            tokenB,
            supply,
            supply,
            ownerA,
            ownerB
        );

        return config;
    }
}
