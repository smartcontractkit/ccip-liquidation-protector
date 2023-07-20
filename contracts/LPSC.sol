// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {LPSCRegistry} from "./LPSCRegistry.sol";
import {LPSCVault} from "./LPSCVault.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract LPSC is LPSCVault, LPSCRegistry, CCIPReceiver {
    address immutable router;

    event ReplySent(
        bytes32 replyMessageId,
        uint64 sourceChainSelector,
        bytes32 messageId,
        address sender,
        address tokenToReturn,
        uint256 amount
    );

    modifier onlyRouterOrOwner() {
        require(
            msg.sender == router || msg.sender == owner(),
            "Only LPSC or Owner can call"
        );
        _;
    }

    constructor(
        address _router,
        address _vault
    ) CCIPReceiver(_router) LPSCVault(_vault) {
        router = _router;
        LinkTokenInterface(LINK).approve(_router, type(uint256).max);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory receivedMessage
    ) internal override {
        bytes32 messageId = receivedMessage.messageId;
        uint64 sourceChainSelector = receivedMessage.sourceChainSelector;
        (address tokenAddress, uint256 amount, address sender) = abi.decode(
            receivedMessage.data,
            (address, uint256, address)
        );

        reply(tokenAddress, amount, sourceChainSelector, sender, messageId);
    }

    function reply(
        address tokenAddress,
        uint256 amount,
        uint64 sourceChainSelector,
        address sender,
        bytes32 messageId
    ) public onlyRouterOrOwner {
        address tokenToReturn = s_destinationToSourceMap[
            keccak256(abi.encodePacked(tokenAddress, sourceChainSelector))
        ];

        uint256 currentBalance = IERC20(tokenToReturn).balanceOf(address(this));

        // If there are not enough funds in LPSC, withdraw additional from Aave vault
        if (currentBalance < amount) {
            withdrawFromVault(tokenToReturn, amount - currentBalance);
        }

        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: tokenToReturn,
            amount: amount
        });
        tokenAmounts[0] = tokenAmount;

        IERC20(tokenToReturn).approve(router, amount);

        Client.EVM2AnyMessage memory messageReply = Client.EVM2AnyMessage({
            receiver: abi.encode(sender),
            data: abi.encode(messageId),
            tokenAmounts: tokenAmounts,
            extraArgs: "",
            feeToken: LINK
        });

        bytes32 replyMessageId = IRouterClient(router).ccipSend(
            sourceChainSelector,
            messageReply
        );

        emit ReplySent(
            replyMessageId,
            sourceChainSelector,
            messageId,
            sender,
            tokenToReturn,
            amount
        );
    }
}
