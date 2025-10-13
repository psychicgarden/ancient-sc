// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title SimpleStakingPool
 * @dev Simplified staking pool that receives mortgage interest and appreciation
 * 
 * Yield Sources:
 * - Monthly interest from mortgages (8% APR on loans)
 * - 10% of property appreciation at year 10
 * 
 * Expected Returns:
 * - Target IRR: ~9.4% annually
 * - Based on real mortgage cashflows
 */
contract SimpleStakingPool is ERC20, Ownable, ReentrancyGuard, Pausable {
    
    IERC20 public immutable usdt;
    address public mortgageContract;
    address public immutable treasury;
    
    uint256 public totalDeposits;
    uint256 public totalInterestReceived;
    uint256 public totalAppreciationReceived;
    uint256 public managementFeeBps = 200; // 2%
    
    uint256 public constant MIN_DEPOSIT = 100 * 1e6; // 100 USDT (6 decimals)
    
    event Deposited(address indexed user, uint256 usdtAmount, uint256 sharesMinted);
    event Withdrawn(address indexed user, uint256 usdtAmount, uint256 sharesBurned);
    event InterestReceived(uint256 amount);
    event AppreciationReceived(uint256 amount);
    event ManagementFeeCollected(uint256 amount);
    
    constructor(
        address _usdt,
        address _treasury
    ) ERC20("Ancient Staking Pool", "ASP") Ownable(msg.sender) {
        require(_usdt != address(0), "Invalid USDT");
        require(_treasury != address(0), "Invalid treasury");
        usdt = IERC20(_usdt);
        treasury = _treasury;
    }
    
    function setMortgageContract(address _mortgageContract) external onlyOwner {
        require(_mortgageContract != address(0), "Invalid mortgage contract");
        mortgageContract = _mortgageContract;
    }
    
    /**
     * @dev Deposit USDT and receive pool shares
     * Initial ratio: 1 USDT = 1e12 shares (to handle 6 decimal USDT)
     */
    function deposit(uint256 usdtAmount) external nonReentrant whenNotPaused returns (uint256 shares) {
        require(usdtAmount >= MIN_DEPOSIT, "Below minimum");
        
        // Calculate shares to mint
        if (totalSupply() == 0) {
            // Initial deposit: 1 USDT (6 decimals) = 1e12 shares (18 decimals)
            shares = usdtAmount * 1e12;
        } else {
            // Subsequent deposits: maintain ratio based on pool value
            uint256 poolValue = totalAssets();
            shares = (usdtAmount * totalSupply()) / poolValue;
        }
        
        // Transfer USDT
        require(usdt.transferFrom(msg.sender, address(this), usdtAmount), "Transfer failed");
        
        totalDeposits += usdtAmount;
        
        // Mint shares
        _mint(msg.sender, shares);
        
        emit Deposited(msg.sender, usdtAmount, shares);
    }
    
    /**
     * @dev Withdraw USDT by burning shares
     */
    function withdraw(uint256 shares) external nonReentrant returns (uint256 usdtAmount) {
        require(shares > 0, "Invalid shares");
        require(balanceOf(msg.sender) >= shares, "Insufficient shares");
        
        // Calculate USDT to return
        uint256 poolValue = totalAssets();
        usdtAmount = (shares * poolValue) / totalSupply();
        
        require(usdtAmount <= poolValue, "Insufficient pool balance");
        
        // Burn shares
        _burn(msg.sender, shares);
        
        // Transfer USDT
        require(usdt.transfer(msg.sender, usdtAmount), "Transfer failed");
        
        emit Withdrawn(msg.sender, usdtAmount, shares);
    }
    
    /**
     * @dev Receive interest from mortgage payments
     * Called by mortgage contract
     */
    function receiveInterest(uint256 amount) external nonReentrant {
        require(msg.sender == mortgageContract, "Only mortgage contract");
        require(amount > 0, "Invalid amount");
        
        // Collect management fee
        uint256 fee = (amount * managementFeeBps) / 10000;
        uint256 netAmount = amount - fee;
        
        if (fee > 0) {
            require(usdt.transfer(treasury, fee), "Fee transfer failed");
            emit ManagementFeeCollected(fee);
        }
        
        totalInterestReceived += netAmount;
        
        emit InterestReceived(netAmount);
    }
    
    /**
     * @dev Receive appreciation share (10%) from year 10 appraisals
     * Called by mortgage contract
     */
    function receiveAppreciation(uint256 amount) external nonReentrant {
        require(msg.sender == mortgageContract, "Only mortgage contract");
        require(amount > 0, "Invalid amount");
        
        // Collect management fee
        uint256 fee = (amount * managementFeeBps) / 10000;
        uint256 netAmount = amount - fee;
        
        if (fee > 0) {
            require(usdt.transfer(treasury, fee), "Fee transfer failed");
            emit ManagementFeeCollected(fee);
        }
        
        totalAppreciationReceived += netAmount;
        
        emit AppreciationReceived(netAmount);
    }
    
    /**
     * @dev Get total assets under management (USDT balance)
     */
    function totalAssets() public view returns (uint256) {
        return usdt.balanceOf(address(this));
    }
    
    /**
     * @dev Calculate user's USDT value
     */
    function getUserValue(address user) external view returns (uint256) {
        if (totalSupply() == 0) return 0;
        return (balanceOf(user) * totalAssets()) / totalSupply();
    }
    
    /**
     * @dev Calculate current APY based on actual yields
     */
    function getCurrentAPY() external view returns (uint256) {
        if (totalDeposits == 0) return 0;
        
        uint256 totalYield = totalInterestReceived + totalAppreciationReceived;
        if (totalYield == 0) return 0;
        
        // Simple APY calculation: (total yield / total deposits) * 100
        // This is simplified - in production would use time-weighted calculations
        return (totalYield * 10000) / totalDeposits; // Returns basis points
    }
    
    /**
     * @dev Get pool statistics
     */
    function getPoolStats() external view returns (
        uint256 totalPoolValue,
        uint256 interestEarned,
        uint256 appreciationEarned,
        uint256 totalYield,
        uint256 currentAPY
    ) {
        totalPoolValue = totalAssets();
        interestEarned = totalInterestReceived;
        appreciationEarned = totalAppreciationReceived;
        totalYield = interestEarned + appreciationEarned;
        currentAPY = this.getCurrentAPY();
    }
    
    function setManagementFee(uint256 newFeeBps) external onlyOwner {
        require(newFeeBps <= 500, "Fee too high"); // Max 5%
        managementFeeBps = newFeeBps;
    }
    
    function emergencyPause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
}

