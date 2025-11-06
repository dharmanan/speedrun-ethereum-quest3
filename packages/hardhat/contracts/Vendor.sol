pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading
// SPDX-License-Identifier: MIT

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

    // Payable function to buy tokens
    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        
        uint256 tokensToBuy = msg.value * tokensPerEth;
        
        require(
            yourToken.balanceOf(address(this)) >= tokensToBuy,
            "Vendor does not have enough tokens"
        );
        
        bool sent = yourToken.transfer(msg.sender, tokensToBuy);
        require(sent, "Failed to transfer tokens");
        
        emit BuyTokens(msg.sender, msg.value, tokensToBuy);
    }

    // Sell tokens back to the vendor
    function sellTokens(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        
        require(
            yourToken.balanceOf(msg.sender) >= amount,
            "You do not have enough tokens to sell"
        );
        
        uint256 ethToSend = amount / tokensPerEth;
        
        require(
            address(this).balance >= ethToSend,
            "Vendor does not have enough ETH"
        );
        
        bool success = yourToken.transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
        
        (bool sent, ) = msg.sender.call{value: ethToSend}("");
        require(sent, "Failed to send ETH");
        
        emit SellTokens(msg.sender, amount, ethToSend);
    }

    // Withdraw ETH - only owner can call
    function withdraw() public onlyOwner {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send ETH");
    }

    // Receive ETH directly
    receive() external payable {}
}
