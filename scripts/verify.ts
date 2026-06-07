import { network, ethers, run } from "hardhat";
import { requireEnv } from "./_helpers.js";

async function main() {
  const track = (process.env.TRACK ?? "track-1").toLowerCase();
  console.log(`Verifying contracts for ${track} on ${network.name}...`);

  if (track === "track-1" || track === "price-feed" || track === "track1") {
    const address = requireEnv("PRICE_FEED_CONSUMER_ADDRESS");
    const ethFeed = requireEnv("SEPOLIA_ETH_USD_FEED");
    const btcFeed = process.env.SEPOLIA_BTC_USD_FEED ?? "0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43";
    await run("verify:verify", {
      address,
      constructorArguments: [ethFeed, btcFeed]
    });
  }

  if (track === "track-4" || track === "tokenization") {
    const address = requireEnv("REAL_ESTATE_TOKEN_ADDRESS");
    await run("verify:verify", {
      address,
      constructorArguments: [
        process.env.TOKEN_NAME ?? "Vadodara Real Estate Share",
        process.env.TOKEN_SYMBOL ?? "VRES",
        requireEnv("TREASURY_ADDRESS"),
        process.env.TOKEN_SUPPLY ?? "1000000000000000000000",
        process.env.PROPERTY_NAME ?? "Builder House",
        process.env.PROPERTY_LOCATION ?? "Vadodara, Gujarat"
      ]
    });
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
