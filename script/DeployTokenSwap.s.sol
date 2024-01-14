// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {TokenSwap} from "../src/TokenSwap.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {TestConfig as test} from "./TestConfig.s.sol";

contract DeployTokenSwap is Script, HelperConfig {
    function run() external returns (TokenSwap) {
        test.Config memory config = getConstructorConfig();
        vm.startBroadcast();
        TokenSwap tokenSwap = new TokenSwap(
            config._tokenA,
            config._tokenB,
            config._ownerA,
            config._ownerB
        );
        vm.stopBroadcast();

        return tokenSwap;
    }
}
