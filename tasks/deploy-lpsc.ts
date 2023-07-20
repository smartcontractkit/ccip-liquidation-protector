import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Spinner } from "../utils/spinner";
import { LPSC, LPSC__factory } from "../typechain-types";

task(`deploy-lpsc`, `Deploys the LPSC smart contract`)
    .addParam(`router`, `The Chainlink CCIP Router address`)
    .addParam(`vault`, `The Vault smart contract address`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        if (hre.network.name !== hre.config.defaultNetwork) {
            console.error(`❌ LPSC can be deployed to the liquidty chain only. Liquidity chain - ${hre.config.defaultNetwork}`);
            return 1;
        }

        const { router, vault } = taskArguments;

        const spinner: Spinner = new Spinner();
        const [deployer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to deploy LPSC to the ${hre.network.name} blockchain using ${deployer.address} address`);
        spinner.start();

        const lpscFactory: LPSC__factory = await hre.ethers.getContractFactory('LPSC');
        const lpsc: LPSC = await lpscFactory.deploy(router, vault);
        await lpsc.deployed();

        spinner.stop();
        console.log(`✅ LPSC deployed at address ${lpsc.address} to ${hre.network.name} blockchain`);
    })