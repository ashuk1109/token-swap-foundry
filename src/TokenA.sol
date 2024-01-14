// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenA is ERC20, Ownable {
    using SafeERC20 for ERC20;

    constructor() ERC20("TokenA", "TA") Ownable(msg.sender) {}

    function mint(uint256 value) external {
        _mint(msg.sender, value);
    }

    function directTransfer(address to, uint256 value) external onlyOwner {
        _transfer(msg.sender, to, value);
    }
}
