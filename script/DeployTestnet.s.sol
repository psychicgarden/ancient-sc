// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {SimpleMortgage} from "../src/SimpleMortgage.sol";
import {SimpleStakingPool} from "../src/SimpleStakingPool.sol";
import {MockUSDT} from "../src/MockUSDT.sol";

/**
 * @title DeployTestnet
 * @notice Complete testnet deployment - deploys MockUSDT, SimpleMortgage, and SimpleStakingPool
 * @dev All-in-one deployment for Base Sepolia testing
 *
 * Usage:
 * forge script script/DeployTestnet.s.sol:DeployTestnet --rpc-url base-sepolia --broadcast --verify -vvv
 */
contract DeployTestnet is Script {
    
    MockUSDT public usdt;
    SimpleMortgage public mortgage;
    SimpleStakingPool public stakingPool;
    
    address public deployer;
    address public treasury;
    
    function run() external {
        // Get deployer from private key
        uint256 privateKey;
        
        // Try to get from environment first
        try vm.envUint("TESTNET_PRIVATE_KEY") returns (uint256 key) {
            privateKey = key;
        } catch {
            try vm.envUint("PRIVATE_KEY") returns (uint256 key) {
                privateKey = key;
            } catch {
                // Use Anvil's default account for local testing
                privateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
                console.log("Using Anvil default account for local testing");
            }
        }
        
        deployer = vm.addr(privateKey);
        treasury = deployer; // Use deployer as treasury for testing
        
        console.log("");
        console.log("=== ANCIENT LENDING - TESTNET DEPLOYMENT ===");
        console.log("");
        console.log("Deployer:", deployer);
        console.log("Treasury:", treasury);
        console.log("Network:", block.chainid);
        console.log("");
        
        vm.startBroadcast(privateKey);
        
        // 1. Deploy Mock USDT
        console.log("1. Deploying Mock USDT...");
        usdt = new MockUSDT();
        console.log("   Mock USDT:", address(usdt));
        console.log("   Deployer balance:", usdt.balanceOf(deployer) / 1e6, "USDT");
        
        // 2. Deploy SimpleMortgage
        console.log("");
        console.log("2. Deploying SimpleMortgage...");
        mortgage = new SimpleMortgage(address(usdt), treasury);
        console.log("   SimpleMortgage:", address(mortgage));
        
        // 3. Deploy SimpleStakingPool
        console.log("");
        console.log("3. Deploying SimpleStakingPool...");
        stakingPool = new SimpleStakingPool(address(usdt), treasury);
        console.log("   SimpleStakingPool:", address(stakingPool));
        
        // 4. Link contracts
        console.log("");
        console.log("4. Linking contracts...");
        mortgage.setStakingPool(address(stakingPool));
        stakingPool.setMortgageContract(address(mortgage));
        console.log("   Contracts linked successfully");
        
        vm.stopBroadcast();
        
        // Summary
        console.log("");
        console.log("=== DEPLOYMENT COMPLETE ===");
        console.log("");
        console.log("Contract Addresses (save these!):");
        console.log("----------------------------------");
        console.log("Mock USDT:       ", address(usdt));
        console.log("SimpleMortgage:  ", address(mortgage));
        console.log("SimpleStakingPool:", address(stakingPool));
        console.log("Treasury:        ", treasury);
        console.log("");
        console.log("Block Explorer:");
        console.log("https://sepolia.basescan.org/address/", address(mortgage));
        console.log("");
        console.log("Next Steps:");
        console.log("1. Update frontend/contracts.ts with these addresses");
        console.log("2. Run: cd frontend && npm install && npm run dev");
        console.log("3. Connect MetaMask to Base Sepolia");
        console.log("4. Import USDT token:", address(usdt));
        console.log("5. Call usdt.faucet() to get 1000 USDT");
        console.log("");
        console.log("Frontend Config:");
        console.log("----------------");
        console.log("export const CONTRACTS = {");
        console.log("  mortgage: '", vm.toString(address(mortgage)), "',");
        console.log("  stakingPool: '", vm.toString(address(stakingPool)), "',");
        console.log("  usdt: '", vm.toString(address(usdt)), "',");
        console.log("  treasury: '", vm.toString(treasury), "',");
        console.log("};");
        console.log("");
        
        // Validate
        _validate();
    }
    
    function _validate() internal view {
        console.log("Validating deployment...");
        require(address(mortgage.usdt()) == address(usdt), "Mortgage: Wrong USDT");
        require(mortgage.treasury() == treasury, "Mortgage: Wrong treasury");
        require(mortgage.stakingPool() == address(stakingPool), "Mortgage: Pool not linked");
        require(address(stakingPool.usdt()) == address(usdt), "Pool: Wrong USDT");
        require(stakingPool.treasury() == treasury, "Pool: Wrong treasury");
        console.log("[OK] All validations passed!");
        console.log("");
    }
}

