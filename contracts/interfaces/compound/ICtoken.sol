// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.0;

interface ICToken {
    function repayBorrowBehalf(
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);

    function repayBorrowBehalf(address borrower) external payable;

    function borrowBalanceStored(address account) external view returns (uint);
}
