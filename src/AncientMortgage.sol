// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

interface IStakingPool {
    function receiveInterest(uint256 amount) external;
    function receiveAppreciation(uint256 amount) external;
}

/**
 * @title AncientMortgage
 * @dev Simplified mortgage contract with correct business logic
 *
 * Business Model:
 * - 20% down payment required
 * - 8% APR on remaining 80%
 * - 10 year term (120 monthly payments)
 * - Property NFT held as collateral
 * - Year 10: Appreciation split - 40% treasury, 10% stakers, 50% stays with property
 */
contract AncientMortgage is ERC721, Ownable, ReentrancyGuard, Pausable {
    // Constants
    uint256 public constant SECONDS_PER_MONTH = 30 days;
    uint256 public constant DOWN_PAYMENT_BPS = 2000; // 20%
    uint256 public constant INTEREST_RATE_BPS = 800; // 8% APR
    uint256 public constant TERM_MONTHS = 120; // 10 years
    uint256 public constant PLATFORM_FEE_BPS = 300; // 3%

    // Core addresses
    IERC20 public immutable usdt;
    address public immutable treasury;
    address public stakingPool;

    uint256 private _nextTokenId = 1;

    struct Mortgage {
        address borrower;
        uint256 propertyPrice;
        uint256 loanAmount; // 80% of property price
        uint256 monthlyPayment;
        uint256 paymentsMade;
        uint256 nextPaymentDue;
        uint256 totalInterestPaid;
        bool isActive;
        bool year10Completed;
    }

    struct Appraisal {
        uint256 appraisedValue;
        uint256 appreciation;
        uint256 treasuryShare; // 40%
        uint256 stakerShare; // 10%
        bool distributed;
    }

    mapping(uint256 => Mortgage) public mortgages;
    mapping(uint256 => Appraisal) public appraisals;

    event MortgageCreated(
        uint256 indexed tokenId,
        address indexed borrower,
        uint256 propertyPrice,
        uint256 loanAmount,
        uint256 monthlyPayment
    );
    event PaymentMade(
        uint256 indexed tokenId,
        uint256 paymentNumber,
        uint256 interestPaid,
        uint256 principalPaid
    );
    event MortgageCompleted(uint256 indexed tokenId);
    event AppraiseProperty(
        uint256 indexed tokenId,
        uint256 appraisedValue,
        uint256 appreciation
    );
    event AppreciationDistributed(
        uint256 indexed tokenId,
        uint256 treasuryShare,
        uint256 stakerShare
    );

    constructor(
        address _usdt,
        address _treasury
    ) ERC721("Ancient Property", "APROPERTY") Ownable(msg.sender) {
        require(_usdt != address(0), "Invalid USDT");
        require(_treasury != address(0), "Invalid treasury");
        usdt = IERC20(_usdt);
        treasury = _treasury;
    }

    function setStakingPool(address _stakingPool) external onlyOwner {
        require(_stakingPool != address(0), "Invalid staking pool");
        stakingPool = _stakingPool;
    }

    /**
     * @dev Purchase property with 20% down payment
     */
    function purchaseProperty(
        uint256 propertyPrice
    ) external nonReentrant whenNotPaused returns (uint256) {
        require(propertyPrice > 0, "Invalid price");

        // Calculate amounts
        uint256 downPayment = (propertyPrice * DOWN_PAYMENT_BPS) / 10000; // 20%
        uint256 loanAmount = propertyPrice - downPayment; // 80%
        uint256 platformFee = (propertyPrice * PLATFORM_FEE_BPS) / 10000; // 3%

        // Calculate monthly payment: loan * (rate/12) * (1+rate/12)^120 / ((1+rate/12)^120 - 1)
        // Simplified: For 8% over 120 months ≈ 1.21% of loan amount per month
        uint256 monthlyPayment = (loanAmount * 121) / 10000; // Approximation: 1.21% per month

        // Transfer down payment + platform fee
        require(
            usdt.transferFrom(msg.sender, address(this), downPayment),
            "Down payment failed"
        );
        require(
            usdt.transferFrom(msg.sender, treasury, platformFee),
            "Platform fee failed"
        );

        // Mint property NFT to contract (held as collateral)
        uint256 tokenId = _nextTokenId++;
        _mint(address(this), tokenId);

        // Create mortgage
        mortgages[tokenId] = Mortgage({
            borrower: msg.sender,
            propertyPrice: propertyPrice,
            loanAmount: loanAmount,
            monthlyPayment: monthlyPayment,
            paymentsMade: 0,
            nextPaymentDue: block.timestamp + SECONDS_PER_MONTH,
            totalInterestPaid: 0,
            isActive: true,
            year10Completed: false
        });

        emit MortgageCreated(
            tokenId,
            msg.sender,
            propertyPrice,
            loanAmount,
            monthlyPayment
        );

        return tokenId;
    }

    /**
     * @dev Make monthly mortgage payment
     */
    function makePayment(uint256 tokenId) external nonReentrant whenNotPaused {
        Mortgage storage m = mortgages[tokenId];
        require(m.borrower == msg.sender, "Not borrower");
        require(m.isActive, "Not active");
        require(m.paymentsMade < TERM_MONTHS, "Completed");

        // Transfer payment
        require(
            usdt.transferFrom(msg.sender, address(this), m.monthlyPayment),
            "Payment failed"
        );

        // Calculate interest vs principal
        uint256 remainingBalance = m.loanAmount -
            ((m.loanAmount * m.paymentsMade) / TERM_MONTHS);
        uint256 interestPortion = (remainingBalance * INTEREST_RATE_BPS) /
            (10000 * 12); // Monthly interest
        uint256 principalPortion = m.monthlyPayment - interestPortion;

        // Send interest to staking pool
        if (stakingPool != address(0) && interestPortion > 0) {
            require(
                usdt.transfer(stakingPool, interestPortion),
                "Interest transfer failed"
            );
            IStakingPool(stakingPool).receiveInterest(interestPortion);
        }

        m.paymentsMade++;
        m.totalInterestPaid += interestPortion;
        m.nextPaymentDue = block.timestamp + SECONDS_PER_MONTH;

        emit PaymentMade(
            tokenId,
            m.paymentsMade,
            interestPortion,
            principalPortion
        );

        // Complete mortgage after 120 payments
        if (m.paymentsMade == TERM_MONTHS) {
            _completeMortgage(tokenId);
        }
    }

    /**
     * @dev Complete mortgage and transfer NFT to borrower
     */
    function _completeMortgage(uint256 tokenId) internal {
        Mortgage storage m = mortgages[tokenId];

        // Transfer property NFT to borrower
        _transfer(address(this), m.borrower, tokenId);

        emit MortgageCompleted(tokenId);
    }

    /**
     * @dev Appraise property at year 10
     */
    function appraiseProperty(
        uint256 tokenId,
        uint256 appraisedValue
    ) external onlyOwner {
        Mortgage storage m = mortgages[tokenId];
        require(m.paymentsMade == TERM_MONTHS, "Not completed");
        require(!m.year10Completed, "Already appraised");
        require(appraisedValue >= m.propertyPrice, "Value decreased");

        uint256 appreciation = appraisedValue - m.propertyPrice;

        // Calculate splits: 40% treasury, 10% stakers (50% stays with property)
        uint256 treasuryShare = (appreciation * 4000) / 10000;
        uint256 stakerShare = (appreciation * 1000) / 10000;

        appraisals[tokenId] = Appraisal({
            appraisedValue: appraisedValue,
            appreciation: appreciation,
            treasuryShare: treasuryShare,
            stakerShare: stakerShare,
            distributed: false
        });

        m.year10Completed = true;

        emit AppraiseProperty(tokenId, appraisedValue, appreciation);
    }

    /**
     * @dev Distribute appreciation to parties
     */
    function distributeAppreciation(
        uint256 tokenId
    ) external onlyOwner nonReentrant {
        Mortgage storage m = mortgages[tokenId];
        Appraisal storage a = appraisals[tokenId];

        require(m.year10Completed, "Not appraised");
        require(!a.distributed, "Already distributed");
        require(a.appreciation > 0, "No appreciation");

        // Distribute shares: 40% treasury, 10% stakers (50% stays with property)
        require(
            usdt.transfer(treasury, a.treasuryShare),
            "Treasury transfer failed"
        );

        if (stakingPool != address(0)) {
            require(
                usdt.transfer(stakingPool, a.stakerShare),
                "Staker transfer failed"
            );
            IStakingPool(stakingPool).receiveAppreciation(a.stakerShare);
        }

        a.distributed = true;

        emit AppreciationDistributed(tokenId, a.treasuryShare, a.stakerShare);
    }

    // View functions
    function getMortgage(
        uint256 tokenId
    )
        external
        view
        returns (
            address borrower,
            uint256 propertyPrice,
            uint256 loanAmount,
            uint256 monthlyPayment,
            uint256 paymentsMade,
            uint256 paymentsRemaining,
            uint256 totalInterestPaid,
            bool isActive
        )
    {
        Mortgage storage m = mortgages[tokenId];
        return (
            m.borrower,
            m.propertyPrice,
            m.loanAmount,
            m.monthlyPayment,
            m.paymentsMade,
            TERM_MONTHS - m.paymentsMade,
            m.totalInterestPaid,
            m.isActive
        );
    }

    function getAppraisal(
        uint256 tokenId
    )
        external
        view
        returns (
            uint256 appraisedValue,
            uint256 appreciation,
            uint256 treasuryShare,
            uint256 stakerShare,
            bool distributed
        )
    {
        Appraisal storage a = appraisals[tokenId];
        return (
            a.appraisedValue,
            a.appreciation,
            a.treasuryShare,
            a.stakerShare,
            a.distributed
        );
    }

    function emergencyPause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
