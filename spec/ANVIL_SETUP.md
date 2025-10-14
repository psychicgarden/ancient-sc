# 🦊 Connect MetaMask to Anvil (Local Testnet)

## Step 1: Add Anvil Network to MetaMask

1. Open MetaMask
2. Click network dropdown (top left)
3. Click "Add Network" → "Add a network manually"
4. Enter these details:

```
Network Name: Anvil Local
RPC URL: http://localhost:8545
Chain ID: 31337
Currency Symbol: ETH
```

5. Click "Save"

## Step 2: Import Anvil Test Account

Anvil gives you 10 test accounts with 10,000 ETH each!

1. In MetaMask, click account icon → "Add account or hardware wallet"
2. Click "Import account"
3. Paste this private key:
```
0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
```
4. Click "Import"

You now have 10,000 ETH and 10,000,000 USDT! 💰

## Step 3: Add USDT Token

1. In MetaMask, scroll down and click "Import tokens"
2. Paste the USDT contract address:
```
0x5FbDB2315678afecb367f032d93F642f64180aa3
```
3. Token symbol should auto-fill as "mUSDT"
4. Click "Add custom token" → "Import"

You should see: **10,000,000 mUSDT**

## Step 4: Open the Frontend

The frontend is already running at: http://localhost:3000

Or start it with:
```bash
cd frontend
npm run dev
```

## Step 5: Connect & Test!

1. Go to http://localhost:3000
2. Click "Connect Wallet"
3. Select MetaMask
4. Approve the connection
5. You should see your balance!

## 🎯 What You Can Do:

### Purchase Properties
- Browse 6 luxury properties
- Click any property → "View Details"
- See mortgage breakdown
- Click "Purchase Property"
- Approve USDT spending in MetaMask
- Confirm transaction
- Property appears in "My Properties"!

### Make Payments
- Go to "My Properties" tab
- See your purchased properties
- Click "Make Payment Now"
- Approve transaction
- Watch progress bar grow!

### Stake USDT
- Go to "Staking Pool" tab
- Enter amount (min 100 USDT)
- Click "Deposit to Pool"
- Earn 9.4% APY from mortgage interest!

## 🔧 Troubleshooting

**"Wrong network"**
- Make sure you're on "Anvil Local" network in MetaMask

**"Insufficient funds"**
- Make sure you imported the Anvil account (you should have 10k ETH)

**"Transaction failed"**
- Check you approved USDT spending first
- Make sure Anvil is still running (check terminal)

**"Can't connect"**
- Restart Anvil: `anvil --port 8545`
- Refresh the page

## 📊 Contract Addresses (Already Configured)

```
Mock USDT:        0x5FbDB2315678afecb367f032d93F642f64180aa3
AncientMortgage:   0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
AncientStakingPool: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
```

## 🎉 You're Ready!

Everything is set up and working with REAL smart contracts on your local blockchain!

Test the full flow:
1. Purchase a property
2. Make monthly payments
3. Stake USDT
4. See everything update in real-time!

Enjoy! 🚀
