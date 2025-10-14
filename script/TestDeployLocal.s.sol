// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SimpleMortgage} from "../src/SimpleMortgage.sol";
import {SimpleStakingPool} from "../src/SimpleStakingPool.sol";

// Mock USDT for testing
contract MockUSDT {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    string public name = "Mock USDT";
    string public symbol = "mUSDT";
    uint8 public decimals = 6;
    
    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
    
    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }
}

/**
 * @title TestDeployLocal
 * @notice Local test deployment script - simulates full deployment and basic operations
 * @dev Deploy mock USDT, then deploy Ancient Lending contracts, then test basic flows
 *
 * Usage:
 * forge script script/TestDeployLocal.s.sol -vvvv
 */
contract TestDeployLocal is Script {
    
    MockUSDT public usdt;
    SimpleMortgage public mortgage;
    SimpleStakingPool public stakingPool;
    
    address public deployer = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // Anvil default
    address public treasury;
    address public buyer = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC; // Anvil account 2  
    address public staker = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; // Anvil account 1
    
    uint256 constant PROPERTY_PRICE = 150_000 * 1e6; // $150k
    
    function run() external {
        console.log("");
        console.log("=== ANCIENT LENDING - LOCAL TEST DEPLOYMENT ===");
        console.log("");
        
        // Use default anvil private key
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        treasury = deployer; // Treasury is deployer for testing
        
        console.log("Test Configuration:");
        console.log("  Deployer/Treasury:", deployer);
        console.log("  Test Buyer:", buyer);
        console.log("  Test Staker:", staker);
        console.log("");
        
        vm.startBroadcast(privateKey);
        
        // 1. Deploy Mock USDT
        console.log("1. Deploying Mock USDT...");
        usdt = new MockUSDT();
        console.log("   Mock USDT deployed at:", address(usdt));
        
        // Mint USDT to test accounts
        usdt.mint(buyer, 10_000_000 * 1e6); // $10M to buyer
        usdt.mint(staker, 1_000_000 * 1e6); // $1M to staker
        console.log("   Minted USDT to test accounts");
        
        // 2. Deploy SimpleMortgage
        console.log("");
        console.log("2. Deploying SimpleMortgage...");
        mortgage = new SimpleMortgage(address(usdt), treasury);
        console.log("   SimpleMortgage deployed at:", address(mortgage));
        
        // 3. Deploy SimpleStakingPool
        console.log("");
        console.log("3. Deploying SimpleStakingPool...");
        stakingPool = new SimpleStakingPool(address(usdt), treasury);
        console.log("   SimpleStakingPool deployed at:", address(stakingPool));
        
        // 4. Link contracts
        console.log("");
        console.log("4. Linking contracts...");
        mortgage.setStakingPool(address(stakingPool));
        console.log("   Mortgage -> StakingPool linked");
        
        stakingPool.setMortgageContract(address(mortgage));
        console.log("   StakingPool -> Mortgage linked");
        
        vm.stopBroadcast();
        
        // 5. Validate deployment
        console.log("");
        console.log("5. Validating deployment...");
        _validateDeployment();
        
        // 6. Test basic operations
        console.log("");
        console.log("6. Testing basic operations...");
        _testOperations();
        
        console.log("");
        console.log("=== DEPLOYMENT AND TESTING COMPLETED ===");
        console.log("");
        console.log("Contract Addresses:");
        console.log("  Mock USDT:", address(usdt));
        console.log("  SimpleMortgage:", address(mortgage));
        console.log("  SimpleStakingPool:", address(stakingPool));
        console.log("");
    }
    
    function _validateDeployment() internal view {
        // Validate SimpleMortgage
        require(address(mortgage.usdt()) == address(usdt), "Mortgage: Invalid USDT");
        require(mortgage.treasury() == treasury, "Mortgage: Invalid treasury");
        require(mortgage.stakingPool() == address(stakingPool), "Mortgage: Pool not set");
        require(mortgage.owner() == deployer, "Mortgage: Invalid owner");
        require(mortgage.DOWN_PAYMENT_BPS() == 2000, "Mortgage: Wrong down payment");
        require(mortgage.INTEREST_RATE_BPS() == 800, "Mortgage: Wrong interest rate");
        require(mortgage.TERM_MONTHS() == 120, "Mortgage: Wrong term");
        console.log("   [OK] SimpleMortgage validated");
        
        // Validate SimpleStakingPool
        require(address(stakingPool.usdt()) == address(usdt), "Pool: Invalid USDT");
        require(stakingPool.treasury() == treasury, "Pool: Invalid treasury");
        require(stakingPool.owner() == deployer, "Pool: Invalid owner");
        require(stakingPool.managementFeeBps() == 200, "Pool: Wrong management fee");
        console.log("   [OK] SimpleStakingPool validated");
    }
    
    function _testOperations() internal {
        uint256 privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        
        // Test 1: Staker deposits
        console.log("");
        console.log("   Test 1: Staker deposits $120k to pool");
        vm.startBroadcast(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d); // Staker key (account 1)
        usdt.approve(address(stakingPool), type(uint256).max);
        uint256 shares = stakingPool.deposit(120_000 * 1e6);
        vm.stopBroadcast();
        console.log("      Staker received shares:", shares);
        require(shares > 0, "Staker deposit failed");
        console.log("      [OK] Staker deposit successful");
        
        // Test 2: Buyer purchases property
        console.log("");
        console.log("   Test 2: Buyer purchases $150k property");
        vm.startBroadcast(0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a); // Buyer key (account 2)
        usdt.approve(address(mortgage), type(uint256).max);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        vm.stopBroadcast();
        console.log("      Property NFT tokenId:", tokenId);
        require(tokenId == 1, "Property purchase failed");
        console.log("      [OK] Property purchase successful");
        
        // Test 3: Check mortgage details
        console.log("");
        console.log("   Test 3: Verify mortgage details");
        (
            address borrower,
            uint256 propertyPrice,
            uint256 loanAmount,
            uint256 monthlyPayment,
            ,
            uint256 paymentsRemaining,
            ,
        ) = mortgage.getMortgage(tokenId);
        
        console.log("      Borrower:", borrower);
        console.log("      Property Price: $", propertyPrice / 1e6);
        console.log("      Loan Amount: $", loanAmount / 1e6);
        console.log("      Monthly Payment: $", monthlyPayment / 1e6);
        console.log("      Payments Remaining:", paymentsRemaining);
        
        require(borrower == buyer, "Wrong borrower");
        require(propertyPrice == PROPERTY_PRICE, "Wrong property price");
        require(loanAmount == PROPERTY_PRICE * 80 / 100, "Wrong loan amount");
        require(paymentsRemaining == 120, "Wrong payments remaining");
        console.log("      [OK] Mortgage details correct");
        
        // Test 4: Make first payment
        console.log("");
        console.log("   Test 4: Buyer makes first payment");
        vm.warp(block.timestamp + 30 days);
        vm.startBroadcast(0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a); // Buyer key (account 2)
        mortgage.makePayment(tokenId);
        vm.stopBroadcast();
        
        (, , , , uint256 paymentsMade, , , ) = mortgage.getMortgage(tokenId);
        console.log("      Payments made:", paymentsMade);
        require(paymentsMade == 1, "Payment failed");
        console.log("      [OK] First payment successful");
        
        // Test 5: Check staking pool received interest
        console.log("");
        console.log("   Test 5: Verify staking pool received interest");
        uint256 totalInterest = stakingPool.totalInterestReceived();
        console.log("      Total interest received: $", totalInterest / 1e6);
        require(totalInterest > 0, "Pool did not receive interest");
        console.log("      [OK] Staking pool receiving interest");
        
        console.log("");
        console.log("   [SUCCESS] All tests passed!");
    }
}

