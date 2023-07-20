// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {Withdraw} from "../utils/Withdraw.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract MockLending is Withdraw {
    // Zero by default so it will automatically be triggered by Chainlink Automation
    mapping(address account => uint256 amount) internal deposited;

    function healthFactor(address account) external view returns (uint256) {
        return deposited[account] / 1;
    }

    function deposit(
        address token,
        uint256 amount,
        address inBehalfOf
    ) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        deposited[inBehalfOf] += amount;
    }

    function getBorrowedAmount(
        address inBehalfOf
    ) external pure returns (uint256) {
        return 1e18;
    }
}
