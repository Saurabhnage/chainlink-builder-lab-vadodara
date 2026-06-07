# Hardhat guide

Hardhat is the local development toolkit used in this repository.

Use it to:
- compile contracts
- deploy to testnet
- run scripts
- verify contracts

## Beginner checklist

```bash
npm install
cp .env.example .env
npm run compile
```

## Common beginner mistakes

- Running the deploy script before filling `.env`
- Using the wrong private key
- Missing an RPC URL
