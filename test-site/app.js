// Ancient Lending - Test Site JavaScript
// This simulates smart contract interactions for testing

// Mock data for properties
const properties = [
    {
        id: 1,
        name: "Modern Miami Penthouse",
        location: "Miami, FL",
        type: "Penthouse",
        price: 450000,
        image: "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800",
        futureValue: 495000,
        beds: 3,
        baths: 2,
        sqft: 2500
    },
    {
        id: 2,
        name: "Beverly Hills Villa",
        location: "Los Angeles, CA",
        type: "Villa",
        price: 850000,
        image: "https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800",
        futureValue: 935000,
        beds: 5,
        baths: 4,
        sqft: 4200
    },
    {
        id: 3,
        name: "Manhattan Loft",
        location: "New York, NY",
        type: "Loft",
        price: 625000,
        image: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800",
        futureValue: 687500,
        beds: 2,
        baths: 2,
        sqft: 1800
    },
    {
        id: 4,
        name: "Austin Modern Home",
        location: "Austin, TX",
        type: "Single Family",
        price: 380000,
        image: "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800",
        futureValue: 418000,
        beds: 4,
        baths: 3,
        sqft: 2800
    },
    {
        id: 5,
        name: "Malibu Beach House",
        location: "Los Angeles, CA",
        type: "Beach House",
        price: 1200000,
        image: "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800",
        futureValue: 1320000,
        beds: 4,
        baths: 3,
        sqft: 3500
    },
    {
        id: 6,
        name: "South Beach Condo",
        location: "Miami, FL",
        type: "Condo",
        price: 325000,
        image: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800",
        futureValue: 357500,
        beds: 2,
        baths: 2,
        sqft: 1500
    }
];

// Mock user data
let userData = {
    connected: false,
    address: null,
    usdtBalance: 0,
    properties: [],
    stakingBalance: 0,
    stakingEarnings: 0
};

// Initialize the app
window.onload = function() {
    renderProperties();
    updateUI();
};

// Connect wallet (mock)
async function connectWallet() {
    try {
        // Simulate wallet connection
        userData.connected = true;
        userData.address = '0x' + Math.random().toString(16).substr(2, 40);
        userData.usdtBalance = 1000000; // $1M USDT for testing
        
        document.getElementById('connectWallet').classList.add('hidden');
        document.getElementById('disconnectWallet').classList.remove('hidden');
        document.getElementById('walletInfo').classList.remove('hidden');
        
        updateUI();
        showNotification('Wallet connected successfully!', 'success');
    } catch (error) {
        showNotification('Failed to connect wallet', 'error');
    }
}

// Disconnect wallet
function disconnectWallet() {
    userData = {
        connected: false,
        address: null,
        usdtBalance: 0,
        properties: [],
        stakingBalance: 0,
        stakingEarnings: 0
    };
    
    document.getElementById('connectWallet').classList.remove('hidden');
    document.getElementById('disconnectWallet').classList.add('hidden');
    document.getElementById('walletInfo').classList.add('hidden');
    
    updateUI();
    showNotification('Wallet disconnected', 'info');
}

// Update UI with current data
function updateUI() {
    // Update balance
    document.getElementById('usdtBalance').textContent = formatMoney(userData.usdtBalance);
    
    // Update staking info
    document.getElementById('yourStake').textContent = formatMoney(userData.stakingBalance);
    document.getElementById('yourEarnings').textContent = formatMoney(userData.stakingEarnings);
    
    // Update my properties
    renderMyProperties();
}

// Render property grid
function renderProperties() {
    const grid = document.getElementById('propertyGrid');
    grid.innerHTML = '';
    
    properties.forEach(property => {
        const card = createPropertyCard(property);
        grid.appendChild(card);
    });
}

