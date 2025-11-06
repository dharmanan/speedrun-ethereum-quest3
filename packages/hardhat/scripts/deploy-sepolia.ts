import { ethers } from "hardhat";
import { Wallet } from "ethers";
import password from "@inquirer/password";
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
  const encryptedKey = process.env.DEPLOYER_PRIVATE_KEY_ENCRYPTED;

  if (!encryptedKey) {
    console.log("🚫️ You don't have a deployer account. Run `yarn generate` or `yarn account:import` first");
    return;
  }

  const pass = await password({ message: "Enter password to decrypt private key:" });

  try {
    const wallet = await Wallet.fromEncryptedJson(encryptedKey, pass);

    // Create a provider and signer
    const provider = ethers.provider;
    const signer = new ethers.Wallet(wallet.privateKey, provider);

    console.log("Deploying YourToken...");

    const YourToken = await ethers.getContractFactory("YourToken", signer);
    const yourToken = await YourToken.deploy();

    await yourToken.waitForDeployment();
    const tokenAddress = await yourToken.getAddress();

    console.log("YourToken deployed to:", tokenAddress);

    console.log("Deploying Vendor...");

    const Vendor = await ethers.getContractFactory("Vendor", signer);
    const vendor = await Vendor.deploy(tokenAddress);

    await vendor.waitForDeployment();
    const vendorAddress = await vendor.getAddress();

    console.log("Vendor deployed to:", vendorAddress);

    // Transfer tokens to vendor
    const tokensToTransfer = ethers.parseEther("1000");
    await yourToken.transfer(vendorAddress, tokensToTransfer);
    console.log("Transferred 1000 tokens to vendor");

    console.log("Deployment completed!");
    console.log("Token Address:", tokenAddress);
    console.log("Vendor Address:", vendorAddress);
    console.log("Sepolia Etherscan URLs:");
    console.log("Token:", `https://sepolia.etherscan.io/address/${tokenAddress}`);
    console.log("Vendor:", `https://sepolia.etherscan.io/address/${vendorAddress}`);

  } catch (e) {
    console.error("Failed to decrypt private key or deploy:", e);
    process.exit(1);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});