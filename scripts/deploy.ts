import { ethers, network } from "hardhat";
import { NETWORKS, requireEnv, toBigIntEnv, toNumberEnv } from "./_helpers";

async function main() {
  const track = (process.env.TRACK ?? "track-1").toLowerCase();
  console.log(`Deploying ${track} on ${network.name}...`);

  switch (track) {
    case "track-1":
    case "price-feed":
    case "track1": {
      const feed = requireEnv("SEPOLIA_ETH_USD_FEED", NETWORKS.sepolia.ethUsdFeed);
      const btc = process.env.SEPOLIA_BTC_USD_FEED ?? NETWORKS.sepolia.btcUsdFeed;
      const factory = await ethers.getContractFactory("PriceFeedConsumer");
      const contract = await factory.deploy(feed, btc);
      await contract.waitForDeployment();
      console.log(`PriceFeedConsumer deployed to: ${await contract.getAddress()}`);
      break;
    }

    case "track-2":
    case "weather":
    case "insurance": {
      const oracleFactory = await ethers.getContractFactory("MockOracle");
      const initialRainfall = toBigIntEnv("INITIAL_RAINFALL_MM", "12");
      const oracle = await oracleFactory.deploy(initialRainfall);
      await oracle.waitForDeployment();

      const insuranceFactory = await ethers.getContractFactory("WeatherInsurance");
      const payoutWei = toBigIntEnv("WEATHER_PAYOUT_WEI", "100000000000000000");
      const threshold = toBigIntEnv("RAINFALL_THRESHOLD_MM", "20");
      const signer = await ethers.provider.getSigner();
      const farmer = requireEnv("FARMER_ADDRESS", await signer.getAddress());
      const premiumWei = toBigIntEnv("WEATHER_PREMIUM_WEI", "10000000000000000");

      const insurance = await insuranceFactory.deploy(
        await oracle.getAddress(),
        farmer,
        threshold,
        payoutWei,
        { value: payoutWei }
      );
      await insurance.waitForDeployment();

      console.log(`MockOracle deployed to: ${await oracle.getAddress()}`);
      console.log(`WeatherInsurance deployed to: ${await insurance.getAddress()}`);
      console.log(`Premium suggestion for workshop: ${premiumWei.toString()} wei`);
      break;
    }

    case "track-3":
    case "ccip": {
      const gasLimit = toBigIntEnv("CCIP_GAS_LIMIT", "250000");
      const selector = toBigIntEnv("CCIP_DEST_CHAIN_SELECTOR", "16015286601757825753");
      const sourceRouter = requireEnv("CCIP_SOURCE_ROUTER", NETWORKS.avalancheFuji.ccipRouter);
      const destRouter = requireEnv("CCIP_DEST_ROUTER", NETWORKS.ethereumSepolia.ccipRouter);

      if (network.name === "sepolia") {
        const receiverFactory = await ethers.getContractFactory("CcipReceiver");
        const receiver = await receiverFactory.deploy(destRouter);
        await receiver.waitForDeployment();
        console.log(`CcipReceiver deployed to: ${await receiver.getAddress()}`);
        console.log("Next: switch to Avalanche Fuji and deploy the sender with CCIP_RECEIVER_ADDRESS set to this receiver address.");
        break;
      }

      if (network.name === "avalancheFuji") {
        const receiverAddress = requireEnv("CCIP_RECEIVER_ADDRESS");
        const senderFactory = await ethers.getContractFactory("CcipSender");
        const sender = await senderFactory.deploy(sourceRouter, selector, receiverAddress, gasLimit);
        await sender.waitForDeployment();
        console.log(`CcipSender deployed to: ${await sender.getAddress()}`);
        console.log("Next: keep this sender address for scripts/track3/send-ccip-message.ts.");
        break;
      }

      throw new Error("Track 3 uses sepolia for the receiver and avalancheFuji for the sender.");
    }

    case "track-4":
    case "tokenization": {
      const factory = await ethers.getContractFactory("RealEstateToken");
      const tokenName = process.env.TOKEN_NAME ?? "Vadodara Real Estate Share";
      const symbol = process.env.TOKEN_SYMBOL ?? "VRES";
      const supply = toBigIntEnv("TOKEN_SUPPLY", "1000000000000000000000");
      const signer = await ethers.provider.getSigner();
      const treasury = requireEnv("TREASURY_ADDRESS", await signer.getAddress());
      const propertyName = process.env.PROPERTY_NAME ?? "Builder House";
      const propertyLocation = process.env.PROPERTY_LOCATION ?? "Vadodara, Gujarat";
      const token = await factory.deploy(tokenName, symbol, treasury, supply, propertyName, propertyLocation);
      await token.waitForDeployment();
      console.log(`RealEstateToken deployed to: ${await token.getAddress()}`);
      break;
    }

    default:
      throw new Error(`Unknown TRACK value: ${track}`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
