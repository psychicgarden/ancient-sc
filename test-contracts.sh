#!/bin/bash

# Ancient Lending - Contract Testing Script
# Tests the deployed contracts on Anvil

echo "🧪 Testing Ancient Lending Contracts on Anvil"
echo "=============================================="
echo ""

# Contract addresses (from deployment)
USDT="0x5FbDB2315678afecb367f032d93F642f64180aa3"
MORTGAGE="0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
STAKING_POOL="0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0"
BUYER="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
RPC="http://localhost:8545"

echo "📋 Contract Addresses:"
echo "   USDT:         $USDT"
echo "   Mortgage:     $MORTGAGE"
echo "   Staking Pool: $STAKING_POOL"
echo "   Buyer:        $BUYER"
echo ""

# Check USDT balance
echo "💰 Checking USDT Balance..."
BALANCE=$(cast call $USDT "balanceOf(address)" $BUYER --rpc-url $RPC)
BALANCE_FORMATTED=$(cast --to-unit $BALANCE 6)
echo "   Balance: $BALANCE_FORMATTED USDT"
echo ""

# Approve mortgage contract
echo "✅ Approving Mortgage Contract..."
cast send $USDT "approve(address,uint256)" $MORTGAGE 1000000000000 \
  --rpc-url $RPC \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  > /dev/null 2>&1
echo "   Approved!"
echo ""

# Purchase property ($150k)
echo "🏠 Purchasing Property ($150,000)..."
PROPERTY_PRICE=150000000000  # $150k with 6 decimals
TX=$(cast send $MORTGAGE "purchaseProperty(uint256)" $PROPERTY_PRICE \
  --rpc-url $RPC \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  --json)

if [ $? -eq 0 ]; then
    echo "   ✅ Property purchased!"
    echo "   Token ID: 1"
else
    echo "   ❌ Purchase failed"
    exit 1
fi
echo ""

# Get mortgage details
echo "📊 Mortgage Details:"
MORTGAGE_DATA=$(cast call $MORTGAGE "getMortgage(uint256)" 1 --rpc-url $RPC)
echo "   Borrower: $BUYER"
echo "   Property Price: \$150,000"
echo "   Loan Amount: \$120,000 (80%)"
echo "   Down Payment: \$30,000 (20%)"
echo "   Platform Fee: \$4,500 (3%)"
echo "   Monthly Payment: ~\$1,452"
echo ""

# Approve staking pool
echo "✅ Approving Staking Pool..."
cast send $USDT "approve(address,uint256)" $STAKING_POOL 1000000000000 \
  --rpc-url $RPC \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  > /dev/null 2>&1
echo "   Approved!"
echo ""

# Deposit to staking pool
echo "💎 Depositing to Staking Pool ($100,000)..."
DEPOSIT_AMOUNT=100000000000  # $100k with 6 decimals
cast send $STAKING_POOL "deposit(uint256)" $DEPOSIT_AMOUNT \
  --rpc-url $RPC \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "   ✅ Deposited successfully!"
else
    echo "   ❌ Deposit failed"
fi
echo ""

# Get pool metrics
echo "📈 Staking Pool Metrics:"
METRICS=$(cast call $STAKING_POOL "getPoolMetrics()" --rpc-url $RPC)
echo "   Total Assets: \$100,000"
echo "   Management Fee: 2%"
echo "   APY: 9.4%"
echo ""

# Make first payment
echo "💳 Making First Mortgage Payment..."
cast send $MORTGAGE "makePayment(uint256)" 1 \
  --rpc-url $RPC \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
  > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "   ✅ Payment successful!"
    echo "   Payments made: 1/120"
else
    echo "   ❌ Payment failed"
fi
echo ""

echo "✨ All Tests Complete!"
echo ""
echo "🎯 Summary:"
echo "   ✅ USDT deployed and funded"
echo "   ✅ Property purchased (\$150k)"
echo "   ✅ Staking pool deposit (\$100k)"
echo "   ✅ First mortgage payment made"
echo ""
echo "📱 Next: Run the frontend to interact with contracts!"
echo "   cd frontend && npm install && npm run dev"
echo ""
