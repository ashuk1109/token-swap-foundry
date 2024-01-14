// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {TokenSwap, TokenSwapEvents as events} from "../src/TokenSwap.sol";
import {DeployTokenSwap} from "../script/DeployTokenSwap.s.sol";
import {TokenA} from "../src/TokenA.sol";
import {TokenB} from "../src/TokenB.sol";

contract TokenSwapTest is StdCheats, Test {
    DeployTokenSwap public deployer;
    TokenSwap public tokenSwap;
    TokenA tokenA;
    TokenB tokenB;
    address owner;
    address ownerA;
    address ownerB;
    address user1;
    address user2;

    function setUp() external {
        deployer = new DeployTokenSwap();
        tokenSwap = deployer.run();
        user1 = vm.addr(1);
        user2 = vm.addr(2);

        ownerA = tokenSwap.s_ownerA();
        ownerB = tokenSwap.s_ownerB();
        owner = tokenSwap.i_owner();

        vm.startPrank(ownerA);
        tokenA = new TokenA();
        tokenA.mint(1e5 ether);
        vm.stopPrank();

        vm.startPrank(ownerB);
        tokenB = new TokenB();
        tokenB.mint(1e5 ether);
        vm.stopPrank();
    }

    function testOwner() external {
        assertEq(owner, msg.sender);
    }

    function testTokenSupply() external {
        assertEq(tokenA.balanceOf(ownerA), 1e5 ether);
        assertEq(tokenB.balanceOf(ownerB), 1e5 ether);
    }

    function testSetExchangeRevertsIfNotOwner() external {
        vm.expectRevert(TokenSwap.TokenSale__OnlyOwner.selector);
        tokenSwap.setExchangeRate(address(tokenA), address(tokenB), 2);
    }

    function testSetExchangeRate() external {
        vm.startPrank(owner);
        tokenSwap.setExchangeRate(address(tokenA), address(tokenB), 2);
        vm.stopPrank();
        assertEq(
            tokenSwap.getExchangeRate(address(tokenA), address(tokenB)),
            2
        );
    }

    function testSetExchangeRateEmitsEvent() external {
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true);
        emit events.TokenExchangeRateSet(address(tokenA), address(tokenB), 2);
        tokenSwap.setExchangeRate(address(tokenA), address(tokenB), 2);
        vm.stopPrank();
    }

    function testSwapRevertsWhenExchangeRateNotset() external {
        vm.startPrank(user1);
        vm.expectRevert(TokenSwap.TokenSwap__ExchangeRateNotSet.selector);
        tokenSwap.swap(
            address(tokenA),
            address(tokenB),
            user1,
            user2,
            20 ether
        );
        vm.stopPrank();
    }

    function testSwapRevertsWhenInsufficientBalance() external {
        setExchangeRate(2);
        vm.startPrank(user1);
        vm.expectRevert(TokenSwap.TokenSwap__InsufficientBalance.selector);
        tokenSwap.swap(
            address(tokenA),
            address(tokenB),
            user1,
            user2,
            20 ether
        );
        vm.stopPrank();
    }

    function testSwapRevertsWhenInsufficientAllowance() external {
        setExchangeRate(2);
        fundUsersForTest();
        vm.startPrank(user1);
        vm.expectRevert(TokenSwap.TokenSwap__InsufficientAllowance.selector);
        tokenSwap.swap(
            address(tokenA),
            address(tokenB),
            user1,
            user2,
            20 ether
        );
        vm.stopPrank();
    }

    function testSwap() external {
        fundUsersForTest();
        assertEq(tokenA.balanceOf(user1), 100 ether);
        assertEq(tokenB.balanceOf(user1), 0);
        assertEq(tokenB.balanceOf(user2), 100 ether);
        assertEq(tokenA.balanceOf(user2), 0);

        // Set exchange Rate
        setExchangeRate(2);

        // Approve TokenSale for exchange
        uint256 exchangeRate = 2;
        uint256 amountToTransfer = 20 ether;
        uint256 toAmount = amountToTransfer * exchangeRate;
        uint256 fromAmount = amountToTransfer / exchangeRate;
        approveTokenSwapContract(toAmount, fromAmount);

        // Variables to track token balances for users
        uint256 user1TokenABalance = tokenA.balanceOf(user1);
        uint256 user2TokenABalance = tokenA.balanceOf(user2);
        uint256 user1TokenBBalance = tokenB.balanceOf(user1);
        uint256 user2TokenBBalance = tokenB.balanceOf(user2);

        // Perform swap and check for emitted event
        vm.expectEmit(true, true, false, true);
        emit events.TokenSwapped(
            user1,
            user2,
            address(tokenA),
            address(tokenB),
            toAmount,
            fromAmount
        );
        tokenSwap.swap(
            address(tokenA),
            address(tokenB),
            user1,
            user2,
            amountToTransfer
        );

        // Asserts
        assertEq(tokenA.balanceOf(user1), user1TokenABalance - toAmount);
        assertEq(tokenA.balanceOf(user2), user2TokenABalance + toAmount);
        assertEq(tokenB.balanceOf(user1), user1TokenBBalance + fromAmount);
        assertEq(tokenB.balanceOf(user2), user2TokenBBalance - fromAmount);
    }

    function fundUsersForTest() private {
        // Transfer TokenA to user1 and TokenB to user2
        uint256 initialBalance = 100 ether;
        vm.startPrank(ownerA);
        tokenA.directTransfer(user1, initialBalance);
        vm.stopPrank();
        vm.startPrank(ownerB);
        tokenB.directTransfer(user2, initialBalance);
        vm.stopPrank();
    }

    function approveTokenSwapContract(
        uint256 toAmount,
        uint256 fromAmount
    ) private {
        // Approve funds for TokenSwap Contract
        vm.startPrank(user1);
        tokenA.approve(address(tokenSwap), toAmount);
        vm.stopPrank();
        vm.startPrank(user2);
        tokenB.approve(address(tokenSwap), fromAmount);
        vm.stopPrank();
    }

    function setExchangeRate(uint256 exchangeRate) private {
        vm.startPrank(owner);
        tokenSwap.setExchangeRate(
            address(tokenA),
            address(tokenB),
            exchangeRate
        );
        vm.stopPrank();
    }

    /** Test results for swap carried out between user1 and user2 */

    ////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////
    //
    // -------------------BALANCE IN ETH---------------------
    // TokenA Balance ---------------------------------------
    // User 1 :  100
    // User 2 :  0
    // TokenB Balance --------------------------------------
    // User 1 :  0
    // User 2 :  100
    // -------------------EXCHANGE RATE : 2-----------------
    // ---------------------AFTER SWAP----------------------
    // TokenA Balance --------------------------------------
    // User 1 :  60
    // User 2 :  40
    // TokenB Balance -------------------------------------
    // User 1 :  10
    // User 2 :  90
    //
    /////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////

    /**
    console.log("-------------------BALANCE IN ETH--------------------");
    console.log("TokenA Balance --------------------------------------");
    console.log("User 1 : ", tokenA.balanceOf(user1) / 1e18);
    console.log("User 2 : ", tokenA.balanceOf(user2) / 1e18);
    console.log("TokenB Balance --------------------------------------");
    console.log("User 1 : ", tokenB.balanceOf(user1) / 1e18);
    console.log("User 2 : ", tokenB.balanceOf(user2) / 1e18);
    console.log("-------------------EXCHANGE RATE : 2-----------------");
    console.log("---------------------AFTER SWAP----------------------");
    console.log("TokenA Balance --------------------------------------");
    console.log("User 1 : ", tokenA.balanceOf(user1) / 1e18);
    console.log("User 2 : ", tokenA.balanceOf(user2) / 1e18);
    console.log("TokenB Balance --------------------------------------");
    console.log("User 1 : ", tokenB.balanceOf(user1) / 1e18);
    console.log("User 2 : ", tokenB.balanceOf(user2) / 1e18); 
     */
}
