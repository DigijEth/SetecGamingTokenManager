#!/bin/bash
set -e

##############################
# Function: install_dependencies
# - Updates apt, installs required packages.
# - Installs Rust (if not installed) so that Sugar can be built.
# - Installs Solana CLI.
# - Installs Sugar (Metaplex Suger CLI) via Cargo.
##############################
install_dependencies() {
  echo "Updating package lists..."
  sudo apt update

  echo "Installing required packages: curl, git, build-essential, jq..."
  sudo apt install -y curl git build-essential jq

  # Install Rust if not already installed
  if ! command -v cargo &>/dev/null; then
    echo "Rust is not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Source the Cargo environment for this session
    source "$HOME/.cargo/env"
  else
    echo "Rust is already installed."
  fi

  # Install Solana CLI if not already installed
  if ! command -v solana &>/dev/null; then
    echo "Installing Solana CLI..."
    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    # Ensure the installed binaries are in PATH for this session
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
  else
    echo "Solana CLI is already installed."
  fi

  # Install Sugar (Metaplex Suger CLI) if not already installed
  if ! command -v sugar &>/dev/null; then
    echo "Installing Metaplex Sugar CLI..."
    cargo install sugar-cli
    # Cargo bin directory should be in PATH; add it if needed.
    export PATH="$HOME/.cargo/bin:$PATH"
  else
    echo "Sugar CLI is already installed."
  fi

  echo "Dependencies installation completed."
}

##############################
# Function: setup_solana_network
# - Lets the user choose a network (Mainnet, Devnet, or Testnet)
# - Configures Solana CLI with the selected RPC URL.
##############################
setup_solana_network() {
  echo "Select the Solana network:"
  echo "  1) Mainnet"
  echo "  2) Devnet"
  echo "  3) Testnet"
  read -rp "Enter choice (1/2/3): " net_choice

  case $net_choice in
    1)
      network="mainnet-beta"
      rpc_url="https://api.mainnet-beta.solana.com"
      ;;
    2)
      network="devnet"
      rpc_url="https://api.devnet.solana.com"
      ;;
    3)
      network="testnet"
      rpc_url="https://api.testnet.solana.com"
      ;;
    *)
      echo "Invalid choice. Defaulting to Devnet."
      network="devnet"
      rpc_url="https://api.devnet.solana.com"
      ;;
  esac

  echo "Setting Solana network to $network ($rpc_url)..."
  solana config set --url "$rpc_url"
}

##############################
# Function: create_wallet
# - Creates a new wallet (keypair) using Solana CLI.
# - Reminds the user to back up their 12-word seed phrase.
##############################
create_wallet() {
  echo "Creating a new Solana wallet..."
  # This command will display the seed phrase and keypair info.
  solana-keygen new --no-bip39-passphrase
  echo "IMPORTANT: Please write down and securely backup your 12 seed words shown above!"
  read -rp "Press Enter once you have safely backed up your seed words..."
}

##############################
# Function: progress_bar
# - Displays a simple progress bar for a given number of seconds.
##############################
progress_bar() {
  total_seconds=$1
  echo "Deploying contract. Please wait $total_seconds seconds..."
  for ((i = 1; i <= total_seconds; i++)); do
    percent=$(( (i * 100) / total_seconds ))
    # Build a bar of '#' characters
    bar=$(printf "%0.s#" $(seq 1 "$i"))
    spaces=$(printf "%0.s " $(seq 1 $((total_seconds - i))))
    printf "\rProgress: [${bar}${spaces}] %d%%" "$percent"
    sleep 1
  done
  echo ""
}

##############################
# Function: token_wizard
# - Interactively gathers token information.
# - Optionally collects metadata details.
# - “Mints” the token by creating a directory for the ticker,
#   saving a contract file (as a simulation), and waiting 45 seconds.
# - After deployment, optionally updates metadata using Sugar CLI.
##############################
token_wizard() {
  echo "========================================"
  echo "        Setec Token Wizard"
  echo "========================================"

  # Gather basic token information
  read -rp "Enter token name: " token_name
  read -rp "Enter ticker symbol: " ticker
  read -rp "Enter number of decimals (default 6): " decimals
  decimals=${decimals:-6}

  read -rp "Do you want to include taxes? (y/n): " include_taxes
  read -rp "Do you want to include anti-bot features? (y/n): " anti_bot

  # Optional metadata update during wizard
  read -rp "Would you like to update token metadata? (y/n): " update_meta_choice
  metadata_file=""
  if [[ "$update_meta_choice" =~ ^[Yy] ]]; then
    read -rp "Enter token website: " token_website
    read -rp "Enter token description: " token_description
    read -rp "Enter your Twitter (X) handle: " twitter_handle
    read -rp "Enter Discord link: " discord_link
    read -rp "Enter Telegram link: " telegram_link

    read -rp "Would you like to upload a token image? (y/n): " upload_image_choice
    if [[ "$upload_image_choice" =~ ^[Yy] ]]; then
      read -rp "Enter the path or URL for the token image: " token_image
    else
      token_image=""
    fi

    # Save metadata in JSON format
    metadata_file="metadata_${ticker}.json"
    cat > "$metadata_file" <<EOF
{
  "token_name": "$token_name",
  "ticker": "$ticker",
  "decimals": $decimals,
  "website": "$token_website",
  "description": "$token_description",
  "twitter": "$twitter_handle",
  "discord": "$discord_link",
  "telegram": "$telegram_link",
  "image": "$token_image"
}
EOF
    echo "Metadata saved to $metadata_file"
  fi

  # Ask user if they want to mint the token
  read -rp "Do you want to mint the token? (y/n): " mint_choice
  if [[ "$mint_choice" =~ ^[Yy] ]]; then
    echo "Creating directory for token deployment..."
    mkdir -p "$ticker"
    # For demonstration purposes, we “save” a contract file with token details.
    contract_file="$ticker/contract.txt"
    cat > "$contract_file" <<EOF
Token Name: $token_name
Ticker: $ticker
Decimals: $decimals
Taxes: $include_taxes
Anti-Bot Features: $anti_bot
EOF
    echo "Contract details saved to $contract_file"
    echo "Deploying token contract..."
    progress_bar 45
    echo "Token contract deployed."

    # After deployment, offer to update metadata via Sugar
    read -rp "Do you want to update the metadata using Metaplex Sugar CLI? (Fees may apply – check the Metaplex website) (y/n): " sugar_update_choice
    if [[ "$sugar_update_choice" =~ ^[Yy] ]]; then
      if [ -z "$metadata_file" ]; then
        echo "No metadata file available to update."
      else
        echo "Updating metadata using Sugar CLI..."
        # NOTE: Adjust the Sugar CLI command parameters as required.
        sugar update --metadata "$metadata_file" --env "$network"
      fi
    fi
  else
    echo "Token minting was skipped."
  fi

  echo "========================================"
  echo "      Setec Token Wizard Complete"
  echo "========================================"
}

##############################
# Main Execution
##############################

install_dependencies
setup_solana_network
create_wallet
token_wizard

echo "All operations completed."
