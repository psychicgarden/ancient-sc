// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SimpleMortgage} from "../src/SimpleMortgage.sol";
import {SimpleStakingPool} from "../src/SimpleStakingPool.sol";

/**
 * @title DeployAncientLending
 * @notice Deployment script for Ancient Lending mortgage and staking pool contracts
 * @dev Deploys SimpleMortgage and SimpleStakingPool, then links them together
 *
 * Environment Variables:
 * - PRIVATE_KEY: Private key for deployment (handled by Makefile)
 * - USDT_ADDRESS: Address of USDT token contract (required)
 * - TREASURY_ADDRESS: Address of Ancient treasury (optional, defaults to deployer)
 *
 * Usage with Makefile:
 * 
 * 1. Set environment variables in .env:
 *    USDT_ADDRESS=0x...
 *    TREASURY_ADDRESS=0x...
 *    TESTNET_PRIVATE_KEY=your_key
 *    MAINNET_PRIVATE_KEY=your_key
 *    ETHERSCAN_KEY=your_key
 *
 * 2. Run deployment:
 *    make deploy
 *
 * 3. Follow prompts to select:
 *    - Network (base-sepolia, base-mainnet, etc.)
 *    - Verify on explorer (y/n)
 *    - Broadcast transaction (y/n)
 *
 * Manual Usage (without Makefile):
 * forge script script/DeployAncientLending.s.sol \
 *   --rpc-url base-sepolia \
 *   --broadcast \
 *   --verify \
 *   -vvv
 */
contract DeployAncientLending is Script {
    
    // Deployed contract instances
    SimpleMortgage public mortgage;
    SimpleStakingPool public stakingPool;
    
    // Deployment configuration
    address public usdt;
    address public treasury;
    address public deployer;
    
    function run() external {
        // Get deployer address from private key
        uint256 privateKey;
        if (vm.envExists("PRIVATE_KEY")) {
            privateKey = vm.envUint("PRIVATE_KEY");
        } else if (vm.envExists("TESTNET_PRIVATE_KEY")) {
            privateKey = vm.envUint("TESTNET_PRIVATE_KEY");
        } else {
            revert("No private key found. Set PRIVATE_KEY or TESTNET_PRIVATE_KEY");
        }
        deployer = vm.addr(privateKey);
        
        // Get USDT address (required)
        require(vm.envExists("USDT_ADDRESS"), "USDT_ADDRESS not set in .env");
        usdt = vm.envAddress("USDT_ADDRESS");
        
        // Get treasury address (optional, defaults to deployer)
        if (vm.envExists("TREASURY_ADDRESS")) {
            treasury = vm.envAddress("TREASURY_ADDRESS");
        } else {
            treasury = deployer;
            console.log("WARNING: TREASURY_ADDRESS not set, using deployer address");
        }
        
        // Validate addresses
        require(usdt != address(0), "Invalid USDT address");
        require(treasury != address(0), "Invalid treasury address");
        
        console.log("");
        console.log("=== ANCIENT LENDING DEPLOYMENT ===");
        console.log("");
        console.log("Configuration:");
        console.log("  Deployer:", deployer);
        console.log("  USDT Token:", usdt);
        console.log("  Treasury:", treasury);
        console.log("  Network Chain ID:", block.chainid);
        console.log("");
        
        // Start deployment
        vm.startBroadcast(privateKey);
        
        // Deploy SimpleMortgage
        console.log("Deploying SimpleMortgage...");
        mortgage = new SimpleMortgage(usdt, treasury);
        console.log("  SimpleMortgage deployed at:", address(mortgage));
        
        // Deploy SimpleStakingPool
        console.log("");
        console.log("Deploying SimpleStakingPool...");
        stakingPool = new SimpleStakingPool(usdt, treasury);
        console.log("  SimpleStakingPool deployed at:", address(stakingPool));
        
        // Link contracts together
        console.log("");
        console.log("Linking contracts...");
        mortgage.setStakingPool(address(stakingPool));
        console.log("  Mortgage -> StakingPool link established");
        
        stakingPool.setMortgageContract(address(mortgage));
        console.log("  StakingPool -> Mortgage link established");
        
        vm.stopBroadcast();
        
        // Deployment summary
        console.log("");
        console.log("=== DEPLOYMENT SUMMARY ===");
        console.log("");
        console.log("Contracts:");
        console.log("  SimpleMortgage:", address(mortgage));
        console.log("  SimpleStakingPool:", address(stakingPool));
        console.log("");
        console.log("Configuration:");
        console.log("  USDT Token:", usdt);
        console.log("  Treasury:", treasury);
        console.log("  Deployer/Owner:", deployer);
        console.log("");
        
        // Validate deployment
        _validateDeployment();
        
        console.log("");
        console.log("=== DEPLOYMENT COMPLETED SUCCESSFULLY ===");
        console.log("");
        console.log("Save these addresses for your frontend:");
        console.log("");
        console.log("export const CONTRACTS = {");
        console.log("  mortgage: '", vm.toString(address(mortgage)), "',");
        console.log("  stakingPool: '", vm.toString(address(stakingPool)), "',");
        console.log("  usdt: '", vm.toString(usdt), "',");
        console.log("  treasury: '", vm.toString(treasury), "',");
        console.log("};");
        console.log("");
    }
    
    function _validateDeployment() internal view {
        console.log("Validating deployment...");
        console.log("");
        
        // Validate SimpleMortgage
        console.log("SimpleMortgage Validation:");
        require(address(mortgage.usdt()) == usdt, "Mortgage: Invalid USDT address");
        console.log("  [OK] USDT address correct");
        
        require(mortgage.treasury() == treasury, "Mortgage: Invalid treasury address");
        console.log("  [OK] Treasury address correct");
        
        require(mortgage.stakingPool() == address(stakingPool), "Mortgage: Staking pool not set");
        console.log("  [OK] Staking pool linked");
        
        require(mortgage.owner() == deployer, "Mortgage: Invalid owner");
        console.log("  [OK] Owner is deployer");
        
        // Validate constants
        require(mortgage.DOWN_PAYMENT_BPS() == 2000, "Mortgage: Invalid down payment");
        console.log("  [OK] Down payment: 20%");
        
        require(mortgage.INTEREST_RATE_BPS() == 800, "Mortgage: Invalid interest rate");
        console.log("  [OK] Interest rate: 8%");
        
        require(mortgage.TERM_MONTHS() == 120, "Mortgage: Invalid term");
        console.log("  [OK] Term: 120 months");
        
        require(mortgage.PLATFORM_FEE_BPS() == 300, "Mortgage: Invalid platform fee");
        console.log("  [OK] Platform fee: 3%");
        
        console.log("");
        console.log("SimpleStakingPool Validation:");
        require(address(stakingPool.usdt()) == usdt, "Pool: Invalid USDT address");
        console.log("  [OK] USDT address correct");
        
        require(stakingPool.treasury() == treasury, "Pool: Invalid treasury address");
        console.log("  [OK] Treasury address correct");
        
        require(stakingPool.owner() == deployer, "Pool: Invalid owner");
        console.log("  [OK] Owner is deployer");
        
        require(stakingPool.managementFeeBps() == 200, "Pool: Invalid management fee");
        console.log("  [OK] Management fee: 2%");
        
        require(stakingPool.MIN_DEPOSIT() == 100 * 1e6, "Pool: Invalid min deposit");
        console.log("  [OK] Min deposit: 100 USDT");
        
        console.log("");
        console.log("[SUCCESS] All validations passed!");
    }
}
