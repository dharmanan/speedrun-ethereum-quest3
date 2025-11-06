# 🚩 SpeedRun Ethereum - Token Vendor Challenge 🏵

A complete implementation of the SpeedRun Ethereum Token Vendor challenge. I built a decentralized ERC20 token vending machine with buy/sell functionality, deployed on Sepolia testnet with a fully functional Next.js frontend.

## 🎯 Challenge Overview

The challenge requires creating a decentralized vending machine that allows users to buy and sell ERC20 tokens using ETH. This teaches:
- ERC20 token implementation with OpenZeppelin
- Contract-to-contract interactions
- The "approve" pattern for token transfers
- Payable functions and ETH handling
- Smart contract security with Ownable pattern
- Frontend integration with Web3 wallets

## 📋 What I Built

### 🏗 Smart Contracts

#### YourToken.sol
- **ERC20 Token**: Inherits OpenZeppelin's ERC20 standard
- **Initial Supply**: Mints 1000 tokens (with 18 decimals) to deployer
- **Standard Functions**: transfer, approve, transferFrom, balanceOf, etc.

#### Vendor.sol
- **Token Vending Machine**: Buys and sells YourToken using ETH
- **Exchange Rate**: 100 tokens per ETH
- **Functions**:
  - `buyTokens()`: Payable function to purchase tokens with ETH
  - `sellTokens(uint256 amount)`: Sell tokens back for ETH (requires approval)
  - `withdraw()`: Owner can withdraw accumulated ETH
- **Events**: BuyTokens and SellTokens for transaction tracking
- **Security**: Ownable pattern for access control

### 🎨 Frontend (Next.js + TypeScript)

- **Framework**: Next.js 15 with TypeScript
- **Web3 Integration**: Wagmi + Viem for Ethereum interactions
- **Wallet Connection**: RainbowKit for multiple wallet support
- **UI Components**: Responsive design with Tailwind CSS
- **Pages**:
  - **Token Vendor**: Buy/sell interface with real-time balance display
  - **Events**: Transaction history with BuyTokens/SellTokens events
  - **Debug Contracts**: Direct contract interaction for testing

## 🚀 Deployment & Verification

### Testnet Deployment
- **Network**: Sepolia Testnet
- **Token Contract**: [0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD](https://sepolia.etherscan.io/address/0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD#code)
- **Vendor Contract**: [0x56A19Af53EE3550b2C0D84c6076e5EA8A975CB83](https://sepolia.etherscan.io/address/0x56A19Af53EE3550b2C0D84c6076e5EA8A975CB83#code)

### Frontend Deployment
- **Platform**: Vercel
- **URL**: https://nextjs-oy876mvfo-kohens-projects.vercel.app
- **Network**: Connected to Sepolia testnet

## 🛠 Step-by-Step Implementation

### 1. Environment Setup

```bash
# Clone the challenge repository
git clone https://github.com/scaffold-eth/se-2-challenges.git
cd se-2-challenges/challenge-token-vendor

# Install dependencies
npm install
```

### 2. Smart Contract Development

#### YourToken.sol Implementation
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract YourToken is ERC20 {
    constructor() ERC20("YourToken", "YTK") {
        _mint(msg.sender, 1000 * 10**18); // Mint 1000 tokens
    }
}
```

#### Vendor.sol Implementation
```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
    uint256 public constant tokensPerEth = 100;

    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    YourToken public yourToken;

    constructor(address tokenAddress) Ownable(msg.sender) {
        yourToken = YourToken(tokenAddress);
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy tokens");

        uint256 tokensToBuy = msg.value * tokensPerEth;
        require(yourToken.balanceOf(address(this)) >= tokensToBuy, "Vendor has insufficient tokens");

        bool sent = yourToken.transfer(msg.sender, tokensToBuy);
        require(sent, "Failed to transfer tokens");

        emit BuyTokens(msg.sender, msg.value, tokensToBuy);
    }

    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(yourToken.balanceOf(msg.sender) >= amount, "Insufficient token balance");

        uint256 ethToSend = amount / tokensPerEth;
        require(address(this).balance >= ethToSend, "Vendor has insufficient ETH");

        bool success = yourToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        (bool sent,) = msg.sender.call{value: ethToSend}("");
        require(sent, "Failed to send ETH");

        emit SellTokens(msg.sender, amount, ethToSend);
    }

    function withdraw() public onlyOwner {
        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH");
    }

    receive() external payable {}
}
```

### 3. Local Testing

```bash
# Start local Hardhat network
npm run chain

# Deploy contracts locally
npm run deploy

# Run tests
npm run test

# Start frontend
npm run dev
```

### 4. Testnet Deployment

```bash
# Generate deployer account
npm run account:generate

# Fund the account with Sepolia ETH from a faucet
# (e.g., https://sepoliafaucet.com or https://faucet.quicknode.com/ethereum/sepolia)

# Deploy to Sepolia
npx hardhat run scripts/deploy-sepolia.ts --network sepolia
```

### 5. Contract Verification

```bash
# Verify Vendor contract
npx hardhat verify --network sepolia 0x56A19Af53EE3550b2C0D84c6076e5EA8A975CB83 "0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD"

