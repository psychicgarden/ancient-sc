# 🏠 Ancient Lending - Test Site

A beautiful, fully-functional test site to demo the Ancient Lending smart contract flow.

**Shopify meets Soho House meets Zillow** - Buy premium real estate with crypto mortgages.

## 🎯 Features

### Marketplace
- Browse luxury properties (6 curated listings)
- Filter by location and price
- View detailed property information
- See mortgage breakdown (down payment, fees, monthly payments)
- Purchase properties with one click

### My Properties
- View all your owned properties
- Track mortgage progress with visual progress bars
- See payment history and remaining balance
- Make monthly payments
- Get notified when payments are due

### Staking Pool
- Deposit USDT to earn yield
- 9.4% APY from mortgage interest
- View your earnings breakdown:
  - Interest income
  - Appreciation share
  - Total returns
- Real-time pool metrics
- Withdraw anytime

## 🚀 Quick Start

### Option 1: Open Directly (Easiest)

```bash
# Just open the HTML file in your browser
open test-site/index.html
```

Or double-click `index.html` in Finder.

### Option 2: Local Server (Recommended)

```bash
# Navigate to test site
cd test-site

# Start a local server (Python 3)
python3 -m http.server 8000

# Or use Python 2
python -m SimpleHTTPServer 8000

# Or use Node.js (if you have http-server installed)
npx http-server -p 8000
```

Open http://localhost:8000 in your browser.

## 📖 How to Test the Flow

### 1. Connect Wallet
Click "Connect Wallet" in the top right. This simulates a wallet connection and gives you $1M USDT for testing.

### 2. Browse Properties
- View 6 different luxury properties
- See prices ranging from $325k to $1.2M
- Click any property to see full details

### 3. Purchase a Property
- Click "View Details" on any property
- Review the mortgage breakdown:
  - **Down Payment**: 20% of price
  - **Platform Fee**: 3% of price  
  - **Total Due Now**: 23% of price
  - **Monthly Payment**: Calculated for 120 months at 8% APR
- Click "Purchase Property"
- Watch your USDT balance decrease
- Property appears in "My Properties"

### 4. Manage Your Mortgages
- Go to "My Properties" tab
- See all your purchased properties
- Track payment progress (0/120 to 120/120)
- Visual progress bars show completion
- Make monthly payments when due
- See "Congratulations!" message when fully paid off

### 5. Stake USDT
- Go to "Staking Pool" tab
- Enter amount to deposit (minimum 100 USDT)
- Click "Deposit to Pool"
- Watch your stake grow
- View earnings breakdown
- See your share of the pool

## 🎨 UI Features

### Design
- **Modern gradient backgrounds**
- **Smooth animations and hover effects**
- **Responsive design** (works on mobile/tablet/desktop)
- **Soho House-inspired** premium aesthetic
- **Real property photos** from Unsplash

### User Experience
- **Toast notifications** for all actions
- **Modal dialogs** for property details
- **Progress bars** for mortgage tracking
- **Color-coded badges** for status
- **Real-time balance updates**

### Property Cards
Each property card shows:
- High-quality property image
- Property name and location
- Bedrooms, bathrooms, square footage
- Purchase price
- Down payment required
- Monthly payment amount
- "View Details" button

## 🧪 Testing Scenarios

### Scenario 1: First-Time Buyer
1. Connect wallet ($1M USDT balance)
2. Browse marketplace
3. Purchase "Austin Modern Home" ($380k)
   - Down payment: $76k
   - Platform fee: $11.4k
   - Total due: $87.4k
   - Monthly: ~$4,598
4. Go to "My Properties"
5. See property with 0/120 payments
6. Make first payment (simulated 30-day wait removed for testing)

### Scenario 2: Property Investor
1. Purchase multiple properties
2. Track all mortgages in "My Properties"
3. See different progress bars
4. Make payments on different properties
5. Watch completion percentages grow

### Scenario 3: Staker/Lender
1. Don't purchase any properties
2. Go directly to "Staking Pool"
3. Deposit $100k USDT
4. View pool statistics
5. See your share of earnings

