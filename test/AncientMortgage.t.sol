// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/AncientMortgage.sol";
import "../src/AncientStakingPool.sol";

contract MockUSDT {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
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

contract AncientMortgageTest is Test {
    AncientMortgage public mortgage;
    AncientStakingPool public pool;
    MockUSDT public usdt;
    
    address public treasury = address(0x1);
    address public buyer = address(0x2);
    address public staker = address(0x3);
    
    uint256 public constant PROPERTY_PRICE = 150_000 * 1e6; // $150k (USDT has 6 decimals)
    
    function setUp() public {
        usdt = new MockUSDT();
        mortgage = new AncientMortgage(address(usdt), treasury);
        pool = new AncientStakingPool(address(usdt), treasury);
        
        mortgage.setStakingPool(address(pool));
        pool.setMortgageContract(address(mortgage));
        
        // Mint USDT to buyer and staker
        usdt.mint(buyer, 10_000_000 * 1e6); // $10M
        usdt.mint(staker, 1_000_000 * 1e6); // $1M
        
        // Approve spending
        vm.prank(buyer);
        usdt.approve(address(mortgage), type(uint256).max);
        
        vm.prank(staker);
        usdt.approve(address(pool), type(uint256).max);
    }
    
    function testPurchaseProperty() public {
        vm.prank(buyer);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        
        assertEq(tokenId, 1);
        assertEq(mortgage.ownerOf(tokenId), address(mortgage)); // NFT held as collateral
        
        (
            address borrower,
            uint256 propertyPrice,
            uint256 loanAmount,
            uint256 monthlyPayment,
            ,
            uint256 paymentsRemaining,
            ,
            bool isActive
        ) = mortgage.getMortgage(tokenId);
        
        assertEq(borrower, buyer);
        assertEq(propertyPrice, PROPERTY_PRICE);
        assertEq(loanAmount, PROPERTY_PRICE * 80 / 100); // 80% loan
        assertGt(monthlyPayment, 0);
        assertEq(paymentsRemaining, 120);
        assertTrue(isActive);
    }
    
    function testMakePayments() public {
        vm.prank(buyer);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        
        (, , , uint256 monthlyPayment, , , , ) = mortgage.getMortgage(tokenId);
        
        // Make first payment
        vm.prank(buyer);
        mortgage.makePayment(tokenId);
        
        (, , , , uint256 paymentsMade, uint256 paymentsRemaining, , ) = mortgage.getMortgage(tokenId);
        assertEq(paymentsMade, 1);
        assertEq(paymentsRemaining, 119);
    }
    
    function testCompleteFullMortgage() public {
        vm.prank(buyer);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        
        // Make all 120 payments
        for (uint256 i = 0; i < 120; i++) {
            vm.warp(block.timestamp + 30 days);
            vm.prank(buyer);
            mortgage.makePayment(tokenId);
        }
        
        // NFT should now be owned by buyer
        assertEq(mortgage.ownerOf(tokenId), buyer);
        
        (, , , , uint256 paymentsMade, uint256 paymentsRemaining, , ) = mortgage.getMortgage(tokenId);
        assertEq(paymentsMade, 120);
        assertEq(paymentsRemaining, 0);
    }
    
    function testAppraiseAndDistribute() public {
        vm.prank(buyer);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        
        // Complete mortgage
        for (uint256 i = 0; i < 120; i++) {
            vm.warp(block.timestamp + 30 days);
            vm.prank(buyer);
            mortgage.makePayment(tokenId);
        }
        
        // Appraise at $165k (10% appreciation)
        uint256 appraisedValue = 165_000 * 1e6;
        mortgage.appraiseProperty(tokenId, appraisedValue);
        
        (
            uint256 appraised,
            uint256 appreciation,
            uint256 treasuryShare,
            uint256 stakerShare,
            bool distributed
        ) = mortgage.getAppraisal(tokenId);
        
        assertEq(appraised, appraisedValue);
        assertEq(appreciation, 15_000 * 1e6); // $15k appreciation
        assertEq(treasuryShare, 6_000 * 1e6); // 40% = $6k
        assertEq(stakerShare, 1_500 * 1e6); // 10% = $1.5k
        assertFalse(distributed);
        
        // Fund the contract with ONLY the distributed amount (40% + 10% = 50% of appreciation)
        // The other 50% stays with the property/SPV
        uint256 distributionAmount = treasuryShare + stakerShare; // $7.5k total
        usdt.mint(address(mortgage), distributionAmount);
        
        // Distribute appreciation
        uint256 treasuryBalanceBefore = usdt.balanceOf(treasury);
        uint256 poolBalanceBefore = usdt.balanceOf(address(pool));
        
        mortgage.distributeAppreciation(tokenId);
        
        // Treasury gets 40% of appreciation ($6k) PLUS 2% management fee on the staker's 10% share ($30k)
        // Total treasury increase = $6,000k + $30k = $6,030k
        uint256 expectedTreasuryIncrease = treasuryShare + ((stakerShare * 200) / 10000); // 40% + 2% of 10%
        assertEq(usdt.balanceOf(treasury), treasuryBalanceBefore + expectedTreasuryIncrease);
        
        // Pool gets 10% of appreciation minus 2% management fee
        uint256 expectedPoolIncrease = stakerShare - ((stakerShare * 200) / 10000);
        assertEq(usdt.balanceOf(address(pool)), poolBalanceBefore + expectedPoolIncrease);
    }
    
    function testStakingPoolIntegration() public {
        // Staker deposits
        vm.prank(staker);
        uint256 shares = pool.deposit(120_000 * 1e6); // Deposit $120k (loan amount)
        assertGt(shares, 0);
        
        // Buyer purchases property
        vm.prank(buyer);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        
        uint256 poolBalanceBefore = usdt.balanceOf(address(pool));
        
        // Make first payment (interest goes to pool)
        vm.warp(block.timestamp + 30 days);
        vm.prank(buyer);
        mortgage.makePayment(tokenId);
        
        // Pool should have received interest
        assertGt(usdt.balanceOf(address(pool)), poolBalanceBefore);
        assertGt(pool.totalInterestReceived(), 0);
    }
    
    function testCalculateExpectedReturns() public {
        // Loan: $120,000 (80% of $150k)
        // Interest Rate: 8% APR
        // Term: 120 months
        
        vm.prank(buyer);
        uint256 tokenId = mortgage.purchaseProperty(PROPERTY_PRICE);
        
        (, , uint256 loanAmount, uint256 monthlyPayment, , , , ) = mortgage.getMortgage(tokenId);
        
        // Total payments over 10 years
        uint256 totalPayments = monthlyPayment * 120;
        
        // Total interest = total payments - loan amount
        uint256 expectedTotalInterest = totalPayments - loanAmount;
        
        console.log("Loan Amount:", loanAmount / 1e6);
        console.log("Monthly Payment:", monthlyPayment / 1e6);
        console.log("Total Payments:", totalPayments / 1e6);
        console.log("Total Interest:", expectedTotalInterest / 1e6);
        
        // Expected: ~$54,712 in interest
        // This is approximately 45.6% of loan amount
        assertGt(expectedTotalInterest, 50_000 * 1e6); // At least $50k
        assertLt(expectedTotalInterest, 60_000 * 1e6); // Less than $60k
    }
}

