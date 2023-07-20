// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {ILendingPoolAaveV2} from "../interfaces/aave-v2/ILendingPoolAaveV2.sol";
import {Withdraw} from "../utils/Withdraw.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract MonitorAaveV2 is
    AutomationCompatibleInterface,
    CCIPReceiver,
    Withdraw
{
    /**
     * If Health goes below 1, a portion of the user's collateral can be liquidated.
     *
     * Health > 2 : Green
     * Health < 1.99: Orange
     * Health <1.1: Red
     * Health < 1, liquidation will occur
     *
     * @dev Suggestion is to be at least 11000000000000000000
     */
    uint256 immutable i_minHealthFactor;
    address immutable i_onBehalfOf;
    address immutable i_lendingPoolAddress;
    address immutable i_link;
    address immutable i_tokenAddress;
    address immutable i_lpsc;
    uint64 immutable i_sourceChainSelector;
    bool private _isCcipMessageSent;

    mapping(bytes32 messageId => uint256 amountToRepay) internal requested;

    event MessageSent(bytes32 indexed messageId);

    constructor(
        address router,
        address onBehalfOf,
        address lendingPoolAddress,
        address linkTokenAddress,
        uint256 minHealthFactor,
        address tokenAddress,
        address lpsc,
        uint64 sourceChainSelector
    ) CCIPReceiver(router) {
        i_onBehalfOf = onBehalfOf;
        i_lendingPoolAddress = lendingPoolAddress;
        i_link = linkTokenAddress;
        i_minHealthFactor = minHealthFactor;
        i_tokenAddress = tokenAddress;
        i_lpsc = lpsc;
        i_sourceChainSelector = sourceChainSelector;

        LinkTokenInterface(i_link).approve(i_router, type(uint256).max);
    }

    function checkUpkeep(
        bytes calldata /*checkData*/
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (, , , , , uint256 healthFactor) = ILendingPoolAaveV2(
            i_lendingPoolAddress
        ).getUserAccountData(i_onBehalfOf);

        upkeepNeeded = healthFactor <= i_minHealthFactor && !_isCcipMessageSent;
    }

    function performUpkeep(bytes calldata /*performData*/) external override {
        require(
            !_isCcipMessageSent,
            "CCIP Message already sent, waiting for a response"
        );
        (
            ,
            uint256 totalDebtETH,
            ,
            ,
            ,
            uint256 healthFactor
        ) = ILendingPoolAaveV2(i_lendingPoolAddress).getUserAccountData(
                i_onBehalfOf
            );
        require(
            healthFactor <= i_minHealthFactor,
            "Account can't be liquidated!"
        );

        uint256 amountNeeded = totalDebtETH;

        // Ask for funds from LPSC on the source blockchain
        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(i_lpsc),
            data: abi.encode(i_tokenAddress, amountNeeded, address(this)),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: "",
            feeToken: i_link
        });

        bytes32 messageId = IRouterClient(i_router).ccipSend(
            i_sourceChainSelector,
            message
        );

        requested[messageId] = amountNeeded;

        _isCcipMessageSent = true;

        emit MessageSent(messageId);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory receivedMessage
    ) internal override {
        _isCcipMessageSent = false;
        bytes32 requestMessageId = abi.decode(receivedMessage.data, (bytes32));
        uint256 amountToRepay = requested[requestMessageId];

        IERC20(i_tokenAddress).approve(i_lendingPoolAddress, amountToRepay);

        ILendingPoolAaveV2(i_lendingPoolAddress).repay(
            i_tokenAddress,
            amountToRepay,
            1,
            i_onBehalfOf
        );
    }
}
