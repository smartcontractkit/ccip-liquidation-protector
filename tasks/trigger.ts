import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Spinner } from "../utils/spinner";
import { MonitorMockLending, MonitorMockLending__factory } from "../typechain-types";

task(`trigger`, `Triggers the performUpkeep function of MonitorMockLending smart contract`)
    .addParam(`monitor`, `The address of the MonitorMockLending smart contract`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { monitor } = taskArguments;

        const spinner: Spinner = new Spinner();
        const [signer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to trigger performUpkeep function of MonitorMockLending smart contract on the ${hre.network.name} blockchain`);
        spinner.start();

        const monitorMockLending: MonitorMockLending = MonitorMockLending__factory.connect(monitor, signer);

        try {
            const tx = await monitorMockLending.performUpkeep(`0x`);

            await tx.wait();

            spinner.stop();
            console.log(`✅ Liquidation saving triggered, transaction hash: ${tx.hash}`);
        } catch (error) {
            spinner.stop();
            console.error(error);
        }
    })