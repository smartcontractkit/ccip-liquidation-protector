import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Spinner } from "../utils/spinner";
import { MockLending, MockLending__factory, MockVault, MockVault__factory } from "../typechain-types";

task(`deploy-mock-vault`, `Deploys the MockVault smart contract`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        if (hre.network.name !== hre.config.defaultNetwork) {
            console.error(`❌ MockVault can be deployed to the liquidty chain only. Liquidity chain - ${hre.config.defaultNetwork}`);
            return 1;
        }

        const spinner: Spinner = new Spinner();
        const [deployer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to deploy MockVault on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const mockVaultFactory: MockVault__factory = await hre.ethers.getContractFactory('MockVault');
        const mockVault: MockVault = await mockVaultFactory.deploy();
        await mockVault.deployed();

        spinner.stop();
        console.log(`✅ MockVault deployed at address ${mockVault.address} on ${hre.network.name} blockchain`);
    })

task(`deploy-mock-lending`, `Deploys the MockLending smart contract`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const spinner: Spinner = new Spinner();
        const [deployer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to deploy MockLending on the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const mockLendingFactory: MockLending__factory = await hre.ethers.getContractFactory('MockLending');
        const mockLending: MockLending = await mockLendingFactory.deploy();
        await mockLending.deployed();

        spinner.stop();
        console.log(`✅ MockLending deployed at address ${mockLending.address} on ${hre.network.name} blockchain`);
    })