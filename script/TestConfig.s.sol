// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface TestConfig {
    struct Config {
        address _tokenA;
        address _tokenB;
        uint256 _tokenASupply;
        uint256 _tokenBsupply;
        address _ownerA;
        address _ownerB;
    }
}
