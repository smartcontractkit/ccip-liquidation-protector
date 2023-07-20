import { task } from "hardhat/config";
import { HardhatRuntimeEnvironment, TaskArguments } from "hardhat/types";
import { Spinner } from "../utils/spinner";
import { IERC20, IERC20__factory } from "../typechain-types";
import { LINK_ADDRESSES } from "./constants";

task(`fund`, `Fund contract with LINK tokens to cover Chainlink CCIP fees`)
    .addParam(`receiver`, `The address of the smart contract to fund`)
    .addOptionalParam(`link`, `The LINK token address`)
    .addParam(`amount`, `The amount to send`)
    .setAction(async (taskArguments: TaskArguments, hre: HardhatRuntimeEnvironment) => {
        const { receiver, link, amount } = taskArguments;

        const linkAddress = link ? link : LINK_ADDRESSES[hre.network.name]

        const spinner: Spinner = new Spinner();
        const [signer] = await hre.ethers.getSigners();

        console.log(`ℹ️  Attempting to transfer ${amount} (in Juels) of LINK tokens (${linkAddress}) from ${signer.address} to ${receiver} on the ${hre.network.name} blockchain`);
        spinner.start();

        const linkToken: IERC20 = IERC20__factory.connect(linkAddress, signer);

        const tx = await linkToken.transfer(receiver, amount);
        await tx.wait();

        spinner.stop();
        console.log(`✅ LINKs sent, transaction hash: ${tx.hash}`);
    })