# Verify Token contract
npx hardhat verify --network sepolia 0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD
```

### 6. Frontend Configuration

Update `packages/nextjs/contracts/externalContracts.ts` with deployed contract addresses:

```typescript
const externalContracts = {
  11155111: { // Sepolia chain ID
    YourToken: {
      address: "0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD",
      abi: [/* YourToken ABI */]
    },
    Vendor: {
      address: "0x56A19Af53EE3550b2C0D84c6076e5EA8A975CB83",
      abi: [/* Vendor ABI */]
    }
  }
} as const;
```

Update `packages/nextjs/scaffold.config.ts`:
```typescript
const scaffoldConfig = {
  targetNetworks: [chains.sepolia], // Change from chains.hardhat
  // ... other config
};
```

### 7. Frontend Deployment

```bash
# Install Vercel CLI
npm install -g vercel

# Login to Vercel
vercel login

# Deploy to production
cd packages/nextjs
vercel --prod
```

## 🧪 Testing

Run the complete test suite:

```bash
cd packages/hardhat
npm run test
```

**Test Results:**
- ✅ Deploy YourToken contract
- ✅ Deploy Vendor contract
- ✅ Buy tokens functionality
- ✅ Sell tokens functionality
- ✅ Owner withdrawal functionality

## 📊 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │  Vendor.sol     │    │  YourToken.sol  │
│  (Next.js)      │◄──►│                 │◄──►│                 │
│                 │    │ • buyTokens()   │    │ • ERC20 Token   │
│ • Buy/Sell UI   │    │ • sellTokens()  │    │ • Transfer      │
│ • Wallet Connect│    │ • withdraw()    │    │ • Approve       │
│ • Event History │    │ • Events        │    │ • Balance       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                        Sepolia Testnet
```

## 🔐 Security Features

- **Ownable Pattern**: Only contract owner can withdraw ETH
- **Input Validation**: Require statements for all user inputs
- **Reentrancy Protection**: Careful ETH transfers
- **Access Control**: Owner-only functions
- **Balance Checks**: Prevent insufficient balance errors

## 🎨 User Experience

1. **Connect Wallet**: Users connect their Web3 wallet (MetaMask, etc.)
2. **Buy Tokens**: Enter ETH amount, see token preview, confirm transaction
3. **Sell Tokens**: Approve token spending, enter token amount, receive ETH
4. **View Events**: See transaction history in real-time
5. **Debug Tools**: Direct contract interaction for advanced users

## 📈 Key Features

- **Real-time Balance Updates**: Automatic UI updates after transactions
- **Gas Estimation**: Transaction cost previews
- **Event Streaming**: Live transaction history
- **Multi-wallet Support**: Works with all Web3 wallets
- **Responsive Design**: Mobile-friendly interface
- **Error Handling**: User-friendly error messages

## 🏆 Challenge Completion

This implementation successfully completes all SpeedRun Ethereum Token Vendor requirements:

- ✅ ERC20 token with fixed supply
- ✅ Payable buyTokens() function
- ✅ Token selling with approval pattern
- ✅ Owner withdrawal functionality
- ✅ Frontend with buy/sell interface
- ✅ Testnet deployment and verification
- ✅ Public web deployment
- ✅ Source code verification

## 🔗 Links

- **Live Demo**: https://nextjs-oy876mvfo-kohens-projects.vercel.app
- **Vendor Contract**: https://sepolia.etherscan.io/address/0x56A19Af53EE3550b2C0D84c6076e5EA8A975CB83#code
- **Token Contract**: https://sepolia.etherscan.io/address/0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD#code
- **GitHub**: https://github.com/dharmanan/speedrun-ethereum-quest3
- **SpeedRun Ethereum**: https://speedrunethereum.com

## 🚀 How to Use This Repository

1. **Fork this repository**
2. **Follow the step-by-step guide above**
3. **Customize the contracts and frontend as needed**
4. **Deploy to your preferred testnet**
5. **Submit your solution to SpeedRun Ethereum**

## 📚 Learnings

This challenge taught me:
- Smart contract development with Solidity
- ERC20 token standards and interactions
- DeFi concepts (token exchanges, approvals)
- Frontend Web3 integration
- Testnet deployment and verification
- Decentralized application architecture

## 📄 License

This project is part of the SpeedRun Ethereum challenges and follows their licensing terms.

## 🔗 Links

- **Live Demo**: https://nextjs-oy876mvfo-kohens-projects.vercel.app
- **Vendor Contract**: https://sepolia.etherscan.io/address/0x56A19Af53EE3550b2C0D84c6076e5EA8A975CB83#code
- **Token Contract**: https://sepolia.etherscan.io/address/0x1f06AB392aD2733F3c1Ece8cCC92fd2188F414CD#code
- **GitHub**: https://github.com/dharmanan/speedrun-ethereum-quest3
- **SpeedRun Ethereum**: https://speedrunethereum.com

## � How to Use This Repository

1. **Fork this repository**
2. **Follow the step-by-step guide above**
3. **Customize the contracts and frontend as needed**
4. **Deploy to your preferred testnet**
5. **Submit your solution to SpeedRun Ethereum**

## 📚 Learnings

This challenge teaches:
- Smart contract development with Solidity
- ERC20 token standards and interactions
- DeFi concepts (token exchanges, approvals)
- Frontend Web3 integration
- Testnet deployment and verification
- Decentralized application architecture

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## � License

This project is part of the SpeedRun Ethereum challenges and follows their licensing terms.

## 📚 Learnings

This challenge teaches:
- Smart contract development with Solidity
- ERC20 token standards and interactions
- DeFi concepts (token exchanges, approvals)
- Frontend Web3 integration
- Testnet deployment and verification
- Decentralized application architecture

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is part of the SpeedRun Ethereum challenges and follows their licensing terms.