import { ethers, network } from "hardhat";
import { requireEnv, toBigIntEnv } from "../_helpers";

async function main() {
  const senderAddress = requireEnv("CCIP_SENDER_ADDRESS");
  const message = process.env.CCIP_MESSAGE ?? "Hello from Vadodara!";
  const sender = await ethers.getContractAt("CcipSender", senderAddress);
  const fee = await sender.estimateFee(message);

  console.log(`Network: ${network.name}`);
  console.log(`Estimated fee: ${fee.toString()} wei`);

  const tx = await sender.sendMessage(message, { value: fee });
  const receipt = await tx.wait();

  console.log(`Message sent. Tx hash: ${receipt?.hash}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
