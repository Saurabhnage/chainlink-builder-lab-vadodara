# Chainlink Builder Lab — Vadodara

A beginner-friendly workshop repository for teaching Chainlink through a single learning journey:

**Problem:** smart contracts cannot access reliable real-world data  
↓  
**Track 1:** read price feeds  
↓  
**Track 2:** use data for insurance  
↓  
**Track 3:** move data across chains with CCIP  
↓  
**Track 4:** represent real assets with tokenization

This repo is designed for a 4-hour in-person workshop where students can clone the repo, install dependencies, and complete one track without fighting setup issues.

## What is inside

- Solidity contracts for four workshop tracks
- Hardhat + TypeScript + Ethers v6 setup
- Chainlink Data Feeds and CCIP workshop material
- Step-by-step beginner setup guides
- Mermaid architecture diagrams
- Deployment and troubleshooting scripts

## Learning outcomes

By the end of the workshop, students should understand:

- why oracles exist
- how Chainlink Price Feeds work
- how a simple parametric insurance contract behaves
- how CCIP sends a message between two chains
- how ERC20 tokenization can represent real assets
- how to deploy and verify contracts on testnet

## Project structure

```text
chainlink-builder-lab-vadodara/
├─ contracts/
├─ scripts/
├─ setup/
├─ track-1-price-feed/
├─ track-2-weather-insurance/
├─ track-3-ccip/
├─ track-4-tokenization/
└─ resources/
```

## Quick start

```bash
git clone <your-fork-or-repo-url>
cd chainlink-builder-lab-vadodara
npm install
cp .env.example .env
npm run compile
```

### Deploy example

```bash
TRACK=track-1 npx hardhat run scripts/deploy.ts --network sepolia
```

### CCIP note

Track 3 is deployed in two steps:

1. deploy the receiver on Sepolia
2. deploy the sender on Avalanche Fuji with `CCIP_RECEIVER_ADDRESS` set to the receiver address


## Workshop schedule

| Time | Segment |
|---|---|
| 0:00 - 0:20 | Welcome, wallet setup, repo walkthrough |
| 0:20 - 0:40 | Track selection and architecture overview |
| 0:40 - 1:40 | Build time for the selected track |
| 1:40 - 2:10 | Deploy and verify |
| 2:10 - 2:40 | Show and tell |
| 2:40 - 3:10 | Bonus challenge |
| 3:10 - 4:00 | Debugging, Q&A, next steps |

## Track selection guide

- **Track 1 — Price Feed Consumer**: best first track for total beginners
- **Track 2 — Weather Insurance**: best for understanding oracle-driven logic
- **Track 3 — CCIP**: best for cross-chain messaging demos
- **Track 4 — Tokenization**: best for product and asset modeling

## Setup flow

1. Install Node.js 22+
2. Install dependencies
3. Copy `.env.example` to `.env`
4. Fund your wallet on Sepolia
5. Compile contracts
6. Run the deploy script for the track you picked

## FAQ

**Do students need prior Solidity experience?**  
No. The docs are written for first-time Solidity users.

**Do we need a backend?**  
No. Everything is onchain and beginner-friendly.

**Which network should I use?**  
Track 1, 2, and 4 run on Sepolia. Track 3 uses Ethereum Sepolia for the receiver and Avalanche Fuji for the sender because CCIP needs two chains.

**Can students complete the repo during the workshop?**  
Yes. Each track is designed to be deployable in roughly 60 to 90 minutes.

## Troubleshooting

- If compilation fails, check Node.js version and reinstall dependencies.
- If deployment fails, verify RPC URL and private key.
- If CCIP sends fail, check router addresses and chain selectors.
- If price feed reading fails, check the feed addresses in `.env`.

## Useful links

- [Setup guides](setup/metamask-guide.md)
- [Track 1](track-1-price-feed/README.md)
- [Track 2](track-2-weather-insurance/README.md)
- [Track 3](track-3-ccip/README.md)
- [Track 4](track-4-tokenization/README.md)
