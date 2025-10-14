# Ancient Lending Frontend

A React/Next.js frontend for interacting with Ancient Lending smart contracts.

## Features

- 🔗 Wallet connection (MetaMask, WalletConnect, etc.)
- 🏠 Property purchase with 20% down payment
- 💰 Mortgage payment management
- 🏦 Staking pool deposits and withdrawals
- 📊 Real-time contract metrics
- 📱 Responsive design

## Quick Start

### 1. Install Dependencies

```bash
cd frontend
npm install
```

### 2. Update Contract Addresses

After deploying your contracts, update the addresses in `contracts.ts`:

```typescript
export const CONTRACTS = {
  mortgage: "0x...", // Your SimpleMortgage address
  stakingPool: "0x...", // Your SimpleStakingPool address
  usdt: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913", // USDbC on Base
  treasury: "0x...", // Your treasury address
} as const;
```

### 3. Get WalletConnect Project ID

1. Go to [WalletConnect Cloud](https://cloud.walletconnect.com)
2. Create a new project
3. Copy your Project ID
4. Update `_app.tsx`:
   ```typescript
   projectId: 'your-walletconnect-project-id',
   ```

### 4. Run Development Server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

## Usage

### For Users

1. **Connect Wallet**: Click "Connect Wallet" to connect MetaMask or other wallet
2. **Purchase Property**: 
   - Enter property price (e.g., 150000 for $150k)
   - Click "Purchase Property"
   - Approve USDT spending if needed
   - Pay 20% down + 3% platform fee
3. **Make Payments**: 
   - Enter your mortgage token ID
   - Click "Make Payment" monthly
4. **Stake**: 
   - Enter amount to deposit (minimum 100 USDT)
   - Click "Deposit to Pool"
   - Earn interest from mortgage payments

### For Developers

#### Contract Integration

The frontend uses wagmi hooks to interact with contracts:

```typescript
// Read contract data
const { data: mortgageDetails } = useContractRead({
  address: mortgageAddress,
  abi: MORTGAGE_ABI,
  functionName: 'getMortgage',
  args: [BigInt(tokenId)],
});

// Write to contract
const { write: purchaseProperty } = useContractWrite({
  address: mortgageAddress,
  abi: MORTGAGE_ABI,
  functionName: 'purchaseProperty',
});
```

#### Adding New Features

1. Add new functions to ABIs in `contracts.ts`
2. Create new components in `components/`
3. Add new pages in `pages/`
4. Update navigation in `index.tsx`

## Network Support

Currently configured for:
- Base Mainnet
- Base Sepolia (testnet)
- Localhost (for testing)

Add more networks in `contracts.ts`:

```typescript
export const NETWORKS = {
  // ... existing networks
  ethereum: {
    id: 1,
    name: "Ethereum Mainnet",
    rpcUrl: "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY",
    blockExplorer: "https://etherscan.io",
  },
} as const;
```

## Testing

### Local Testing

1. Start local blockchain:
   ```bash
   anvil
   ```

2. Deploy contracts:
   ```bash
   forge script script/TestDeployLocal.s.sol:TestDeployLocal -vvv
   ```

3. Update `contracts.ts` with local addresses

4. Run frontend:
   ```bash
   npm run dev
   ```

### Testnet Testing

1. Deploy to testnet:
   ```bash
   make deploy
   # Select base-sepolia
   ```

2. Update `contracts.ts` with testnet addresses

3. Get testnet USDT from faucet or deploy mock

## Deployment

### Vercel (Recommended)

1. Push to GitHub
2. Connect to Vercel
3. Set environment variables:
   - `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID`
4. Deploy

### Other Platforms

```bash
# Build
npm run build

# Start production server
npm start
```

## Troubleshooting

### Common Issues

1. **"Contract not deployed"**: Update addresses in `contracts.ts`
2. **"Insufficient USDT"**: Get USDT from faucet or exchange
3. **"Transaction failed"**: Check gas fees and network
4. **"Wallet not connected"**: Refresh page and reconnect

### Debug Mode

Add to your browser console:
```javascript
localStorage.setItem('wagmi.debug', 'true');
```

### Network Issues

Make sure you're on the correct network:
- Base Mainnet: Chain ID 8453
- Base Sepolia: Chain ID 84532

## Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

MIT License - see LICENSE file for details
