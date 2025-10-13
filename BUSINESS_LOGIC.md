# Ancient Lending - Business Logic Documentation

## Overview
Ancient Lending provides decentralized mortgage financing for real estate purchases with a 10-year term.

## Buyer Journey

### 1. Property Purchase
- **Down Payment**: 20% of property price
- **Loan Amount**: 80% of property price (financed)
- **Platform Fee**: 3% of property price (paid to treasury)
- **Collateral**: Property NFT held by contract until mortgage is paid off

### 2. Monthly Payments
- **Term**: 120 months (10 years)
- **Interest Rate**: 8% APR
- **Payment Structure**: 
  - Each payment includes interest + principal
  - Interest portion goes to staking pool (lenders)
  - Interest calculated on remaining balance

### 3. Mortgage Completion
- After 120 payments, mortgage is complete
- Property NFT transfers to buyer
- Buyer becomes full owner of the property

### 4. Year-10 Appraisal
- Third-party appraiser values the property
- **Appreciation Distribution** (if property increased in value):
  - **40%** → Ancient Treasury
  - **10%** → Staking Pool (lenders)
  - **50%** → Stays with property/SPV (buyer benefit)

## Lender/Staker Returns

### Example: $150k Property Purchase

**Loan Details:**
- Property Price: $150,000
- Down Payment (20%): $30,000
- Loan Amount (80%): $120,000
- Monthly Payment: ~$1,452
- Total Payments: $174,240
- Total Interest: $54,240

**Lender Returns (10-year hold):**
- Interest Earned: $54,240
- Appreciation Share (10% of $15k): $1,500
- **Total Return: $55,740**
- **Gross ROI: 46.4%**
- **Annualized IRR: ~9.4%**

### Management Fees
- **2% fee** on all yield (interest + appreciation) going to stakers
- Fee goes to Ancient Treasury
- Net yield to stakers = 98% of gross yield

## Smart Contract Architecture

### SimpleMortgage.sol
- Handles property purchases
- Manages monthly payments
- Tracks mortgage lifecycle
- Executes Year-10 appraisal and distribution
- Issues property NFTs as collateral

### SimpleStakingPool.sol
- Accepts USDT deposits from lenders
- Issues ERC20 shares representing pool ownership
- Receives interest from mortgage payments
- Receives appreciation share from Year-10 events
- Distributes management fees to treasury

## Key Features

### Security
- ✅ ReentrancyGuard on all state-changing functions
- ✅ Pausable for emergency situations
- ✅ Ownable for admin functions
- ✅ NFT collateral held by contract

### Transparency
- ✅ All payments tracked on-chain
- ✅ Interest/principal breakdown for each payment
- ✅ Real-time pool metrics
- ✅ Event emission for all major actions

### Fairness
- ✅ 50% of appreciation stays with property
- ✅ Lenders earn competitive 9.4% IRR
- ✅ Ancient earns platform fees + appreciation share
- ✅ Buyer builds equity and property ownership

## Comparison to Traditional Finance

| Metric | Ancient Lending | Traditional Mortgage |
|--------|----------------|---------------------|
| Down Payment | 20% | 20% typical |
| Interest Rate | 8% APR | 6-8% typical |
| Term | 10 years | 30 years typical |
| Appreciation Split | 40% platform, 10% lenders, 50% buyer | 100% buyer |
| Transparency | Full on-chain | Limited |
| Liquidity (for lenders) | ERC20 shares tradeable | Illiquid |

## Yield Comparison

Ancient's **9.4% IRR** compares favorably to:
- 🏦 U.S. Treasuries (10Y): 4.2%
- 🏘 REITs (avg dividend): 3.8%
- 🌐 Crypto Staking (ETH): 4.5%
- 💵 Stablecoin Lending: 5.0%

## Risk Considerations

### For Buyers
- Must make 120 on-time payments
- Only 50% of appreciation retained
- Property held as collateral

### For Lenders
- Real estate market risk
- Smart contract risk
- Borrower default risk (mitigated by collateral)

### For Platform
- Regulatory risk
- Smart contract vulnerabilities
- Market adoption risk

## Future Enhancements

Potential features for future versions:
- [ ] Late payment penalties
- [ ] Early payoff options
- [ ] Refinancing capability
- [ ] Multiple property types
- [ ] Insurance integration
- [ ] Credit scoring system
- [ ] Secondary market for mortgage NFTs

