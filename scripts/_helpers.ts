import * as dotenv from "dotenv";

dotenv.config();

export const NETWORKS = {
  sepolia: {
    chainId: 11155111,
    ethUsdFeed: process.env.SEPOLIA_ETH_USD_FEED ?? "0x694AA1769357215DE4FAC081bf1f309aDC325306",
    btcUsdFeed: process.env.SEPOLIA_BTC_USD_FEED ?? "0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43"
  },
  avalancheFuji: {
    chainId: 43113,
    ccipRouter: process.env.CCIP_SOURCE_ROUTER ?? "0xF694E193200268f9a4868e4Aa017A0118C9a8177",
    ccipSelector: BigInt(process.env.CCIP_SOURCE_CHAIN_SELECTOR ?? "14767482510784806043")
  },
  ethereumSepolia: {
    chainId: 11155111,
    ccipRouter: process.env.CCIP_DEST_ROUTER ?? "0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59",
    ccipSelector: BigInt(process.env.CCIP_DEST_CHAIN_SELECTOR ?? "16015286601757825753")
  }
} as const;

export function toBigIntEnv(name: string, fallback: string): bigint {
  const raw = process.env[name];
  return BigInt(raw && raw.trim() !== "" ? raw : fallback);
}

export function toNumberEnv(name: string, fallback: string): number {
  const raw = process.env[name];
  return Number(raw && raw.trim() !== "" ? raw : fallback);
}

export function requireEnv(name: string, fallback?: string): string {
  const raw = process.env[name];
  const value = raw && raw.trim() !== "" ? raw : fallback;
  if (!value || value.trim() === "") {
    throw new Error(`Missing environment variable: ${name}`);
  }
  return value;
}
