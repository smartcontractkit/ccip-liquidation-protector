// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract LPSCRegistry {
    // Source Chain (Ethereum Sepolia) Config:
    uint64 constant SEPOLIA_CHAIN_SELECTOR = 16015286601757825753;
    address constant LINK = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address constant WETH = 0x097D90c9d3E0B50Ca60e1ae45F6A81010f9FB534;
    address constant CCIP_BnM = 0xFd57b4ddBf88a4e07fF4e34C487b99af2Fe82a05;
    address constant CCIP_LnM = 0x466D489b6d36E7E3b824ef491C225F5830E81cC1;

    mapping(bytes32 tokenAndChainSelector => address token)
        internal s_destinationToSourceMap;

    function fillMap(
        address destinationChainToken,
        uint64 destinationChainSelector,
        address sourceChainToken
    ) private {
        s_destinationToSourceMap[
            keccak256(
                abi.encodePacked(
                    destinationChainToken,
                    destinationChainSelector
                )
            )
        ] = sourceChainToken;
    }

    constructor() {
        // Optimism Goerli
        uint64 optimismGoerliChainId = 2664363617261496610;
        fillMap(
            0xdc2CC710e42857672E7907CF474a69B63B93089f,
            optimismGoerliChainId,
            LINK
        );
        fillMap(
            0xaBfE9D11A2f1D61990D1d253EC98B5Da00304F16,
            optimismGoerliChainId,
            CCIP_BnM
        );
        fillMap(
            0x835833d556299CdEC623e7980e7369145b037591,
            optimismGoerliChainId,
            CCIP_LnM
        );

        // Avalanche Fuji
        uint64 avalancheFujiChainId = 14767482510784806043;
        fillMap(
            0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
            avalancheFujiChainId,
            LINK
        );
        fillMap(
            0xD21341536c5cF5EB1bcb58f6723cE26e8D8E90e4,
            avalancheFujiChainId,
            CCIP_BnM
        );
        fillMap(
            0x70F5c5C40b873EA597776DA2C21929A8282A3b35,
            avalancheFujiChainId,
            CCIP_LnM
        );

        // Arbitrum Goerli
        uint64 aribtrumGoerliChainId = 6101244977088475029;
        fillMap(
            0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28,
            aribtrumGoerliChainId,
            LINK
        );
        fillMap(
            0x0579b4c1C8AcbfF13c6253f1B10d66896Bf399Ef,
            aribtrumGoerliChainId,
            CCIP_BnM
        );
        fillMap(
            0x0E14dBe2c8e1121902208be173A3fb91Bb125CDB,
            aribtrumGoerliChainId,
            CCIP_LnM
        );

        // Polygon Mumbai
        uint64 polygonMumbaiChainId = 12532609583862916517;
        fillMap(
            0x326C977E6efc84E512bB9C30f76E30c160eD06FB,
            polygonMumbaiChainId,
            LINK
        );
        fillMap(
            0xf1E3A5842EeEF51F2967b3F05D45DD4f4205FF40,
            polygonMumbaiChainId,
            CCIP_BnM
        );
        fillMap(
            0xc1c76a8c5bFDE1Be034bbcD930c668726E7C1987,
            polygonMumbaiChainId,
            CCIP_LnM
        );
    }
}
