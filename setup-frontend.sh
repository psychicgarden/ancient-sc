#!/bin/bash

# Ancient Lending - Frontend Setup Script

echo "🚀 Setting up Ancient Lending Frontend..."

# Check if we're in the right directory
if [ ! -f "foundry.toml" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Create frontend directory if it doesn't exist
if [ ! -d "frontend" ]; then
    echo "📁 Frontend directory already exists"
else
    echo "✅ Frontend directory created"
fi

# Install frontend dependencies
echo "📦 Installing frontend dependencies..."
cd frontend

if command -v npm &> /dev/null; then
    npm install
    echo "✅ Dependencies installed with npm"
elif command -v yarn &> /dev/null; then
    yarn install
    echo "✅ Dependencies installed with yarn"
else
    echo "❌ Error: npm or yarn not found. Please install Node.js first"
    exit 1
fi

# Create .env.local file for frontend
echo "⚙️ Creating frontend environment file..."
cat > .env.local << EOF
# Frontend Environment Variables
NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID=your-walletconnect-project-id

# Contract addresses (update after deployment)
NEXT_PUBLIC_MORTGAGE_ADDRESS=0x0000000000000000000000000000000000000000
NEXT_PUBLIC_STAKING_POOL_ADDRESS=0x0000000000000000000000000000000000000000
NEXT_PUBLIC_USDT_ADDRESS=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913
NEXT_PUBLIC_TREASURY_ADDRESS=0x0000000000000000000000000000000000000000

# Network configuration
NEXT_PUBLIC_CHAIN_ID=8453
NEXT_PUBLIC_RPC_URL=https://mainnet.base.org
EOF

echo "✅ Environment file created: frontend/.env.local"

# Create deployment helper script
echo "🔧 Creating deployment helper script..."
cat > ../deploy-and-update.sh << 'EOF'
#!/bin/bash

echo "🚀 Deploying contracts and updating frontend..."

# Deploy contracts
echo "📝 Deploying contracts..."
make deploy

# Wait for user to copy addresses
echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 Next steps:"
echo "1. Copy the contract addresses from the deployment output above"
echo "2. Update frontend/contracts.ts with the new addresses:"
echo "   - SimpleMortgage: <address>"
echo "   - SimpleStakingPool: <address>"
echo "3. Run: cd frontend && npm run dev"
echo ""
echo "🔗 Contract addresses to update:"
echo "   mortgage: <copy from deployment output>"
echo "   stakingPool: <copy from deployment output>"
echo "   usdt: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 (USDbC on Base)"
echo "   treasury: <your treasury address>"
EOF

chmod +x ../deploy-and-update.sh

echo ""
echo "🎉 Frontend setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Get WalletConnect Project ID from https://cloud.walletconnect.com"
echo "2. Update frontend/.env.local with your project ID"
echo "3. Deploy contracts: ./deploy-and-update.sh"
echo "4. Update contract addresses in frontend/contracts.ts"
echo "5. Start frontend: cd frontend && npm run dev"
echo ""
echo "🌐 Frontend will be available at: http://localhost:3000"
echo ""
echo "📚 Documentation: frontend/README.md"
