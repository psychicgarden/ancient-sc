/**
 * Ancient Lending Protocol - Deployment Addresses
 * 
 * This file contains the deployed contract addresses for all networks.
 * Generated from deployment artifacts in broadcast/ directory.
 */

export interface DeploymentAddresses {
  MockUSDT: string;
  AncientStakingPool: string;
  AncientMortgage: string;
}

export interface NetworkDeployments {
  [chainId: number]: DeploymentAddresses;
}

/**
 * Chain IDs for supported networks
 */
export const ChainId = {
  BASE_SEPOLIA: 84532,
  AVALANCHE_FUJI: 43113,
  ANVIL: 31337,
} as const;

/**
 * Network names for display
 */
export const NetworkNames: Record<number, string> = {
  [ChainId.BASE_SEPOLIA]: "Base Sepolia",
  [ChainId.AVALANCHE_FUJI]: "Avalanche Fuji",
  [ChainId.ANVIL]: "Anvil (Local)",
};

/**
 * All deployment addresses by chain ID
 */
export const deployments: NetworkDeployments = {
  // Base Sepolia (Testnet)
  [ChainId.BASE_SEPOLIA]: {
    MockUSDT: "0x82895d380f6df68d50e34d2ccc94bad1415a2b46",
    AncientStakingPool: "0xac7378799cffd01f38a4e39fb5d91d60a0e62b33",
    AncientMortgage: "0xb48a5f86ffe36d3249acf6d97b14c2eac0dea6b5",
  },

  // Avalanche Fuji (Testnet)
  [ChainId.AVALANCHE_FUJI]: {
    MockUSDT: "0x5b510bD0179191Edda8b8B7E3c3a260689264aDD",
    AncientStakingPool: "0xd9EFCc0d6fc50Fc0371C3f69C8D083B915AE15C1",
    AncientMortgage: "0x2A8979EB5F05dDE08918C1E624aa8217dEE516e0",
  },
};

/**
 * Helper function to get addresses for a specific chain
 * @param chainId - The chain ID to get addresses for
 * @returns Deployment addresses for the specified chain, or undefined if not deployed
 */
export function getAddresses(chainId: number): DeploymentAddresses | undefined {
  return deployments[chainId];
}

/**
 * Helper function to check if protocol is deployed on a chain
 * @param chainId - The chain ID to check
 * @returns True if deployed, false otherwise
 */
export function isDeployed(chainId: number): boolean {
  return chainId in deployments;
}

/**
 * Block explorer URLs for each network
 */
export const BlockExplorerUrls: Record<number, string> = {
  [ChainId.BASE_SEPOLIA]: "https://sepolia.basescan.org",
  [ChainId.AVALANCHE_FUJI]: "https://testnet.snowtrace.io",
  [ChainId.ANVIL]: "http://localhost:8545",
};

/**
 * Helper function to get block explorer URL for an address
 * @param chainId - The chain ID
 * @param address - The contract address
 * @returns Full URL to view the address on block explorer
 */
export function getExplorerUrl(chainId: number, address: string): string {
  const baseUrl = BlockExplorerUrls[chainId];
  return baseUrl ? `${baseUrl}/address/${address}` : "";
}

/**
 * Deployment timestamps (Unix timestamps in seconds)
 */
export const DeploymentTimestamps: Record<number, number> = {
  [ChainId.BASE_SEPOLIA]: Math.floor(1760478150892 / 1000), // 2025-10-14
  [ChainId.AVALANCHE_FUJI]: Math.floor(Date.now() / 1000), // Update with actual timestamp
};

/**
 * Default export for convenience
 */
export default deployments;

