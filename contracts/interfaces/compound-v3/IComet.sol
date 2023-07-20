// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;

interface IComet {
    function isLiquidatable(address account) external view returns (bool);

    function borrowBalanceOf(address account) external view returns (uint256);

    function supplyTo(address dst, address asset, uint amount) external;

    function approve(address spender, uint256 amount) external returns (bool);
}
