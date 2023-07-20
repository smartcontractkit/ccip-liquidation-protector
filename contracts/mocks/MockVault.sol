// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
interface IBurnMintERC677Helper {
    function drip(address to) external;
}

contract MockVault {
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        IBurnMintERC677Helper(asset).drip(to);
        return 1e18;
    }
}