// Create property card
function createPropertyCard(property) {
    const div = document.createElement('div');
    div.className = 'property-card bg-white rounded-lg shadow-lg overflow-hidden cursor-pointer';
    div.onclick = () => showPropertyModal(property);
    
    const downPayment = property.price * 0.20;
    const platformFee = property.price * 0.03;
    const monthlyPayment = calculateMonthlyPayment(property.price * 0.80);
    
    div.innerHTML = `
        <img src="${property.image}" alt="${property.name}" class="w-full h-48 object-cover">
        <div class="p-6">
            <div class="flex justify-between items-start mb-2">
                <h3 class="text-xl font-bold text-gray-900">${property.name}</h3>
                <span class="badge badge-success">Available</span>
            </div>
            <p class="text-gray-600 mb-4">📍 ${property.location}</p>
            
            <div class="grid grid-cols-3 gap-2 mb-4 text-sm text-gray-600">
                <div>🛏 ${property.beds} beds</div>
                <div>🚿 ${property.baths} baths</div>
                <div>📏 ${property.sqft.toLocaleString()} sqft</div>
            </div>
            
            <div class="border-t pt-4">
                <div class="flex justify-between items-center mb-2">
                    <span class="text-gray-600">Price</span>
                    <span class="text-2xl font-bold text-purple-600">${formatMoney(property.price)}</span>
                </div>
                <div class="flex justify-between items-center mb-2">
                    <span class="text-sm text-gray-600">Down Payment</span>
                    <span class="text-sm font-semibold">${formatMoney(downPayment)}</span>
                </div>
                <div class="flex justify-between items-center mb-4">
                    <span class="text-sm text-gray-600">Monthly Payment</span>
                    <span class="text-sm font-semibold">${formatMoney(monthlyPayment)}/mo</span>
                </div>
                <button class="w-full btn-primary text-white py-2 rounded-lg font-semibold">
                    View Details
                </button>
            </div>
        </div>
    `;
    
    return div;
}

// Show property modal
function showPropertyModal(property) {
    const downPayment = property.price * 0.20;
    const platformFee = property.price * 0.03;
    const loanAmount = property.price * 0.80;
    const totalDue = downPayment + platformFee;
    const monthlyPayment = calculateMonthlyPayment(loanAmount);
    const totalPayments = monthlyPayment * 120;
    const totalInterest = totalPayments - loanAmount;
    
    document.getElementById('modalTitle').textContent = property.name;
    document.getElementById('modalImage').src = property.image;
    document.getElementById('modalLocation').textContent = property.location;
    document.getElementById('modalType').textContent = property.type;
    document.getElementById('modalPrice').textContent = formatMoney(property.price);
    document.getElementById('modalFutureValue').textContent = formatMoney(property.futureValue);
    document.getElementById('modalDownPayment').textContent = formatMoney(downPayment);
    document.getElementById('modalPlatformFee').textContent = formatMoney(platformFee);
    document.getElementById('modalLoanAmount').textContent = formatMoney(loanAmount);
    document.getElementById('modalTotalDue').textContent = formatMoney(totalDue);
    document.getElementById('modalMonthlyPayment').textContent = formatMoney(monthlyPayment);
    document.getElementById('modalTotalInterest').textContent = formatMoney(totalInterest);
    
    // Store current property
    window.currentProperty = property;
    
    document.getElementById('propertyModal').classList.add('active');
}

// Close modal
function closeModal() {
    document.getElementById('propertyModal').classList.remove('active');
}

