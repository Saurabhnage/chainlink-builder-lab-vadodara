# Mentor Guide



## Common Errors



### HH117 Empty RPC URL



Cause:



SEPOLIA_RPC_URL not configured.



Fix:



Verify .env file and Alchemy endpoint.



---



### Missing PRIVATE_KEY



Cause:



Wallet not configured.



Fix:



Export private key from MetaMask and update .env.



---



### Insufficient Sepolia ETH



Cause:



Wallet has no test ETH.



Fix:



Use Sepolia Faucet.



---



### Insufficient Fuji AVAX



Cause:



Wallet has no AVAX.



Fix:



Use Fuji Faucet.



---



### Missing CCIP_SENDER_ADDRESS



Cause:



Sender contract deployed but address not copied into .env.



Fix:



Update:



CCIP_SENDER_ADDRESS=



---



### Compile Failure



Fix:



```bash

npm install

npm run workshop:check

```



---



### Deployment Failure



Fix:



Check:



* RPC URL

* Wallet balance

* Private key

* Network selection



