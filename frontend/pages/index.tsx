import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useContractRead, useContractWrite, useWaitForTransaction } from 'wagmi';
import { parseEther, formatEther, parseUnits } from 'viem';
import { useState, useEffect } from 'react';
import { CONTRACTS, MORTGAGE_ABI, STAKING_POOL_ABI, USDT_ABI } from '../contracts';

export default function Home() {
  const { address, isConnected } = useAccount();
  const [propertyPrice, setPropertyPrice] = useState('150000');
  const [depositAmount, setDepositAmount] = useState('1000');
  const [selectedTokenId, setSelectedTokenId] = useState('1');

  // Contract addresses (update after deployment)
  const mortgageAddress = CONTRACTS.mortgage as `0x${string}`;
  const stakingPoolAddress = CONTRACTS.stakingPool as `0x${string}`;
  const usdtAddress = CONTRACTS.usdt as `0x${string}`;

  // Read USDT balance
  const { data: usdtBalance } = useContractRead({
    address: usdtAddress,
    abi: USDT_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    enabled: !!address,
  });

  // Read USDT allowance for mortgage
  const { data: mortgageAllowance } = useContractRead({
    address: usdtAddress,
    abi: USDT_ABI,
    functionName: 'allowance',
    args: address && mortgageAddress !== '0x0000000000000000000000000000000000000000' 
      ? [address, mortgageAddress] 
      : undefined,
    enabled: !!address && mortgageAddress !== '0x0000000000000000000000000000000000000000',
  });

  // Read mortgage details
  const { data: mortgageDetails } = useContractRead({
    address: mortgageAddress,
    abi: MORTGAGE_ABI,
    functionName: 'getMortgage',
    args: [BigInt(selectedTokenId)],
    enabled: !!selectedTokenId && mortgageAddress !== '0x0000000000000000000000000000000000000000',
  });

  // Read staking pool metrics
  const { data: poolMetrics } = useContractRead({
    address: stakingPoolAddress,
    abi: STAKING_POOL_ABI,
    functionName: 'getPoolMetrics',
    enabled: stakingPoolAddress !== '0x0000000000000000000000000000000000000000',
  });

  // Approve USDT for mortgage
  const { write: approveMortgage, data: approveMortgageData } = useContractWrite({
    address: usdtAddress,
    abi: USDT_ABI,
    functionName: 'approve',
  });

  // Purchase property
  const { write: purchaseProperty, data: purchaseData } = useContractWrite({
    address: mortgageAddress,
    abi: MORTGAGE_ABI,
    functionName: 'purchaseProperty',
  });

  // Make payment
  const { write: makePayment, data: paymentData } = useContractWrite({
    address: mortgageAddress,
    abi: MORTGAGE_ABI,
    functionName: 'makePayment',
  });

  // Deposit to staking pool
  const { write: depositToPool, data: depositData } = useContractWrite({
    address: stakingPoolAddress,
    abi: STAKING_POOL_ABI,
    functionName: 'deposit',
  });

  // Wait for transactions
  useWaitForTransaction({ hash: approveMortgageData?.hash });
  useWaitForTransaction({ hash: purchaseData?.hash });
  useWaitForTransaction({ hash: paymentData?.hash });
  useWaitForTransaction({ hash: depositData?.hash });

  const handlePurchaseProperty = async () => {
    if (!address || !propertyPrice) return;
    
    const price = parseUnits(propertyPrice, 6); // USDT has 6 decimals
    const downPayment = (price * 20n) / 100n; // 20% down
    const platformFee = (price * 3n) / 100n; // 3% platform fee
    const totalNeeded = downPayment + platformFee;
    
    // Check if we need to approve first
    if (!mortgageAllowance || mortgageAllowance < totalNeeded) {
      await approveMortgage({
        args: [mortgageAddress, totalNeeded],
      });
      return;
    }
    
    await purchaseProperty({
      args: [price],
    });
  };

  const handleMakePayment = async () => {
    if (!selectedTokenId) return;
    
    await makePayment({
      args: [BigInt(selectedTokenId)],
    });
  };

  const handleDepositToPool = async () => {
    if (!address || !depositAmount) return;
    
    const amount = parseUnits(depositAmount, 6); // USDT has 6 decimals
    
    // Check allowance first
    const { data: poolAllowance } = await useContractRead({
      address: usdtAddress,
      abi: USDT_ABI,
      functionName: 'allowance',
      args: [address, stakingPoolAddress],
    });
    
    if (!poolAllowance || poolAllowance < amount) {
      await approveMortgage({
        args: [stakingPoolAddress, amount],
      });
      return;
    }
    
    await depositToPool({
      args: [amount],
    });
  };

  if (!isConnected) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-md mx-auto bg-white rounded-lg shadow-md p-6 text-center">
          <h1 className="text-2xl font-bold mb-4">Ancient Lending</h1>
          <p className="text-gray-600 mb-6">
            Connect your wallet to start using Ancient Lending
          </p>
          <ConnectButton />
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Ancient Lending</h1>
        <ConnectButton />
      </div>

      {/* Contract Status */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Contract Status</h2>
          <div className="space-y-2">
            <div className="flex justify-between">
              <span>Mortgage Contract:</span>
              <span className={mortgageAddress !== '0x0000000000000000000000000000000000000000' ? 'text-green-600' : 'text-red-600'}>
                {mortgageAddress !== '0x0000000000000000000000000000000000000000' ? 'Deployed' : 'Not Deployed'}
              </span>
            </div>
            <div className="flex justify-between">
              <span>Staking Pool:</span>
              <span className={stakingPoolAddress !== '0x0000000000000000000000000000000000000000' ? 'text-green-600' : 'text-red-600'}>
                {stakingPoolAddress !== '0x0000000000000000000000000000000000000000' ? 'Deployed' : 'Not Deployed'}
              </span>
            </div>
            <div className="flex justify-between">
              <span>Your USDT Balance:</span>
              <span>{usdtBalance ? formatEther(usdtBalance) : '0'} USDT</span>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Staking Pool Metrics</h2>
          {poolMetrics ? (
            <div className="space-y-2">
              <div className="flex justify-between">
                <span>Total Assets:</span>
                <span>${formatEther(poolMetrics[0])} USDT</span>
              </div>
              <div className="flex justify-between">
                <span>Total Shares:</span>
                <span>{formatEther(poolMetrics[1])}</span>
              </div>
              <div className="flex justify-between">
                <span>Exchange Rate:</span>
                <span>{formatEther(poolMetrics[2])} USDT/share</span>
              </div>
              <div className="flex justify-between">
                <span>Total Interest:</span>
                <span>${formatEther(poolMetrics[3])} USDT</span>
              </div>
            </div>
          ) : (
            <p className="text-gray-500">Loading pool metrics...</p>
          )}
        </div>
      </div>

      {/* Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {/* Purchase Property */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Purchase Property</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Property Price (USDT)</label>
              <input
                type="number"
                value={propertyPrice}
                onChange={(e) => setPropertyPrice(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="150000"
              />
            </div>
            <div className="text-sm text-gray-600">
              <p>Down Payment (20%): ${(parseFloat(propertyPrice) * 0.2).toLocaleString()}</p>
              <p>Platform Fee (3%): ${(parseFloat(propertyPrice) * 0.03).toLocaleString()}</p>
              <p>Total Needed: ${(parseFloat(propertyPrice) * 0.23).toLocaleString()}</p>
            </div>
            <button
              onClick={handlePurchaseProperty}
              disabled={mortgageAddress === '0x0000000000000000000000000000000000000000'}
              className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 disabled:bg-gray-400"
            >
              Purchase Property
            </button>
          </div>
        </div>

        {/* Make Payment */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Make Mortgage Payment</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Token ID</label>
              <input
                type="number"
                value={selectedTokenId}
                onChange={(e) => setSelectedTokenId(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="1"
              />
            </div>
            {mortgageDetails && (
              <div className="text-sm text-gray-600 space-y-1">
                <p>Borrower: {mortgageDetails[0]}</p>
                <p>Property Price: ${formatEther(mortgageDetails[1])} USDT</p>
                <p>Monthly Payment: ${formatEther(mortgageDetails[3])} USDT</p>
                <p>Payments Made: {mortgageDetails[4].toString()}/120</p>
                <p>Remaining: {mortgageDetails[5].toString()}</p>
              </div>
            )}
            <button
              onClick={handleMakePayment}
              disabled={mortgageAddress === '0x0000000000000000000000000000000000000000'}
              className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 disabled:bg-gray-400"
            >
              Make Payment
            </button>
          </div>
        </div>

        {/* Deposit to Pool */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Deposit to Staking Pool</h2>
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-2">Amount (USDT)</label>
              <input
                type="number"
                value={depositAmount}
                onChange={(e) => setDepositAmount(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="1000"
              />
            </div>
            <div className="text-sm text-gray-600">
              <p>Minimum Deposit: 100 USDT</p>
              <p>Management Fee: 2%</p>
            </div>
            <button
              onClick={handleDepositToPool}
              disabled={stakingPoolAddress === '0x0000000000000000000000000000000000000000'}
              className="w-full bg-purple-600 text-white py-2 px-4 rounded-md hover:bg-purple-700 disabled:bg-gray-400"
            >
              Deposit to Pool
            </button>
          </div>
        </div>

        {/* Contract Addresses */}
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-xl font-semibold mb-4">Contract Addresses</h2>
          <div className="space-y-2 text-sm">
            <div>
              <span className="font-medium">Mortgage:</span>
              <p className="font-mono text-xs break-all">{mortgageAddress}</p>
            </div>
            <div>
              <span className="font-medium">Staking Pool:</span>
              <p className="font-mono text-xs break-all">{stakingPoolAddress}</p>
            </div>
            <div>
              <span className="font-medium">USDT:</span>
              <p className="font-mono text-xs break-all">{usdtAddress}</p>
            </div>
          </div>
          <div className="mt-4 p-3 bg-yellow-50 rounded-md">
            <p className="text-sm text-yellow-800">
              <strong>Note:</strong> Update contract addresses in contracts.ts after deployment
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
