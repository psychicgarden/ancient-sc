// Ancient Lending - Contract Addresses and ABIs
// Update these addresses after deployment

export const CONTRACTS = {
  // Deployed to Anvil (local testnet)
  mortgage: "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", // SimpleMortgage address
  stakingPool: "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0", // SimpleStakingPool address
  usdt: "0x5FbDB2315678afecb367f032d93F642f64180aa3", // Mock USDT
  treasury: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", // Treasury address
} as const;

export const NETWORKS = {
  baseMainnet: {
    id: 8453,
    name: "Base Mainnet",
    rpcUrl: "https://mainnet.base.org",
    blockExplorer: "https://basescan.org",
  },
  baseSepolia: {
    id: 84532,
    name: "Base Sepolia",
    rpcUrl: "https://sepolia.base.org",
    blockExplorer: "https://sepolia.basescan.org",
  },
  localhost: {
    id: 31337,
    name: "Localhost",
    rpcUrl: "http://localhost:8545",
    blockExplorer: "http://localhost:8545",
  },
} as const;

// SimpleMortgage ABI (key functions)
export const MORTGAGE_ABI = [
  // View functions
  "function getMortgage(uint256 tokenId) external view returns (address borrower, uint256 propertyPrice, uint256 loanAmount, uint256 monthlyPayment, uint256 paymentsMade, uint256 paymentsRemaining, uint256 totalInterestPaid, bool isActive)",
  "function getAppraisal(uint256 tokenId) external view returns (uint256 appraisedValue, uint256 appreciation, uint256 treasuryShare, uint256 stakerShare, bool distributed)",
  "function ownerOf(uint256 tokenId) external view returns (address owner)",
  "function balanceOf(address owner) external view returns (uint256 balance)",
  "function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId)",
  
  // Write functions
  "function purchaseProperty(uint256 propertyPrice) external returns (uint256)",
  "function makePayment(uint256 tokenId) external",
  "function appraiseProperty(uint256 tokenId, uint256 appraisedValue) external",
  "function distributeAppreciation(uint256 tokenId) external",
  
  // Constants
  "function DOWN_PAYMENT_BPS() external view returns (uint256)",
  "function INTEREST_RATE_BPS() external view returns (uint256)",
  "function TERM_MONTHS() external view returns (uint256)",
  "function PLATFORM_FEE_BPS() external view returns (uint256)",
  
  // Events
  "event MortgageCreated(uint256 indexed tokenId, address indexed borrower, uint256 propertyPrice, uint256 loanAmount, uint256 monthlyPayment)",
  "event PaymentMade(uint256 indexed tokenId, uint256 paymentNumber, uint256 interestPaid, uint256 principalPaid)",
  "event MortgageCompleted(uint256 indexed tokenId)",
  "event AppraiseProperty(uint256 indexed tokenId, uint256 appraisedValue, uint256 appreciation)",
  "event AppreciationDistributed(uint256 indexed tokenId, uint256 treasuryShare, uint256 stakerShare)",
] as const;

// SimpleStakingPool ABI (key functions)
export const STAKING_POOL_ABI = [
  // View functions
  "function balanceOf(address account) external view returns (uint256)",
  "function totalSupply() external view returns (uint256)",
  "function getPoolMetrics() external view returns (uint256 currentTotalAssets, uint256 currentTotalShares, uint256 currentExchangeRate, uint256 totalInterest, uint256 totalAppreciation)",
  "function totalAssetsUnderManagement() external view returns (uint256)",
  "function totalInterestReceived() external view returns (uint256)",
  "function totalAppreciationReceived() external view returns (uint256)",
  
  // Write functions
  "function deposit(uint256 usdtAmount) external returns (uint256 sharesMinted)",
  "function withdraw(uint256 sharesBurned) external returns (uint256 usdtAmount)",
  
  // Constants
  "function MIN_DEPOSIT() external view returns (uint256)",
  "function managementFeeBps() external view returns (uint256)",
  
  // Events
  "event Deposited(address indexed user, uint256 usdtAmount, uint256 sharesMinted)",
  "event Withdrawn(address indexed user, uint256 usdtAmount, uint256 sharesBurned)",
  "event InterestReceived(uint256 amount)",
  "event AppreciationReceived(uint256 amount)",
] as const;

// USDT ABI (standard ERC20)
export const USDT_ABI = [
  "function balanceOf(address owner) external view returns (uint256)",
  "function allowance(address owner, address spender) external view returns (uint256)",
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function transfer(address to, uint256 amount) external returns (bool)",
  "function transferFrom(address from, address to, uint256 amount) external returns (bool)",
  "function decimals() external view returns (uint8)",
  "function symbol() external view returns (string)",
  "function name() external view returns (string)",
] as const;

// Helper function to get contract addresses based on network
export function getContractAddresses(chainId: number) {
  switch (chainId) {
    case NETWORKS.baseMainnet.id:
      return {
        mortgage: CONTRACTS.mortgage,
        stakingPool: CONTRACTS.stakingPool,
        usdt: CONTRACTS.usdt, // USDbC on Base
        treasury: CONTRACTS.treasury,
      };
    case NETWORKS.baseSepolia.id:
      return {
        mortgage: CONTRACTS.mortgage,
        stakingPool: CONTRACTS.stakingPool,
        usdt: CONTRACTS.usdt, // You'll need to deploy mock USDT on testnet
        treasury: CONTRACTS.treasury,
      };
    case NETWORKS.localhost.id:
      return {
        mortgage: CONTRACTS.mortgage,
        stakingPool: CONTRACTS.stakingPool,
        usdt: CONTRACTS.usdt,
        treasury: CONTRACTS.treasury,
      };
    default:
      throw new Error(`Unsupported network: ${chainId}`);
  }
}