// Purchase property
function purchaseProperty() {
    console.log('Purchase button clicked');
    console.log('Connected:', userData.connected);
    
    if (!userData.connected) {
        showNotification('Please connect your wallet first', 'warning');
        closeModal();
        // Scroll to top and highlight connect button
        window.scrollTo(0, 0);
        const connectBtn = document.getElementById('connectWallet');
        connectBtn.classList.add('animate-pulse');
        setTimeout(() => connectBtn.classList.remove('animate-pulse'), 2000);
        return;
    }
    
    const property = window.currentProperty;
    const downPayment = property.price * 0.20;
    const platformFee = property.price * 0.03;
    const totalDue = downPayment + platformFee;
    
    console.log('Property:', property.name);
    console.log('Total due:', totalDue);
    console.log('Balance:', userData.usdtBalance);
    
    if (userData.usdtBalance < totalDue) {
        showNotification('Insufficient USDT balance', 'error');
        return;
    }
    
    // Simulate purchase
    showNotification('Processing purchase...', 'info');
    
    setTimeout(() => {
        userData.usdtBalance -= totalDue;
        userData.properties.push({
            ...property,
            purchaseDate: new Date(),
            paymentsMade: 0,
            nextPaymentDue: new Date(Date.now() - 1), // Make payment immediately available for testing
            monthlyPayment: calculateMonthlyPayment(property.price * 0.80),
            loanAmount: property.price * 0.80
        });
        
        updateUI();
        closeModal();
        showNotification(`Successfully purchased ${property.name}!`, 'success');
        
        // Auto-switch to my properties after purchase
        setTimeout(() => {
            showSection('my-properties');
        }, 1000);
    }, 2000);
}

// Render my properties
function renderMyProperties() {
    const grid = document.getElementById('myPropertiesGrid');
    
    if (!userData.connected) {
        grid.innerHTML = `
            <div class="text-center py-12 col-span-2">
                <p class="text-gray-500">Connect your wallet to see your properties</p>
            </div>
        `;
        return;
    }
    
    if (userData.properties.length === 0) {
        grid.innerHTML = `
            <div class="text-center py-12 col-span-2">
                <p class="text-gray-500 mb-4">You don't own any properties yet</p>
                <button onclick="showSection('marketplace')" class="btn-primary text-white px-6 py-3 rounded-lg font-semibold">
                    Browse Marketplace
                </button>
            </div>
        `;
        return;
    }
    
    grid.innerHTML = '';
    userData.properties.forEach((property, index) => {
        const card = createMyPropertyCard(property, index);
        grid.appendChild(card);
    });
}

// Create my property card
function createMyPropertyCard(property, index) {
    const div = document.createElement('div');
    div.className = 'bg-white rounded-lg shadow-lg overflow-hidden';
    
    const paymentsRemaining = 120 - property.paymentsMade;
    const progress = (property.paymentsMade / 120) * 100;
    const daysUntilPayment = Math.ceil((property.nextPaymentDue - new Date()) / (24 * 60 * 60 * 1000));
    
    div.innerHTML = `
        <img src="${property.image}" alt="${property.name}" class="w-full h-48 object-cover">
        <div class="p-6">
            <div class="flex justify-between items-start mb-4">
                <h3 class="text-xl font-bold text-gray-900">${property.name}</h3>
                <span class="badge badge-info">${property.paymentsMade}/120</span>
            </div>
            
            <div class="mb-4">
                <div class="flex justify-between text-sm text-gray-600 mb-2">
                    <span>Progress</span>
                    <span>${progress.toFixed(1)}%</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill" style="width: ${progress}%"></div>
                </div>
            </div>
            
            <div class="space-y-2 mb-4">
                <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Monthly Payment</span>
                    <span class="font-semibold">${formatMoney(property.monthlyPayment)}</span>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Payments Made</span>
                    <span class="font-semibold">${property.paymentsMade} / 120</span>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Remaining Balance</span>
                    <span class="font-semibold">${formatMoney((property.loanAmount * paymentsRemaining) / 120)}</span>
                </div>
                <div class="flex justify-between text-sm">
                    <span class="text-gray-600">Next Payment Due</span>
                    <span class="font-semibold ${daysUntilPayment <= 7 ? 'text-red-600' : ''}">${daysUntilPayment} days</span>
                </div>
            </div>
            
            <button onclick="makePayment(${index})" class="w-full bg-green-600 text-white py-2 rounded-lg font-semibold hover:bg-green-700">
                Make Payment Now
            </button>
        </div>
    `;
    
    return div;
}

