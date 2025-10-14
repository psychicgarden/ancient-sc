// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MockUSDT
 * @notice Mock USDT token for testing on testnet
 * @dev 6 decimals like real USDT
 */
contract MockUSDT is ERC20, Ownable {
    
    constructor() ERC20("Mock USDT", "mUSDT") Ownable(msg.sender) {
        // Mint 10 million USDT to deployer for testing
        _mint(msg.sender, 10_000_000 * 10**6);
    }
    
    function decimals() public pure override returns (uint8) {
        return 6; // USDT has 6 decimals
    }
    
    // Allow anyone to mint for testing
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
    
    // Faucet function - get 1000 USDT
    function faucet() external {
        _mint(msg.sender, 1000 * 10**6);
    }
}
