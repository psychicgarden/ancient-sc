#!/bin/bash

echo "🚀 Ancient Lending - Testnet Deployment"
echo "========================================"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo ""
    echo "Create .env file with:"
    echo "TESTNET_PRIVATE_KEY=your_private_key_here"
    echo ""
    echo "Get your private key from MetaMask:"
    echo "1. Open MetaMask"
    echo "2. Click account menu → Account Details"
    echo "3. Click 'Export Private Key'"
    echo "4. Enter password and copy the key (without 0x)"
    echo ""
    exit 1
fi

# Source .env
set -a
source .env
set +a

# Check for private key
if [ -z "$TESTNET_PRIVATE_KEY" ]; then
    echo "❌ TESTNET_PRIVATE_KEY not set in .env"
    exit 1
fi

# Get deployer address
DEPLOYER=$(cast wallet address --private-key $TESTNET_PRIVATE_KEY)
echo "📋 Deployer Address: $DEPLOYER"
echo ""

# Check balance
echo "💰 Checking testnet ETH balance..."
BALANCE=$(cast balance $DEPLOYER --rpc-url base-sepolia)
BALANCE_ETH=$(cast --to-unit $BALANCE ether)
echo "   Balance: $BALANCE_ETH ETH"
echo ""

if [ $(echo "$BALANCE_ETH < 0.01" | bc) -eq 1 ]; then
    echo "⚠️  Low balance! You need testnet ETH for gas fees."
    echo ""
    echo "Get free Base Sepolia ETH from:"
    echo "🔗 https://www.alchemy.com/faucets/base-sepolia"
    echo ""
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📦 Deploying contracts..."
echo ""

# Deploy
forge script script/DeployTestnet.s.sol:DeployTestnet \
    --rpc-url base-sepolia \
    --broadcast \
    --verify \
    --etherscan-api-key ${ETHERSCAN_KEY:-""} \
    -vvv

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📝 Next steps:"
echo "1. Copy the contract addresses from above"
echo "2. Update frontend/contracts.ts"
echo "3. Run: cd frontend && npm install && npm run dev"
echo "4. Connect MetaMask to Base Sepolia"
echo "5. Test the app!"
echo ""