// Make mortgage payment
function makePayment(propertyIndex) {
    console.log('Making payment for property', propertyIndex);
    
    const property = userData.properties[propertyIndex];
    
    if (userData.usdtBalance < property.monthlyPayment) {
        showNotification('Insufficient USDT balance', 'error');
        return;
    }
    
    // Simulate payment
    showNotification('Processing payment...', 'info');
    
    setTimeout(() => {
        userData.usdtBalance -= property.monthlyPayment;
        property.paymentsMade++;
        property.nextPaymentDue = new Date(Date.now() - 1); // Always allow next payment for testing
        
        // If mortgage paid off
        if (property.paymentsMade === 120) {
            showNotification(`🎉 Congratulations! You've fully paid off ${property.name}!`, 'success');
        } else {
            showNotification(`Payment successful! ${120 - property.paymentsMade} payments remaining`, 'success');
        }
        
        updateUI();
    }, 1500);
}

// Handle staking
async function handleStaking() {
    if (!userData.connected) {
        showNotification('Please connect your wallet first', 'warning');
        return;
    }
    
    const amount = parseFloat(document.getElementById('stakingAmount').value);
    
    if (!amount || amount < 100) {
        showNotification('Minimum deposit is 100 USDT', 'warning');
        return;
    }
    
    if (amount > userData.usdtBalance) {
        showNotification('Insufficient USDT balance', 'error');
        return;
    }
    
    // Simulate staking
    showNotification('Processing deposit...', 'info');
    
    setTimeout(() => {
        userData.usdtBalance -= amount;
        userData.stakingBalance += amount;
        
        document.getElementById('stakingAmount').value = '';
        updateUI();
        showNotification(`Successfully deposited ${formatMoney(amount)} to staking pool!`, 'success');
    }, 1500);
}

// Set staking mode
function setStakingMode(mode) {
    if (mode === 'deposit') {
        document.getElementById('depositBtn').classList.add('bg-purple-600', 'text-white');
        document.getElementById('depositBtn').classList.remove('bg-gray-200', 'text-gray-700');
        document.getElementById('withdrawBtn').classList.remove('bg-purple-600', 'text-white');
        document.getElementById('withdrawBtn').classList.add('bg-gray-200', 'text-gray-700');
    } else {
        document.getElementById('withdrawBtn').classList.add('bg-purple-600', 'text-white');
        document.getElementById('withdrawBtn').classList.remove('bg-gray-200', 'text-gray-700');
        document.getElementById('depositBtn').classList.remove('bg-purple-600', 'text-white');
        document.getElementById('depositBtn').classList.add('bg-gray-200', 'text-gray-700');
    }
}

// Show section
function showSection(sectionName) {
    // Hide all sections
    document.querySelectorAll('.section').forEach(section => {
        section.classList.add('hidden');
    });
    
    // Show selected section
    document.getElementById(`${sectionName}-section`).classList.remove('hidden');
}

// Calculate monthly payment
function calculateMonthlyPayment(loanAmount) {
    // 8% APR, 120 months, simplified calculation
    return (loanAmount * 0.0121); // Approximation: 1.21% per month
}

// Format money
function formatMoney(amount) {
    return '$' + amount.toLocaleString('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    });
}

// Show notification
function showNotification(message, type) {
    const colors = {
        success: 'bg-green-500',
        error: 'bg-red-500',
        warning: 'bg-yellow-500',
        info: 'bg-blue-500'
    };
    
    const notification = document.createElement('div');
    notification.className = `fixed top-20 right-4 ${colors[type]} text-white px-6 py-4 rounded-lg shadow-lg z-50 animate-slide-in`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// Add animation
const style = document.createElement('style');
style.textContent = `
    @keyframes slide-in {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    .animate-slide-in {
        animation: slide-in 0.3s ease-out;
    }
`;
document.head.appendChild(style);
