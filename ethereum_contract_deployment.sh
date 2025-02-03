#!/usr/bin/env bash

# Ethereum Token Contract Generator & Deployment
# This script walks the user through creating and deploying an ERC-20 or ERC-721 contract

###############################################################################
# Prompt User for Token Details
###############################################################################
echo "Welcome to the Ethereum Token Generator!"
read -p "Do you want to create an ERC-20 token or ERC-721 NFT? (20/721): " TOKEN_TYPE
read -p "Enter the token name: " TOKEN_NAME
read -p "Enter the token symbol: " TOKEN_SYMBOL

if [[ "$TOKEN_TYPE" == "20" ]]; then
    read -p "Enter the initial supply: " INITIAL_SUPPLY
    read -p "Enter the number of decimals (default 18): " DECIMALS
    DECIMALS=${DECIMALS:-18}
elif [[ "$TOKEN_TYPE" == "721" ]]; then
    read -p "Enter the base URI for metadata (e.g., https://yourapi.com/metadata/): " BASE_URI
fi

read -p "Enter the Solidity filename to save (e.g., MyToken.sol): " FILE_NAME

###############################################################################
# Generate Solidity Contract
###############################################################################
mkdir -p generated_contracts
FILE_PATH="generated_contracts/$FILE_NAME"

if [[ "$TOKEN_TYPE" == "20" ]]; then
    cat <<EOL > "$FILE_PATH"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract $TOKEN_NAME is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("$TOKEN_NAME", "$TOKEN_SYMBOL") {
        _mint(msg.sender, initialSupply * (10 ** decimals()));
    }
}
EOL

elif [[ "$TOKEN_TYPE" == "721" ]]; then
    cat <<EOL > "$FILE_PATH"
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract $TOKEN_NAME is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    constructor() ERC721("$TOKEN_NAME", "$TOKEN_SYMBOL") {}

    function mintToken(address to, string memory tokenURI) public onlyOwner {
        _tokenIdCounter++;
        _safeMint(to, _tokenIdCounter);
        _setTokenURI(_tokenIdCounter, tokenURI);
    }
}
EOL

fi

###############################################################################
# Deploying the Smart Contract
###############################################################################
echo "Now, let's deploy your contract to Ethereum!"
echo "We will use Hardhat for deployment."

# Ask user for network & credentials
read -p "Enter your Infura/Alchemy RPC URL (e.g., https://mainnet.infura.io/v3/YOUR_API_KEY): " RPC_URL
read -p "Enter your Ethereum Private Key (DO NOT SHARE THIS!): " PRIVATE_KEY
read -p "Enter the Solidity contract filename (e.g., MyToken.sol): " CONTRACT_FILE

# Create Hardhat Project
echo "Setting up Hardhat environment..."
mkdir -p hardhat_project
cd hardhat_project || exit

# Initialize Node.js project
npm init -y > /dev/null

# Install Hardhat & dependencies
npm install --save-dev hardhat @openzeppelin/contracts dotenv ethers hardhat-ethers

# Create Hardhat project
npx hardhat init --force > /dev/null

# Create .env file for deployment
cat <<EOL > .env
RPC_URL=$RPC_URL
PRIVATE_KEY=$PRIVATE_KEY
EOL

# Create Hardhat config file
cat <<EOL > hardhat.config.js
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  networks: {
    custom: {
      url: process.env.RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  solidity: "0.8.19",
};
EOL

# Move the contract to Hardhat project
mkdir -p contracts
mv "../generated_contracts/$CONTRACT_FILE" contracts/

# Create Hardhat deployment script
cat <<EOL > scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
    const Token = await ethers.getContractFactory("$TOKEN_NAME");
    const token = await Token.deploy($([[ "$TOKEN_TYPE" == "20" ]] && echo "$INITIAL_SUPPLY" || echo ""));
    await token.deployed();
    console.log("Contract deployed to:", token.address);
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
EOL

# Deploy contract using Hardhat
echo "Deploying contract to Ethereum..."
npx hardhat run scripts/deploy.js --network custom

echo "Your contract has been deployed!"
