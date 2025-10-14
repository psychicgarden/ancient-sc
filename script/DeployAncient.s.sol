// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MockUSDT} from "../src/MockUSDT.sol";
import {AncientStakingPool} from "../src/AncientStakingPool.sol";
import {AncientMortgage} from "../src/AncientMortgage.sol";

/**
 * @title AncientDeploy
 * @notice Deployment script for Ancient Lending Protocol
 * @dev Deploys MockUSDT, AncientStakingPool and AncientMortgage contracts and links them together
 *
 * Environment Variables:
 * - PRIVATE_KEY: Private key for deployment (required)
 * - TREASURY_ADDRESS: Treasury address for platform fees (optional, defaults to deployer)
 *
 * Example Usage:
 * PRIVATE_KEY=$PRIVATE_KEY TREASURY_ADDRESS=$TREASURY_ADDRESS forge script script/DeployAncient.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
 *
 * Deployment Flow:
 * 1. Deploy MockUSDT token for testing
 * 2. Deploy AncientStakingPool with USDT and treasury addresses
 * 3. Deploy AncientMortgage with USDT and treasury addresses
 * 4. Link contracts by setting cross-references
 * 5. Validate deployments with contract-specific checks
 */
contract AncientDeploy is Script {
    function run() external {
        // Read deployment configuration from environment variables
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(privateKey);

        // Optional: Treasury address (defaults to deployer)
        address treasury;
        if (vm.envExists("TREASURY_ADDRESS")) {
            treasury = vm.envAddress("TREASURY_ADDRESS");
            require(treasury != address(0), "Invalid TREASURY_ADDRESS");
        } else {
            treasury = deployer;
        }

        console.log("Starting Ancient Lending Protocol deployment...");
        console.log("Deployer Address:", deployer);
        console.log("Treasury Address:", treasury);
        console.log("Network:", block.chainid);

        vm.startBroadcast(privateKey);

        // =======================================================================
        // CONTRACT DEPLOYMENT - DEPLOY MOCK USDT TOKEN
        // =======================================================================

        console.log("");
        console.log("Deploying MockUSDT...");

        MockUSDT usdt = new MockUSDT();

        console.log("MockUSDT deployed at:", address(usdt));

        // =======================================================================
        // CONTRACT DEPLOYMENT - DEPLOY ANCIENT STAKING POOL
        // =======================================================================

        console.log("");
        console.log("Deploying AncientStakingPool...");

        AncientStakingPool stakingPool = new AncientStakingPool(
            address(usdt),
            treasury
        );

        console.log("AncientStakingPool deployed at:", address(stakingPool));

        // =======================================================================
        // CONTRACT DEPLOYMENT - DEPLOY ANCIENT MORTGAGE
        // =======================================================================

        console.log("");
        console.log("Deploying AncientMortgage...");

        AncientMortgage mortgage = new AncientMortgage(address(usdt), treasury);

        console.log("AncientMortgage deployed at:", address(mortgage));

        // =======================================================================
        // CONTRACT LINKING - SET CROSS-REFERENCES
        // =======================================================================

        console.log("");
        console.log("Linking contracts...");

        // Set staking pool address in mortgage contract
        mortgage.setStakingPool(address(stakingPool));
        console.log("Set staking pool in mortgage contract");

        // Set mortgage contract address in staking pool
        stakingPool.setMortgageContract(address(mortgage));
        console.log("Set mortgage contract in staking pool");

        vm.stopBroadcast();

        console.log("");
        console.log("=== DEPLOYMENT SUMMARY ===");
        console.log("MockUSDT:", address(usdt));
        console.log("AncientStakingPool:", address(stakingPool));
        console.log("AncientMortgage:", address(mortgage));
        console.log("Deployer:", deployer);
        console.log("Treasury:", treasury);

        // =======================================================================
        // CONTRACT VALIDATION - VERIFY DEPLOYMENTS
        // =======================================================================

        console.log("");
        console.log("Validating deployments...");

        // Validate MockUSDT
        require(
            usdt.balanceOf(deployer) == 10_000_000 * 10 ** 6,
            "MockUSDT: Initial balance not set correctly"
        );
        require(usdt.decimals() == 6, "MockUSDT: Decimals not set correctly");
        require(usdt.owner() == deployer, "MockUSDT: Owner not set correctly");
        console.log("MockUSDT validation passed");

        // Validate AncientStakingPool
        require(
            address(stakingPool.usdt()) == address(usdt),
            "StakingPool: USDT not set correctly"
        );
        require(
            stakingPool.treasury() == treasury,
            "StakingPool: Treasury not set correctly"
        );
        require(
            stakingPool.mortgageContract() == address(mortgage),
            "StakingPool: Mortgage contract not linked"
        );
        require(
            stakingPool.owner() == deployer,
            "StakingPool: Owner not set correctly"
        );
        console.log("AncientStakingPool validation passed");

        // Validate AncientMortgage
        require(
            address(mortgage.usdt()) == address(usdt),
            "Mortgage: USDT not set correctly"
        );
        require(
            mortgage.treasury() == treasury,
            "Mortgage: Treasury not set correctly"
        );
        require(
            mortgage.stakingPool() == address(stakingPool),
            "Mortgage: Staking pool not linked"
        );
        require(
            mortgage.owner() == deployer,
            "Mortgage: Owner not set correctly"
        );
        console.log("AncientMortgage validation passed");

        // Additional contract-specific validation
        require(
            stakingPool.totalSupply() == 0,
            "StakingPool: Should start with zero supply"
        );
        require(
            stakingPool.totalDeposits() == 0,
            "StakingPool: Should start with zero deposits"
        );
        require(
            stakingPool.managementFeeBps() == 200,
            "StakingPool: Default fee should be 2%"
        );

        console.log("");
        console.log("All validations passed!");
        console.log("");
        console.log("Deployment completed successfully!");
        console.log("Verify contracts on your preferred block explorer:");
        console.log("- MockUSDT:", address(usdt));
        console.log("- AncientStakingPool:", address(stakingPool));
        console.log("- AncientMortgage:", address(mortgage));
    }
}
