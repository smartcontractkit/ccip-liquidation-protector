import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Spinner } from "../utils/spinner";
import { LPSC, LPSC__factory, MonitorMockLending, MonitorMockLending__factory } from "../typechain-types";

task(`reply`, `Triggers the reply function of LPSC smart contract`)
    .addParam(`lpsc`, `The address of the LPSC smart contract`)
    .addParam(`requestedTokenAddress`, `The token address monitor bot requested on the monitor's chain, not Sepolia`)
    .addParam(`amount`, `Requested token amount`)
    .addParam(`sourceChainSelector`, `Monitor bot's chain selector, not Sepolia's selector`)
    .addParam(`monitorAddress`, `The address of the Monitor bot smart contract`)
    .addParam(`messageId`, `The Id of the CCIP Message that failed to execute on Sepolia`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { lpsc, requestedTokenAddress, amount, sourceChainSelector, monitorAddress, messageId } = taskArguments;

        const spinner: Spinner = new Spinner();
        const [signer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to trigger reply function of LPSC smart contract on the ${hre.network.name} blockchain`);
        spinner.start();

        const lpscContract: LPSC = LPSC__factory.connect(lpsc, signer);

        try {
            const tx = await lpscContract.reply(requestedTokenAddress, amount, sourceChainSelector, monitorAddress, messageId, { gasPrice: 2000000000 });

            await tx.wait();

            spinner.stop();
            console.log(`✅ Reply triggered, transaction hash: ${tx.hash}`);
        } catch (error) {
            spinner.stop();
            console.error(error);
        }
    })