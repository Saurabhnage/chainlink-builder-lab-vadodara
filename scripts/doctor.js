const fs = require("fs");

console.log("\n=== Chainlink Builder Lab Doctor ===\n");

if (!fs.existsSync(".env")) {
  console.log("❌ .env file not found");
  process.exit(1);
}

console.log("✅ .env file found");

const env = fs.readFileSync(".env", "utf8");

if (env.includes("YOUR_PRIVATE_KEY")) {
  console.log("⚠️ Private key not configured");
} else {
  console.log("✅ Private key configured");
}

if (env.includes("YOUR_KEY")) {
  console.log("⚠️ RPC URL not configured");
} else {
  console.log("✅ RPC URL configured");
}

console.log("\nDoctor check complete.");