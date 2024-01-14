// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {TokenA} from "./TokenA.sol";
import {TokenB} from "./TokenB.sol";

interface TokenSwapEvents {
    event TokenSwapped(
        address indexed _user,
        address indexed _toUser,
        address _fromToken,
        address _toToken,
        uint256 _toAmount,
        uint256 _fromAmount
    );
    event TokenExchangeRateSet(
        address indexed _fromToken,
        address indexed _toToken,
        uint256 _rate
    );
}

/**
 * @title TokenSwap
 * @author ashuk1109
 *
 * A smart contract to swap two tokens at the same time with complete transparency.
 *
 */
contract TokenSwap is TokenSwapEvents {
    using SafeERC20 for IERC20;

    /** Errors */
    error TokenSale__OnlyOwner();
    error TokenSwap__ExchangeRateNotSet();
    error TokenSwap__InsufficientBalance();
    error TokenSwap__InsufficientAllowance();

    /** Vairables */
    address public s_tokenA;
    address public s_tokenB;
    address public s_ownerA;
    address public s_ownerB;
    address public immutable i_owner;
    mapping(address => mapping(address => uint256)) public s_exchangeRates;

    /** Modifiers */
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert TokenSale__OnlyOwner();
        }
        _;
    }

    /** Functions */
    constructor(
        address _tokenA,
        address _tokenB,
        address _ownerA,
        address _ownerB
    ) {
        s_tokenA = (_tokenA);
        s_tokenB = (_tokenB);
        s_ownerA = _ownerA;
        s_ownerB = _ownerB;
        i_owner = msg.sender;
    }

    /**
     * @dev Function to swap tokens between the caller (msg.sender) and _toUser.
     *
     * Make sure this TokenSale contract is approved for both tokens otherwise
     * the transaction will be reverted with TokenSwap__InsufficientAllowance()
     *
     * @param _fromToken Address of token to swap from
     * @param _toToken Address of token to swap to
     * @param _fromUser Addres of user to swap tokens from
     * @param _toUser Address of user to swap tokens with
     * @param _amount Amount to swap
     */
    function swap(
        address _fromToken,
        address _toToken,
        address _fromUser,
        address _toUser,
        uint256 _amount
    ) public {
        uint256 exchangeRate = getExchangeRate(_fromToken, _toToken);
        if (exchangeRate == 0) {
            revert TokenSwap__ExchangeRateNotSet();
        }

        uint256 toAmount = _amount * exchangeRate;
        uint256 fromAmount = _amount / exchangeRate;
        IERC20 tokenFrom = IERC20(_fromToken);
        IERC20 tokenTo = IERC20(_toToken);

        if (
            tokenFrom.balanceOf(_fromUser) < toAmount ||
            tokenTo.balanceOf(_toUser) < fromAmount
        ) {
            revert TokenSwap__InsufficientBalance();
        }

        if (
            tokenFrom.allowance(_fromUser, address(this)) < toAmount ||
            tokenTo.allowance(_toUser, address(this)) < fromAmount
        ) {
            revert TokenSwap__InsufficientAllowance();
        }

        // From msg.sender to _toUser
        tokenFrom.safeTransferFrom(_fromUser, address(this), toAmount);
        tokenFrom.safeTransfer(_toUser, toAmount);

        // From _toUser to msg.sender
        tokenTo.safeTransferFrom(_toUser, address(this), fromAmount);
        tokenTo.safeTransfer(_fromUser, fromAmount);

        emit TokenSwapped(
            _fromUser,
            _toUser,
            _fromToken,
            _toToken,
            toAmount,
            fromAmount
        );
    }

    /**
     * Function to set exchange rate between two tokens, only callable by owner.
     *
     * @param _tokenA Address of first token
     * @param _tokenB Address of second token
     * @param _rateAToB Exchange Rate of two tokens
     */
    function setExchangeRate(
        address _tokenA,
        address _tokenB,
        uint256 _rateAToB
    ) public onlyOwner {
        s_exchangeRates[_tokenA][_tokenB] = _rateAToB;
        emit TokenExchangeRateSet(_tokenA, _tokenB, _rateAToB);
    }

    /** Getter functions */
    function getExchangeRate(
        address _fromToken,
        address _toToken
    ) public view returns (uint256) {
        return s_exchangeRates[_fromToken][_toToken];
    }
}