### Scenario 4: Full Journey
1. Stake $200k in pool
2. Purchase 2 properties
3. Make payments on both
4. Watch staking earnings grow (simulated)
5. Complete one mortgage fully
6. See success celebration

## 💡 Mock Data & Simulations

### What's Mocked
- **Wallet connection** - No real MetaMask needed
- **USDT balance** - Start with $1M for testing
- **Transactions** - Instant (2-second delay for realism)
- **Time** - Payment due dates can be bypassed
- **Earnings** - Staking yields are simulated

### What's Real Logic
- **Down payment calculation** - Exactly 20%
- **Platform fee** - Exactly 3%
- **Monthly payment** - Real amortization formula approximation
- **Loan amount** - Exactly 80% of price
- **Payment tracking** - Real 120-payment counter
- **Progress bars** - Real percentage calculations

## 📊 Property Catalog

| Property | Location | Price | Type | Monthly Payment |
|----------|----------|-------|------|-----------------|
| Modern Miami Penthouse | Miami, FL | $450k | Penthouse | $5,445 |
| Beverly Hills Villa | LA, CA | $850k | Villa | $10,285 |
| Manhattan Loft | NY, NY | $625k | Loft | $7,562 |
| Austin Modern Home | Austin, TX | $380k | Single Family | $4,598 |
| Malibu Beach House | LA, CA | $1.2M | Beach House | $14,520 |
| South Beach Condo | Miami, FL | $325k | Condo | $3,932 |

## 🎯 Business Logic Demonstrated

### Mortgage Terms
- ✅ 20% down payment required
- ✅ 3% platform fee (upfront)
- ✅ 8% APR interest rate
- ✅ 120 monthly payments (10 years)
- ✅ Fixed monthly payment amount
- ✅ Payment tracking and history

### Staking Pool
- ✅ Minimum deposit: 100 USDT
- ✅ APY: 9.4% (displayed)
- ✅ Management fee: 2% (noted)
- ✅ Real-time pool metrics
- ✅ Earnings breakdown

### User Journey
1. **Browse** → Beautiful property marketplace
2. **Analyze** → Detailed mortgage breakdown
3. **Purchase** → One-click buying
4. **Manage** → Dashboard for all properties
5. **Pay** → Simple monthly payments
6. **Stake** → Passive income opportunity

## 🔧 Customization

### Add More Properties
Edit `app.js` and add to the `properties` array:

```javascript
{
    id: 7,
    name: "Your Property Name",
    location: "City, State",
    type: "Property Type",
    price: 500000,
    image: "https://images.unsplash.com/photo-...",
    futureValue: 550000,
    beds: 3,
    baths: 2,
    sqft: 2000
}
```

### Modify Contract Terms
In `app.js`, update the constants:
- `calculateMonthlyPayment()` - Change interest rate
- `property.price * 0.20` - Change down payment %
- `property.price * 0.03` - Change platform fee %
- `120` - Change number of payments

### Change Styling
Edit `index.html` `<style>` section or add custom CSS.

## 🚀 Next Steps

1. **Test the full flow** - Buy, pay, stake
2. **Share with stakeholders** - Get feedback on UX
3. **Deploy real contracts** - Use `make deploy`
4. **Connect to blockchain** - Replace mock functions
5. **Launch!** - Go live with real USDT

## 📱 Mobile Friendly

The site is fully responsive! Test on:
- iPhone/Android
- iPad/Tablet
- Desktop/Laptop

## 🎨 Screenshots

The site features:
- Hero section with stats
- Property grid with cards
- Detailed property modals
- Mortgage dashboard
- Staking interface
- Real-time notifications

## 🤝 Perfect for Demos

Use this to demonstrate:
- ✅ User flow to investors
- ✅ UI/UX to design team
- ✅ Business model to partners
- ✅ Contract logic to developers
- ✅ Market fit to advisors

## 📞 Support

Questions? The code is well-commented and easy to understand. Modify anything you want!

---

**Built with ❤️ for Ancient Lending**

*Shopify meets Soho House meets Zillow - The future of real estate is here.*
