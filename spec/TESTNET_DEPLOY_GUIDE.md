# 🚀 Deploy to Base Sepolia Testnet

## Step 1: Get Testnet ETH

You need Base Sepolia ETH for gas fees.

### Option A: Base Sepolia Faucet
1. Go to: https://www.alchemy.com/faucets/base-sepolia
2. Enter your wallet address
3. Get free testnet ETH

### Option B: Coinbase Wallet
1. If you have Coinbase account, use their faucet
2. https://portal.cdp.coinbase.com/products/faucet

## Step 2: Create .env File

```bash
# In the project root, create .env file
nano .env
```

Add this content:
```bash
# Your MetaMask testnet private key (Export from MetaMask)
TESTNET_PRIVATE_KEY=your_private_key_here_without_0x

# Optional: Etherscan API key for verification
ETHERSCAN_KEY=your_etherscan_key_here

# These will be set during deployment
USDT_ADDRESS=
TREASURY_ADDRESS=
```

## Step 3: Deploy Mock USDT First

We need to deploy a mock USDT token for testing:

```bash
# Create and run the mock USDT deployment
forge create src/test/MockUSDT.sol:MockUSDT \
  --rpc-url base-sepolia \
  --private-key $TESTNET_PRIVATE_KEY
```

Copy the deployed address and add to .env:
```bash
USDT_ADDRESS=0x...
```

## Step 4: Deploy Ancient Lending Contracts

```bash
# Run the interactive deployment
make deploy

# When prompted:
# 1. Select: AncientLending
# 2. Select network: base-sepolia
# 3. Is mainnet? n
# 4. Verify? y
# 5. Broadcast? y
```

## Step 5: Save Contract Addresses

After deployment, you'll see:
```
AncientMortgage: 0x...
AncientStakingPool: 0x...
```

Save these addresses!

## Step 6: Update Frontend

```bash
# Edit frontend/contracts.ts
nano frontend/contracts.ts
```

Update the addresses:
```typescript
export const CONTRACTS = {
  mortgage: "0x...", // Your AncientMortgage address
  stakingPool: "0x...", // Your AncientStakingPool address
  usdt: "0x...", // Your Mock USDT address
  treasury: "0x...", // Your wallet address
} as const;
```

## Step 7: Get Test USDT

Mint yourself some test USDT:

```bash
# Mint 1 million USDT to your address
cast send $USDT_ADDRESS \
  "mint(address,uint256)" \
  YOUR_WALLET_ADDRESS \
  1000000000000 \
  --rpc-url base-sepolia \
  --private-key $TESTNET_PRIVATE_KEY
```

## Step 8: Test It!

```bash
# Start the frontend
cd frontend
npm install
npm run dev
```

Open http://localhost:3000 and:
1. Connect MetaMask (switch to Base Sepolia)
2. You should see your USDT balance
3. Try purchasing a property!
4. Make payments!
5. Stake USDT!

## Quick Commands Reference

```bash
# Check your testnet ETH balance
cast balance YOUR_ADDRESS --rpc-url base-sepolia

# Check USDT balance  
cast call $USDT_ADDRESS "balanceOf(address)" YOUR_ADDRESS --rpc-url base-sepolia

# View contract on explorer
open "https://sepolia.basescan.org/address/CONTRACT_ADDRESS"
```

## Troubleshooting

**"Insufficient funds"**
- Get more testnet ETH from faucet

**"Contract not verified"**
- Add ETHERSCAN_KEY to .env
- Rerun with --verify flag

**"Transaction reverted"**
- Check you have USDT balance
- Check contracts are deployed correctly
- Check you approved USDT spending

## Need Help?

Check the logs during deployment for any errors!
