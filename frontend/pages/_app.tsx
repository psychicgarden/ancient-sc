import type { AppProps } from 'next/app';
import { WagmiConfig, createConfig } from 'wagmi';
import { createPublicClient, http } from 'viem';
import { base, baseSepolia } from 'wagmi/chains';
import { RainbowKitProvider, getDefaultWallets } from '@rainbow-me/rainbowkit';
import '@rainbow-me/rainbowkit/styles.css';
import '../styles/globals.css';

// Create wagmi config
const { connectors } = getDefaultWallets({
  appName: 'Ancient Lending',
  projectId: 'your-walletconnect-project-id', // Get from https://cloud.walletconnect.com
  chains: [base, baseSepolia],
});

const config = createConfig({
  autoConnect: true,
  connectors,
  publicClient: createPublicClient({
    chain: base,
    transport: http(),
  }),
});

export default function App({ Component, pageProps }: AppProps) {
  return (
    <WagmiConfig config={config}>
      <RainbowKitProvider chains={[base, baseSepolia]}>
        <div className="min-h-screen bg-gray-50">
          <Component {...pageProps} />
        </div>
      </RainbowKitProvider>
    </WagmiConfig>
  );
}
