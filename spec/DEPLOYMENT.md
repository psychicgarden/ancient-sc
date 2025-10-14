# Ancient Lending - Deployment Guide

## Prerequisites

1. **Foundry installed**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Environment variables configured** (see `.env.example`)

3. **Funded deployer wallet** with native gas tokens

4. **USDT contract address** for target network

## Quick Start

### 1. Clone and Setup

```bash
git clone <repo-url>
cd ancient-sc
forge install
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your values
```

Required variables:
- `PRIVATE_KEY` - Deployer private key (without 0x prefix)
- `USDT_ADDRESS` - USDT token contract address
- `TREASURY_ADDRESS` - Ancient treasury wallet
- `TRUSTED_APPRAISER` - Trusted appraiser address
- `RPC_URL` - Network RPC endpoint
- `ETHERSCAN_API_KEY` - For contract verification (optional)

### 3. Deploy Contracts

```bash
# Load environment variables
source .env

# Deploy to testnet
forge script script/DeployAncientLending.s.sol \
  --rpc-url $RPC_URL \
  --broadcast \
  --verify \
  -vvvv

# Deploy to mainnet (add --legacy for some networks)
forge script script/DeployAncientLending.s.sol \
  --rpc-url $MAINNET_RPC_URL \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  -vvvv
```

## Network-Specific Addresses

### Ethereum Mainnet
- **USDT**: `0xdAC17F958D2ee523a2206206994597C13D831ec7`
- **Chain ID**: 1

### Ethereum Sepolia Testnet
- **USDT**: Deploy mock or use existing testnet USDT
- **Chain ID**: 11155111

### Polygon
- **USDT**: `0xc2132D05D31c914a87C6611C10748AEb04B58e8F`
- **Chain ID**: 137

### Arbitrum One
- **USDT**: `0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9`
- **Chain ID**: 42161

### Base
- **USDT**: Check Base documentation for current address
- **Chain ID**: 8453

## Deployment Steps Explained

The deployment script performs the following:

1. **Validates Configuration**
   - Checks all required addresses are set
   - Verifies deployer has sufficient gas

2. **Deploys SimpleMortgage**
   - Constructor args: `(usdt, treasury, trustedAppraiser)`
   - Sets up mortgage parameters (20% down, 8% APR, 120 months)

3. **Deploys SimpleStakingPool**
   - Constructor args: `(usdt, treasury)`
   - Sets up staking pool with 2% management fee

4. **Links Contracts**
   - `mortgage.setStakingPool(stakingPool)`
   - `stakingPool.setMortgageContract(mortgage)`

5. **Validates Deployment**
   - Checks all addresses are correct
   - Verifies contract parameters
   - Confirms contract linkage

## Post-Deployment

### 1. Verify Contracts on Block Explorer

The script outputs verification commands. Run them:

```bash
forge verify-contract \
  <MORTGAGE_ADDRESS> \
  src/SimpleMortgage.sol:SimpleMortgage \
  --constructor-args $(cast abi-encode "constructor(address,address,address)" $USDT_ADDRESS $TREASURY_ADDRESS $TRUSTED_APPRAISER) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --chain-id $CHAIN_ID

forge verify-contract \
  <STAKING_POOL_ADDRESS> \
  src/SimpleStakingPool.sol:SimpleStakingPool \
  --constructor-args $(cast abi-encode "constructor(address,address)" $USDT_ADDRESS $TREASURY_ADDRESS) \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --chain-id $CHAIN_ID
```

### 2. Update Frontend Configuration

Update your frontend with deployed addresses:

```typescript
export const CONTRACTS = {
  mortgage: "0x...", // SimpleMortgage address
  stakingPool: "0x...", // SimpleStakingPool address
  usdt: "0x...", // USDT address
  treasury: "0x...", // Treasury address
};
```

### 3. Test Deployment

Run integration tests:

```bash
# Test on fork
forge test --fork-url $RPC_URL -vvv

# Test specific contract
forge test --match-contract SimpleMortgageTest -vvv
```

### 4. Initial Test Transactions

Perform small test transactions:

1. **Staker deposits $100 USDT**
   ```solidity
   stakingPool.deposit(100 * 1e6)
   ```

2. **Buyer purchases $10k property**
   ```solidity
   mortgage.purchaseProperty(10000 * 1e6)
   ```

3. **Buyer makes first payment**
   ```solidity
   mortgage.makePayment(tokenId)
   ```

4. **Verify events emitted correctly**

## Security Checklist

Before mainnet deployment:

- [ ] All tests passing (`forge test`)
- [ ] Code audited by professional auditors
- [ ] Deployment script tested on testnet
- [ ] Treasury address is multisig
- [ ] Trusted appraiser address is secure
- [ ] Emergency pause mechanism tested
- [ ] Contract verification successful
- [ ] Frontend integration tested
- [ ] Monitoring/alerting set up
- [ ] Insurance/bug bounty program active

## Monitoring

After deployment, monitor:

1. **Contract Events**
   - MortgageCreated
   - PaymentMade
   - MortgageCompleted
   - AppraiseProperty
   - Deposited/Withdrawn

2. **Key Metrics**
   - Total mortgages created
   - Total value locked in staking pool
   - Average mortgage size
   - Payment success rate
   - Pool APY

3. **Security**
   - Unusual transaction patterns
   - Large withdrawals
   - Failed transactions
   - Contract balance changes

## Troubleshooting

### Deployment Fails

**Error: "Invalid USDT address"**
- Check USDT address is correct for network
- Verify USDT contract exists at address

**Error: "Insufficient gas"**
- Increase gas limit: `--gas-limit 5000000`
- Check deployer has enough native tokens

**Error: "Nonce too low"**
- Reset nonce or wait for pending transactions

### Verification Fails

**Error: "Contract source code already verified"**
- Contract is already verified, skip this step

**Error: "Bytecode mismatch"**
- Ensure compiler version matches (0.8.19)
- Check optimization settings in foundry.toml
- Verify constructor args are correct

### Contract Interaction Fails

**Error: "Only owner"**
- Ensure calling from deployer address
- Check ownership transferred correctly

**Error: "Invalid staking pool"**
- Verify `setStakingPool()` was called
- Check staking pool address is correct

## Gas Estimates

Approximate gas costs (at 30 gwei):

| Operation | Gas Used | Cost (ETH) | Cost (USD @ $2000) |
|-----------|----------|------------|-------------------|
| Deploy Mortgage | ~3,500,000 | 0.105 | $210 |
| Deploy Staking Pool | ~2,500,000 | 0.075 | $150 |
| Link Contracts | ~100,000 | 0.003 | $6 |
| **Total Deployment** | **~6,100,000** | **0.183** | **$366** |

## Support

For deployment issues:
- Check [GitHub Issues](https://github.com/ancient-lending/contracts/issues)
- Join [Discord](https://discord.gg/ancient-lending)
- Email: dev@ancient-lending.com

## License

MIT License - See LICENSE file for details

