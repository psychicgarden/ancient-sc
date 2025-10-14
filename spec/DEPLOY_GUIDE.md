# 🚀 Ancient Lending - Deployment Guide

## Quick Start

### 1. Setup Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env with your values
nano .env
```

Required variables in `.env`:
```bash
# Private keys (no 0x prefix)
TESTNET_PRIVATE_KEY=your_testnet_key
MAINNET_PRIVATE_KEY=your_mainnet_key

# USDT address for your target network
USDT_ADDRESS=0x...

# Treasury address (optional, defaults to deployer)
TREASURY_ADDRESS=0x...

# Etherscan API key for verification
ETHERSCAN_KEY=your_key
```

### 2. Deploy Contracts

```bash
make deploy
```

The Makefile will prompt you to:
1. **Select deployment script** → Choose `AncientLending`
2. **Select RPC endpoint** → Choose from:
   - `anvil` (local)
   - `sepolia` (Ethereum testnet)
   - `base-sepolia` (Base testnet)
   - `base-mainnet` (Base mainnet)
   - `optimism-sepolia` (Optimism testnet)
3. **Is this mainnet?** → `y` or `n`
4. **Verify on explorer?** → `y` or `n`
5. **Broadcast transaction?** → `y` or `n`

### 3. Save Contract Addresses

After deployment, save the output:

```typescript
export const CONTRACTS = {
  mortgage: '0x...',
  stakingPool: '0x...',
  usdt: '0x...',
  treasury: '0x...',
};
```

---

## Network-Specific USDT Addresses

### Base
- **Base Mainnet**: `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` (USDbC)
- **Base Sepolia**: Deploy mock USDT for testing

### Ethereum
- **Mainnet**: `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- **Sepolia**: Deploy mock USDT for testing

### Optimism
- **Mainnet**: `0x94b008aA00579c1307B0EF2c499aD98a8ce58e58`
- **Sepolia**: Deploy mock USDT for testing

---

## Example Deployment Flow

```bash
$ make deploy

Available deploy scripts:
  1) AncientLending
  2) ExampleDeploy
Select script name or number (default: AncientLending): 1

Available RPC aliases from foundry.toml:
  1) anvil
  2) base-mainnet
  3) base-sepolia
  4) optimism-sepolia
  5) sepolia
Select RPC alias (name or number, default: base-sepolia): 3

Is this a mainnet? [y/n] (default: n): n
Verify on explorer? [y/n] (default: y): y
Broadcast transaction? [y/n] (default: y): y

Deploying AncientLending to base-sepolia

=== ANCIENT LENDING DEPLOYMENT ===

Configuration:
  Deployer: 0x...
  USDT Token: 0x...
  Treasury: 0x...
  Network Chain ID: 84532

Deploying SimpleMortgage...
  SimpleMortgage deployed at: 0x...

Deploying SimpleStakingPool...
  SimpleStakingPool deployed at: 0x...

Linking contracts...
  Mortgage -> StakingPool link established
  StakingPool -> Mortgage link established

=== DEPLOYMENT SUMMARY ===

Contracts:
  SimpleMortgage: 0x...
  SimpleStakingPool: 0x...

Validating deployment...

SimpleMortgage Validation:
  [OK] USDT address correct
  [OK] Treasury address correct
  [OK] Staking pool linked
  [OK] Owner is deployer
  [OK] Down payment: 20%
  [OK] Interest rate: 8%
  [OK] Term: 120 months
  [OK] Platform fee: 3%

SimpleStakingPool Validation:
  [OK] USDT address correct
  [OK] Treasury address correct
  [OK] Owner is deployer
  [OK] Management fee: 2%
  [OK] Min deposit: 100 USDT

[SUCCESS] All validations passed!

=== DEPLOYMENT COMPLETED SUCCESSFULLY ===
```

---

## Testing Before Mainnet

### 1. Deploy to Testnet

```bash
# Set testnet USDT address in .env
USDT_ADDRESS=0x... # Your mock USDT on testnet

# Deploy
make deploy
# Select testnet (base-sepolia, sepolia, etc.)
# Answer "n" to mainnet question
```

### 2. Run Integration Tests

```bash
# Test on local fork
forge test -vvv

# Test specific contract
forge test --match-contract SimpleMortgageTest -vvv
```

### 3. Manual Testing

Test with small amounts:
1. Deposit $100 USDT to staking pool
2. Purchase $10k property
3. Make first mortgage payment
4. Verify events and balances

---

## Post-Deployment Checklist

- [ ] Contracts deployed successfully
- [ ] Contracts verified on block explorer
- [ ] Contract addresses saved
- [ ] Frontend updated with addresses
- [ ] Test transactions completed
- [ ] Monitoring set up
- [ ] Team notified
- [ ] Documentation updated

---

## Troubleshooting

### "USDT_ADDRESS not set"
```bash
# Add to .env
USDT_ADDRESS=0x...
```

### "No private key found"
```bash
# Add to .env
TESTNET_PRIVATE_KEY=your_key
MAINNET_PRIVATE_KEY=your_key
```

### Verification fails
```bash
# Check ETHERSCAN_KEY is set
ETHERSCAN_KEY=your_key

# Or deploy without verification
# Answer "n" when prompted for verify
```

### Wrong network
```bash
# Check foundry.toml has correct RPC endpoints
# Or add custom RPC:
[rpc_endpoints]
my-network = "https://rpc.my-network.com"
```

---

## Security Recommendations

### For Testnet
- Use separate testnet wallet
- Don't use real funds
- Test all functionality

### For Mainnet
- Use hardware wallet or multisig
- Set treasury to multisig address
- Start with small transactions
- Monitor contract events
- Have emergency pause plan
- Get professional audit

---

## Contract Addresses (Save After Deployment)

### Base Sepolia (Testnet)
```
SimpleMortgage: 
SimpleStakingPool: 
USDT: 
Treasury: 
```

### Base Mainnet (Production)
```
SimpleMortgage: 
SimpleStakingPool: 
USDT: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
Treasury: 
```

---

## Support

- GitHub: [ancient-lending/contracts](https://github.com/ancient-lending/contracts)
- Docs: [docs.ancient-lending.com](https://docs.ancient-lending.com)
- Discord: [discord.gg/ancient-lending](https://discord.gg/ancient-lending)

