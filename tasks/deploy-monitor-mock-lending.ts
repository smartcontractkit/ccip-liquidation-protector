import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Spinner } from "../utils/spinner";
import { MonitorMockLending, MonitorMockLending__factory } from "../typechain-types";
import { LINK_ADDRESSES } from "./constants";

task(`deploy-monitor-mock-lending`, `Deploys the MonitorMockLending smart contract`)
    .addParam(`minHealthFactor`, `The minimum health factor before liquidation saving is triggered`)
    .addParam(`router`, `The Chainlink CCIP Router address`)
    .addParam(`lendingAddress`, `The MockLending smart contract address`)
    .addParam(`tokenAddress`, `The address of a token needed to protect from liquidation`)
    .addParam(`onBehalfOf`, `The User's EOA address`)
    .addParam(`lpsc`, `The LPSC smart contract address on the liquidity chain`)
    .addOptionalParam(`link`, `The LINK token address used for paying CCIP fees`)
    .addParam(`liquidationChainSelector`, `The Liquidation Chain Selector`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { minHealthFactor, router, lendingAddress, tokenAddress, onBehalfOf, lpsc, link, liquidationChainSelector } = taskArguments;

        const linkAddress = link ? link : LINK_ADDRESSES[hre.network.name]

        const spinner: Spinner = new Spinner();
        const [deployer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to deploy MonitorMockLending to the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const monitorMockLendingFactory: MonitorMockLending__factory = await hre.ethers.getContractFactory('MonitorMockLending');
        const monitorMockLending: MonitorMockLending = await monitorMockLendingFactory.deploy(minHealthFactor, router, linkAddress, lendingAddress, tokenAddress, onBehalfOf, lpsc, liquidationChainSelector);
        await monitorMockLending.deployed();

        spinner.stop();
        console.log(`✅ MonitorMockLending deployed at address ${monitorMockLending.address} to ${hre.network.name} blockchain`);
    })