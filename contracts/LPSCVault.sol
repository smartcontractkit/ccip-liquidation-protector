// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {IPoolAaveV3} from "./interfaces/aave-v3/IPoolAaveV3.sol";
import {Withdraw} from "./utils/Withdraw.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract LPSCVault is Withdraw {
    address immutable i_vault;

    constructor(address vault) {
        i_vault = vault;
    }

    // E.g. User has 100 aUSDC, calls withdraw() and receives 100 USDC, burning the 100 aUSDC
    function withdrawFromVault(address asset, uint256 amount) internal {
        IPoolAaveV3(i_vault).withdraw(asset, amount, address(this));
    }
}
