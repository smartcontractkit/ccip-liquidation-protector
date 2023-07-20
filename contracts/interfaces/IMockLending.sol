// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
interface IMockLending {
    function healthFactor(address account) external view returns (uint256);

    function deposit(
        address token,
        uint256 amount,
        address inBehalfOf
    ) external;

    function getBorrowedAmount(address inBehalfOf) external returns (uint256);
}
