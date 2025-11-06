# SpeedRun Ethereum Token Vendor Challenge - Implementation

## ✅ Completed Tasks

### 1. YourToken.sol - ERC20 Token Contract
- ✅ Inherits from OpenZeppelin ERC20
- ✅ Mints 1000 tokens to msg.sender in constructor
- ✅ Ready for deployment

**Contract Code:**
```solidity
contract YourToken is ERC20 {
    constructor() ERC20("Gold", "GLD") {
        _mint(msg.sender, 1000 * 10 ** 18);
    }
}
```

### 2. Vendor.sol - Token Vending Machine
- ✅ Inherits from Ownable
- ✅ `buyTokens()` - Payable function to purchase tokens at 100 tokens per ETH
- ✅ `sellTokens(uint256 amount)` - Sell tokens back to vendor
- ✅ `withdraw()` - Owner can withdraw ETH
- ✅ Events: BuyTokens and SellTokens emitted

**Key Features:**
- tokensPerEth = 100 (constant)
- Checks vendor has enough tokens before selling
- Uses transferFrom for secure token transfers
- Emits events for all transactions

### 3. Deploy Script (01_deploy_vendor.ts)
- ✅ Deploys Vendor contract with YourToken address
- ✅ Transfers 1000 tokens from deployer to Vendor
- ✅ Transfers ownership to deployer address

### 4. Frontend (token-vendor/page.tsx)
- ✅ Buy Tokens UI uncommented
- ✅ Sell Tokens UI uncommented with approve functionality
- ✅ Vendor balance displays uncommented
- ✅ Events page shows both BuyTokens and SellTokens

### 5. Events Page (events/page.tsx)
- ✅ BuyTokens events table enabled
- ✅ SellTokens events table enabled

## Deployment Steps

### Local Testing:
```bash
# Terminal 1: Start blockchain
yarn chain

# Terminal 2: Deploy contracts
yarn deploy

# Terminal 3: Start frontend
yarn start
```

### Production Deployment:
```bash
# Generate deployer account
yarn generate

# Check balance
yarn account

# Faucet: Get testnet ETH from https://faucet.sepolia.dev

# Deploy to Sepolia
yarn deploy --network sepolia

# Update frontend config to sepolia
# In scaffold.config.ts: targetNetwork: chains.sepolia

# Deploy frontend to Vercel
yarn vercel
```

## Contract Addresses (After Deployment)
- Will be displayed in deployment output
- Frontend automatically reads from deployments

## Features Implemented
✅ ERC20 token creation with fixed supply
✅ Token buying with ETH
✅ Token selling back to vendor
✅ Owner withdrawal mechanism
✅ Event logging for all transactions
✅ Responsive frontend UI
✅ Real-time balance displays

## Next Steps
1. Deploy YourToken and Vendor to testnet (Sepolia)
2. Verify contracts on Etherscan
3. Deploy frontend to Vercel
4. Share public URL at SpeedRunEthereum.com
