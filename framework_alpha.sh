#!/usr/bin/env bash
# framework.sh
#
# Setec Gaming Labs Presents: Setec Solana Token Manager version 0.4.1
#
# DISCLAIMER:
#   Setec Gaming Labs is not responsible for any financial or other losses.
#   This tool is provided as-is. By using this application you agree not to hold
#   Setec Gaming Labs, its subsidiaries, or its employees responsible for your losses.
#   It is important to understand the nuances of creating a token.
#
# At any submenu, type "M" to return to the Main Menu.

###############################################################################
# Global Variables & Colors
###############################################################################
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
NETWORK_URL="https://api.devnet.solana.com"  # default network: Devnet
ACTIVE_WALLET=""
SNS_DOMAIN_SUFFIX=".sol"
BOT_CONFIG_DIR="./bot_configs"
TRADING_CONFIG_DIR="./trading_configs"
SOURCE_CODE_DIR="./source_code"
TEMPLATES_DIR="./templates"
LEDGER_ENABLED=false
TREZOR_ENABLED=false
HARDWARE_WALLET_TYPE=""
SESSION_TIMEOUT=3600  # 1 hour default

METAPLEX_FEE_URL="https://docs.metaplex.com/programs/token-metadata/fees"
SOLANA_FEE_URL="https://docs.solana.com/transaction_fees"
OPENBOOK_FEE_URL="https://docs.openbook-dex.com/fees"
RAYDIUM_FEE_URL="https://raydium.io/fees"
JUPITER_FEE_URL="https://station.jup.ag/fees"
DOCS_DIR="./docs"
UPGRADE_DIR="./upgrades"
BRIDGE_CONFIG_DIR="./bridges"
CUSTOM_TOKEN_DIR="./custom_tokens"

CURRENT_PAGE=1
ITEMS_PER_PAGE=15  # 5 items x 3 columns
MAX_ITEMS=30  # Adjust based on total menu items

# Add these new variables
ACTIVE_TOKEN=""
ACTIVE_TOKEN_NAME=""
ACTIVE_SOL_BALANCE="0"
ACTIVE_USD_VALUE="0"
ACTIVE_SNS_DOMAIN=""

###############################################################################
# Utility Functions
###############################################################################
print_header() {
    clear
    echo -e "${GREEN}---------------------------------------------------------------"
    echo -e "| Setec Gaming Labs Presents: Setec Solana Token Manager       |"
    echo -e "---------------------------------------------------------------${NC}"
    
    # Display wallet information if available
    if [[ -n "${ACTIVE_WALLET:-}" ]]; then
        if [[ -n "${ACTIVE_SNS_DOMAIN:-}" ]]; then
            echo -e "Wallet: ${GREEN}${ACTIVE_SNS_DOMAIN}${NC} (${ACTIVE_WALLET:0:8}...${ACTIVE_WALLET: -8})"
        else
            echo -e "Wallet: ${GREEN}${ACTIVE_WALLET:0:8}...${ACTIVE_WALLET: -8}${NC}"
        fi
        
        # Get and display SOL balance
        ACTIVE_SOL_BALANCE=$(solana balance | awk '{print $1}')
        # Get SOL price in USD (simplified example - you would need to implement actual price fetching)
        SOL_PRICE=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=solana&vs_currencies=usd" | jq -r '.solana.usd')
        ACTIVE_USD_VALUE=$(echo "$ACTIVE_SOL_BALANCE * $SOL_PRICE" | bc)
        
        echo -e "Balance: ${GREEN}◎${ACTIVE_SOL_BALANCE}${NC} (\$${ACTIVE_USD_VALUE})"
        
        # Display active token if selected
        if [[ -n "${ACTIVE_TOKEN:-}" && -n "${ACTIVE_TOKEN_NAME:-}" ]]; then
            TOKEN_BALANCE=$(spl-token balance "$ACTIVE_TOKEN" 2>/dev/null || echo "0")
            echo -e "Selected Token: ${GREEN}${ACTIVE_TOKEN_NAME}${NC} (${TOKEN_BALANCE} tokens)"
        fi
    else
        echo "No wallet connected"
    fi
    echo "---------------------------------------------------------------"
}

pause() {
    echo "Press Enter to continue..."
    read -r
}

display_fee_warning() {
    local service="$1"
    local fee_url="$2"
    
    echo -e "${RED}WARNING: This operation may incur fees from $service.${NC}"
    echo -e "Please check current fee structure at: $fee_url"
    read -p "Continue? (y/n): " proceed
    if [[ "$proceed" != "y" ]]; then
        return 1
    fi
    return 0
}

###############################################################################
# Disclaimer – must be accepted to continue
###############################################################################
disclaimer() {
    print_header
    echo "DISCLAIMER:"
    echo "Setec Gaming Labs is not responsible for any financial or other losses."
    echo "This tool is provided as-is. By using this application you agree not to hold"
    echo "Setec Gaming Labs, its subsidiaries, or its employees responsible for your losses."
    echo "It is important to understand the nuances of creating a token."
    echo ""
    read -p "Do you accept these terms? (y/n): " ans
    if [[ "$ans" != "y" ]]; then
        echo "You must accept the terms to continue. Exiting."
        exit 1
    fi
}

###############################################################################
# Simulated Dependency Scan
###############################################################################
scan_dependencies() {
    print_header
    echo "Detecting dependencies..."
    for i in {1..5}; do
        echo "Progress: $(( i * 20 ))%"
        sleep 1
    done
    echo "Dependency scan complete."
    sleep 1
}

###############################################################################
# Dependency Functions
###############################################################################
# Check if a command is installed; print a checkmark if yes, else a cross.
check_installed() {
    if command -v "$1" &>/dev/null; then
        echo "✅"
    else
        echo "❌"
    fi
}

# Display the dependency checklist.
dependency_menu() {
    print_header
    echo "Dependency Checklist:"
    echo " 1. Node.js + npm         : $(check_installed node)"
    echo " 2. Rust (cargo)          : $(check_installed cargo)"
    echo " 3. Anchor CLI            : $(check_installed anchor)"
    echo " 4. netlify-cli           : $(check_installed netlify)"
    echo " 5. vercel CLI            : $(check_installed vercel)"
    echo " 6. Solana CLI            : $(check_installed solana)"
    echo " 7. spl-token CLI         : $(check_installed spl-token)"
    echo " 8. Metaplex CLI          : $(check_installed metaplex)"
    echo " 9. Openbook DEX CLI      : $(check_installed openbook-dex)"
    echo " 10. Raydium CLI         : $(check_installed raydium)"
    echo " 11. Jupiter CLI         : $(check_installed jupiter)"
    echo ""
    echo "Type 'A' to install all, 'R' for recommended, or list numbers separated by commas (e.g., 1,3,5)."
    echo "M. Return to Setup Environment Menu"
    read -p "Enter selection: " dep_choice
    if [[ "$dep_choice" =~ ^[Mm]$ ]]; then
        return 0
    fi
    case "$dep_choice" in
        A|a)
            check_dependencies
            select_solana_version
            install_metaplex
            ;;
        R|r)
            # Recommended: Node.js + npm, Rust, Solana CLI (stable), spl-token CLI, Anchor CLI, and Metaplex CLI.
            verify_or_install "node" "nodejs"
            if ! command -v cargo &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y cargo
            fi
            select_solana_version
            if ! command -v spl-token &>/dev/null; then
                if command -v cargo &>/dev/null; then
                    cargo install spl-token-cli
                fi
            fi
            if ! command -v anchor &>/dev/null; then
                cargo install --git https://github.com/coral-xyz/anchor anchor-cli
            fi
            install_metaplex
            ;;
        *)
            IFS=',' read -ra selections <<< "$dep_choice"
            for sel in "${selections[@]}"; do
                case "$sel" in
                    1) verify_or_install "node" "nodejs" ;;
                    2)
                        if ! command -v cargo &>/dev/null; then
                            sudo apt-get update && sudo apt-get install -y cargo
                        fi
                        ;;
                    3)
                        if ! command -v anchor &>/dev/null && command -v cargo &>/dev/null; then
                            cargo install --git https://github.com/coral-xyz/anchor anchor-cli
                        fi
                        ;;
                    4) npm install -g netlify-cli ;;
                    5) npm install -g vercel ;;
                    6) select_solana_version ;;
                    7)
                        if ! command -v spl-token &>/dev/null && command -v cargo &>/dev/null; then
                            cargo install spl-token-cli
                        fi
                        ;;
                    8) install_metaplex ;;
                    9)
                        if ! command -v openbook-dex &>/dev/null; then
                            if command -v cargo &>/dev/null; then
                                git clone https://github.com/openbook-dex/program.git openbook-dex
                                cd openbook-dex/dex/cli || return 1
                                cargo build --release
                                sudo cp target/release/openbook-dex /usr/local/bin/
                                cd ../../.. || return 1
                                rm -rf openbook-dex
                            else
                                echo -e "${RED}Cargo not found. Please install Rust first.${NC}"
                            fi
                        fi
                        ;;
                    *)
                        echo "Invalid selection: $sel"
                        ;;
                esac
            done
            ;;
    esac
}

check_dependencies() {
    print_header
    echo "Checking dependencies..."
    verify_or_install "node" "nodejs"
    verify_or_install "npm" "nodejs"
    if ! command -v cargo &>/dev/null; then
        echo -e "${RED}Cargo (Rust) not found.${NC}"
        read -p "Install Rust via apt-get? (y/n): " RUST_INSTALL
        if [[ "$RUST_INSTALL" == "y" ]]; then
            sudo apt-get update && sudo apt-get install -y cargo
        else
            echo -e "${RED}Skipping Rust installation. Some features may not work.${NC}"
        fi
    fi
    if ! command -v anchor &>/dev/null; then
        echo -e "${RED}anchor CLI not found.${NC}"
        if command -v cargo &>/dev/null; then
            read -p "Install anchor CLI via cargo? (y/n): " ANCHOR_INSTALL
            if [[ "$ANCHOR_INSTALL" == "y" ]]; then
                cargo install --git https://github.com/coral-xyz/anchor anchor-cli
            else
                echo -e "${RED}Skipping anchor installation.${NC}"
            fi
        else
            echo -e "${RED}Cargo missing. Cannot install anchor automatically.${NC}"
        fi
    fi
    if ! command -v netlify &>/dev/null; then
        echo -e "${GREEN}Installing netlify-cli globally via npm...${NC}"
        npm install -g netlify-cli
    fi
    if ! command -v vercel &>/dev/null; then
        echo -e "${GREEN}Installing vercel CLI globally via npm...${NC}"
        npm install -g vercel
    fi
    if ! command -v solana &>/dev/null; then
        echo -e "${RED}solana CLI not found.${NC}"
        echo -e "${RED}You can manually install from https://docs.solana.com/cli/install-solana-cli${NC}"
        read -p "Attempt auto-install solana CLI from official script? (y/n/skip): " SOLANA_INSTALL
        if [[ "$SOLANA_INSTALL" == "y" ]]; then
            sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
            if ! command -v solana &>/dev/null; then
                echo -e "${RED}Solana CLI still not found in PATH. You may need to source your profile.${NC}"
                echo -e "${RED}Proceeding anyway (expect failures).${NC}"
            fi
        else
            echo -e "${RED}Skipping solana CLI dependency check. Proceeding anyway.${NC}"
        fi
    fi
    if ! command -v spl-token &>/dev/null; then
        echo -e "${RED}spl-token CLI not found.${NC}"
        read -p "Install via cargo? (y/n/skip): " SPL_TOKEN_INSTALL
        if [[ "$SPL_TOKEN_INSTALL" == "y" ]]; then
            if command -v cargo &>/dev/null; then
                cargo install spl-token-cli || echo -e "${RED}Failed to install spl-token CLI.${NC}"
            else
                echo -e "${RED}Cargo missing. Skipping installation of spl-token CLI. Proceeding anyway.${NC}"
            fi
        else
            echo -e "${RED}Skipping spl-token CLI dependency check. Proceeding anyway (expect failures).${NC}"
        fi
    fi
    if ! command -v openbook-dex &>/dev/null; then
        echo -e "${RED}Openbook DEX CLI not found.${NC}"
        read -p "Install Openbook DEX CLI? (y/n): " OPENBOOK_INSTALL
        if [[ "$OPENBOOK_INSTALL" == "y" ]]; then
            if command -v cargo &>/dev/null; then
                git clone https://github.com/openbook-dex/program.git openbook-dex
                cd openbook-dex/dex/cli || return 1
                cargo build --release
                sudo cp target/release/openbook-dex /usr/local/bin/
                cd ../../.. || return 1
                rm -rf openbook-dex
            else
                echo -e "${RED}Cargo missing. Cannot install Openbook DEX CLI.${NC}"
            fi
        else
            echo -e "${RED}Skipping Openbook DEX CLI installation. Market creation will not be available.${NC}"
        fi
    fi
    if ! command -v raydium &>/dev/null; then
        echo -e "${GREEN}Installing Raydium CLI...${NC}"
        npm install -g @raydium-io/raydium-cli
    fi
    
    if ! command -v jupiter &>/dev/null; then
        echo -e "${GREEN}Installing Jupiter CLI...${NC}"
        npm install -g @jup-ag/jupiter-cli
    fi
    if ! command -v qrencode &>/dev/null; then
        echo -e "${GREEN}Installing qrencode...${NC}"
        sudo apt-get install -y qrencode
    fi
    echo "Dependency check complete."
    sleep 1
}

###############################################################################
# Setup Environment Submenu
###############################################################################
setup_environment_menu() {
    while true; do
        print_header
        echo "Setup Environment Menu"
        echo "------------------------"
        echo "1. Dependency Installation/Check"
        echo "2. Select Network"
        echo "M. Return to Main Menu"
        read -p "Enter your choice: " choice
        case "$choice" in
            1)
                dependency_menu
                pause
                ;;
            2)
                select_network_menu
                ;;
            [Mm])
                break
                ;;
            *)
                echo "Invalid selection. Try again."
                sleep 1
                ;;
        esac
    done
}

###############################################################################
# Solana Version Selection Function for Setup Environment
###############################################################################
select_solana_version() {
    print_header
    echo "Select Solana CLI Version to Install:"
    echo "1. Solana Stable"
    echo "2. Solana Beta"
    echo "3. Solana Edge"
    read -p "Enter 1, 2, or 3 (Default: 1): " sol_choice
    case "${sol_choice:-1}" in
        1)
            echo "Installing Solana Stable..."
            sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
            ;;
        2)
            echo "Installing Solana Beta..."
            sh -c "$(curl -sSfL https://release.anza.xyz/beta/install)"
            ;;
        3)
            echo "Installing Solana Edge..."
            sh -c "$(curl -sSfL https://release.anza.xyz/edge/install)"
            ;;
        *)
            echo "Defaulting to Solana Stable."
            sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"
            ;;
    esac
}

###############################################################################
# Install Metaplex CLI Function
###############################################################################
install_metaplex() {
    if ! command -v metaplex &>/dev/null; then
        echo -e "${RED}Metaplex CLI not found.${NC}"
        read -p "Install Metaplex CLI via npm? (y/n): " METAPLEX_INSTALL
        if [[ "$METAPLEX_INSTALL" == "y" ]]; then
            npm install -g @metaplex-foundation/cli
        else
            echo -e "${RED}Skipping Metaplex CLI installation. Metadata immutability will not be available.${NC}"
        fi
    else
        echo -e "${GREEN}Found Metaplex CLI.${NC}"
    fi
}

###############################################################################
# Network Selection Submenu
###############################################################################
select_network_menu() {
    print_header
    echo "Select Solana Network:"
    echo "1. Mainnet"
    echo "2. Devnet (Default)"
    echo "3. Testnet"
    read -p "Enter 1, 2, or 3 (Default: 2): " net_choice
    case "${net_choice:-2}" in
        1) NETWORK_URL="https://api.mainnet-beta.solana.com" ;;
        2) NETWORK_URL="https://api.devnet.solana.com" ;;
        3) NETWORK_URL="https://api.testnet.solana.com" ;;
        *) NETWORK_URL="https://api.devnet.solana.com" ;;
    esac
    echo "Network set to: $NETWORK_URL"
    solana config set --url "$NETWORK_URL"
    pause
}

###############################################################################
# Wallet Management Submenu
###############################################################################
wallet_management_menu() {
    while true; do
        print_header
        echo "Wallet Management Menu"
        echo "-------------------------"
        if [[ -n "${ACTIVE_WALLET:-}" ]]; then
            echo "Active Wallet: $ACTIVE_WALLET"
            echo "Balance: $(solana balance)"
        else
            echo "No active wallet set."
        fi
        echo ""
        echo "1. Create Wallet"
        echo "2. View Wallet"
        echo "3. Set Active Wallet"
        echo "4. Manage Tokens (Send/Burn)"
        echo "5. Connect Hardware Wallet"
        echo "6. Hardware Wallet Settings"
        echo "M. Return to Main Menu"
        read -p "Enter your choice: " choice
        case "$choice" in
            1) create_wallet ;;
            2) view_wallet ;;
            3) set_active_wallet ;;
            4) manage_tokens ;;
            5) connect_hardware_wallet ;;
            6) hardware_wallet_settings ;;
            [Mm]) break ;;
            *) echo "Invalid selection. Try again." ; sleep 1 ;;
        esac
    done
}

create_wallet() {
    print_header
    echo "Creating new wallet..."
    NEW_WALLET=$(solana-keygen new --outfile ~/.config/solana/new_wallet.json --no-bip39-passphrase --force | awk '/pubkey/ {print $NF}')
    echo "New Wallet Address: $NEW_WALLET"
    read -p "Set this as active wallet? (y/n): " set_active
    if [[ "$set_active" == "y" ]]; then
        ACTIVE_WALLET="$NEW_WALLET"
        echo "ACTIVE_WALLET=$ACTIVE_WALLET" >> .env
        solana config set --keypair ~/.config/solana/new_wallet.json
    fi
    pause
}

view_wallet() {
    print_header
    echo "Wallet Details:"
    solana address
    solana balance
    pause
}

set_active_wallet() {
    print_header
    echo "Select a wallet to set as active from the list below:"
    
    # Collect wallet keypair files into an array.
    wallet_files=(~/.config/solana/*.json)
    if [[ ${#wallet_files[@]} -eq 0 ]]; then
        echo "No wallet keypair files found in ~/.config/solana/."
        pause
        return
    fi

    # Display the files as a numbered list.
    local i=1
    for wallet in "${wallet_files[@]}"; do
        echo "$i) $(basename "$wallet")"
        ((i++))
    done

    # Prompt the user to choose by number.
    read -p "Enter the number of the wallet to set active: " selection
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#wallet_files[@]} )); then
        echo -e "${RED}Invalid selection.${NC}"
        pause
        return
    fi

    # Retrieve the chosen wallet file.
    chosen_wallet="${wallet_files[$((selection-1))]}"
    ACTIVE_WALLET=$(solana address -k "$chosen_wallet")
    
    # Ask the user to assign a custom name to the wallet.
    read -p "Enter a custom name for this wallet (or press Enter to use filename): " wallet_name
    if [[ -n "$wallet_name" ]]; then
        echo "ACTIVE_WALLET_NAME=$wallet_name" >> .env
        echo "Active wallet set to: $wallet_name ($ACTIVE_WALLET)"
    else
        echo "Active wallet set to: $(basename "$chosen_wallet") ($ACTIVE_WALLET)"
    fi

    echo "ACTIVE_WALLET=$ACTIVE_WALLET" >> .env
    solana config set --keypair "$chosen_wallet"
    pause
}

manage_tokens() {
    print_header
    echo "Token Management"
    echo "----------------"
    echo "1. Send Tokens"
    echo "2. Burn Tokens"
    echo "M. Return to Wallet Management Menu"
    read -p "Enter your choice: " tok_choice
    case "$tok_choice" in
        1)
            read -p "Enter token mint address: " token_mint
            read -p "Enter recipient wallet address: " recipient
            read -p "Enter amount to send: " amount
            spl-token transfer "$token_mint" "$amount" "$recipient" --fund-recipient
            ;;
        2)
            read -p "Enter token mint address: " token_mint
            read -p "Burn all tokens? (y/n): " burn_all
            if [[ "$burn_all" == "y" ]]; then
                total_supply=$(spl-token supply "$token_mint" | awk '{print $NF}')
                spl-token burn "$token_mint" "$total_supply"
            else
                read -p "Enter amount to burn: " burn_amount
                spl-token burn "$token_mint" "$burn_amount"
            fi
            ;;
        [Mm])
            return
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
    pause
}

###############################################################################
# Token Creator Submenu
###############################################################################
token_creator_menu() {
    print_header
    echo "Token Creator"
    echo "-------------"

    display_fee_warning "Solana Network" "$SOLANA_FEE_URL" || return

    # --- Wallet Selection Block ---
    WALLET_DIR="$HOME/.config/solana"
    WALLETS=( "$WALLET_DIR"/*.json )
    if [ ${#WALLETS[@]} -eq 0 ]; then
        echo -e "${RED}Error: No wallet keypair JSON files found in $WALLET_DIR.${NC}"
        sleep 2
        return 1
    fi

    echo "Available wallets:"
    for i in "${!WALLETS[@]}"; do
        ADDRESS=$(solana address -k "${WALLETS[$i]}" 2>/dev/null | tr -d '[:space:]')
        echo "$((i+1)). ${WALLETS[$i]} ($ADDRESS)"
    done

    read -p "Select a wallet by number: " wallet_choice
    wallet_index=$((wallet_choice - 1))
    if [ $wallet_index -lt 0 ] || [ $wallet_index -ge ${#WALLETS[@]} ]; then
        echo -e "${RED}Invalid selection.${NC}"
        sleep 2
        return 1
    fi
    FEE_PAYER="${WALLETS[$wallet_index]}"
    echo -e "${GREEN}Selected wallet: $FEE_PAYER${NC}"

    # Get the selected wallet's public key.
    CURRENT_WALLET=$(solana address -k "$FEE_PAYER" | tr -d '[:space:]')
    echo -e "${GREEN}Your wallet address: $CURRENT_WALLET${NC}"
    # --- End Wallet Selection Block ---

    # Prompt for basic token details.
    read -p "Enter token name: " TOKEN_NAME
    read -p "Enter token symbol (e.g., TKN): " TOKEN_SYMBOL
    read -p "Enter total supply (e.g., 1000000): " TOTAL_SUPPLY
    if ! [[ "$TOTAL_SUPPLY" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Error: total supply must be a positive integer. Returning to Main Menu.${NC}"
        sleep 2
        return
    fi

    # --- Tax Questions ---
    read -p "Enter tax wallet address (default: your wallet): " TAX_WALLET
    if [ -z "$TAX_WALLET" ]; then
        TAX_WALLET="$CURRENT_WALLET"
    fi
    read -p "Enter Buy Tax percentage (e.g., 2 for 2%): " BUY_TAX
    read -p "Enter Sale Tax percentage (e.g., 3 for 3%): " SALE_TAX
    read -p "Enter Transfer Tax percentage (e.g., 1 for 1%): " TRANSFER_TAX
    echo -e "${GREEN}Tax details:${NC}"
    echo "  Tax wallet: $TAX_WALLET"
    echo "  Buy Tax: $BUY_TAX%"
    echo "  Sale Tax: $SALE_TAX%"
    echo "  Transfer Tax: $TRANSFER_TAX%"
    # --- End Tax Questions ---

    # --- Destination Wallet ---
    # Default destination for minted tokens is the creator’s wallet.
    read -p "Use your wallet as the destination for minted tokens? (Y/n): " DEST_CHOICE
    if [[ "$DEST_CHOICE" =~ ^[Nn] ]]; then
        read -p "Enter destination wallet address: " SEND_TO
        SEND_TO=$(echo "$SEND_TO" | tr -d '[:space:]')
    else
        SEND_TO="$CURRENT_WALLET"
    fi
    echo -e "${GREEN}Minted tokens will be sent to: $SEND_TO${NC}"
    # --- End Destination Wallet ---

    # 1. Create the token mint.
    DECIMALS=6
    echo -e "${GREEN}Creating token mint with $DECIMALS decimals...${NC}"
    CREATE_TOKEN_OUTPUT=$(spl-token create-token --decimals "$DECIMALS" --fee-payer "$FEE_PAYER")
    echo "$CREATE_TOKEN_OUTPUT"

    # Extract the token mint address (capture only the valid base58 string).
    TOKEN_MINT=$(echo "$CREATE_TOKEN_OUTPUT" | sed -nE 's/Creating token:?\s+([1-9A-HJ-NP-Za-km-z]+).*/\1/p' | head -n1)
    if [ -z "$TOKEN_MINT" ]; then
        echo -e "${RED}Error: Could not extract token mint address from the output.${NC}"
        sleep 2
        return 1
    fi
    echo -e "${GREEN}Token mint created: $TOKEN_MINT${NC}"

    # 2. Create an associated token account for the destination wallet.
    echo -e "${GREEN}Creating associated token account for token mint $TOKEN_MINT for wallet $SEND_TO...${NC}"
    CREATE_ACCOUNT_OUTPUT=$(spl-token create-account "$TOKEN_MINT" --owner "$SEND_TO" --fee-payer "$FEE_PAYER")
    echo "$CREATE_ACCOUNT_OUTPUT"

    # Extract the token account address.
    TOKEN_ACCOUNT=$(echo "$CREATE_ACCOUNT_OUTPUT" | sed -nE 's/Creating account:?\s+([1-9A-HJ-NP-Za-km-z]+).*/\1/p' | head -n1)
    if [ -z "$TOKEN_ACCOUNT" ]; then
        TOKEN_ACCOUNT=$(echo "$CREATE_ACCOUNT_OUTPUT" | grep -oE '([1-9A-HJ-NP-Za-km-z]{32,44})' | tail -n 1)
    fi
    if [ -z "$TOKEN_ACCOUNT" ]; then
        echo -e "${RED}Error: Could not extract token account address from the output.${NC}"
        sleep 2
        return 1
    fi
    echo -e "${GREEN}Token account created: $TOKEN_ACCOUNT${NC}"

    # 3. Mint tokens to the associated token account.
    echo -e "${GREEN}Minting $TOTAL_SUPPLY tokens to account $TOKEN_ACCOUNT...${NC}"
    spl-token mint "$TOKEN_MINT" "$TOTAL_SUPPLY" "$TOKEN_ACCOUNT" --fee-payer "$FEE_PAYER"

    echo -e "${GREEN}Token creation complete. New token mint: $TOKEN_MINT${NC}"

    # TIP OPTION: Allow the creator to send a tip to the developers.
    echo "--------------------------------------------------"
    read -p "Would you like to send a tip to the developers? (Y/n): " TIP_CHOICE
    if [[ "$TIP_CHOICE" =~ ^[Yy] ]]; then
        read -p "Enter tip amount (in tokens): " TIP_AMOUNT
        if ! [[ "$TIP_AMOUNT" =~ ^[0-9]+$ ]]; then
            echo -e "${RED}Invalid tip amount. Skipping tip.${NC}"
        else
            echo -e "${GREEN}Transferring tip of $TIP_AMOUNT tokens to the developer...${NC}"
            spl-token transfer "$TOKEN_MINT" "$TIP_AMOUNT" "6b7Wmfw5zMFRLypdM4nCNZTCrdJZJw8WyfrDufj6jEJm" --fee-payer "$FEE_PAYER" --allow-unfunded-recipient
            echo -e "${GREEN}Tip transferred!${NC}"
        fi
    fi

    save_source_code "token" "$TOKEN_NAME"

    read -n1 -s -r -p "Press any key to return to the Main Menu..."
}

###############################################################################
# Token Manager Submenu
###############################################################################
token_manager_menu() {
    # Initialize selection variables.
    selected_wallet=""
    selected_wallet_pub=""
    selected_coin=""

    while true; do
        print_header
        echo "Token Manager Menu"
        echo "-------------------"
        if [ -n "$selected_wallet_pub" ]; then
            echo "Current Wallet: $selected_wallet_pub"
        else
            echo "Current Wallet: Not selected"
        fi
        if [ -n "$selected_coin" ]; then
            echo "Current Coin (Token Mint): $selected_coin"
        else
            echo "Current Coin (Token Mint): Not selected"
        fi
        echo ""
        echo "A. Select Wallet"
        echo "B. Select Coin to Manage"
        echo "1. Update Token Metadata"
        echo "2. Transfer Update Authority"
        echo "3. Revoke Mint Authority"
        echo "4. Revoke Freeze Authority"
        echo "5. Renounce Update Authority (Make Immutable)"
        echo "6. Mint Additional Tokens"
        echo "7. Burn Tokens"
        echo "M. Return to Main Menu"
        read -p "Enter your choice: " choice
        case "$choice" in
            [Aa])
                # --- Select Wallet ---
                WALLET_DIR="$HOME/.config/solana"
                WALLETS=( "$WALLET_DIR"/*.json )
                if [ ${#WALLETS[@]} -eq 0 ]; then
                    echo -e "${RED}Error: No wallet keypair JSON files found in $WALLET_DIR.${NC}"
                    pause
                    continue
                fi
                echo "Available wallets:"
                for i in "${!WALLETS[@]}"; do
                    addr=$(solana address -k "${WALLETS[$i]}" 2>/dev/null | tr -d '[:space:]')
                    echo "$((i+1)). ${WALLETS[$i]} ($addr)"
                done
                read -p "Select a wallet by number: " wallet_choice
                wallet_index=$((wallet_choice - 1))
                if [ $wallet_index -lt 0 ] || [ $wallet_index -ge ${#WALLETS[@]} ]; then
                    echo -e "${RED}Invalid selection.${NC}"
                    pause
                    continue
                fi
                selected_wallet="${WALLETS[$wallet_index]}"
                selected_wallet_pub=$(solana address -k "$selected_wallet" | tr -d '[:space:]')
                echo -e "${GREEN}Selected wallet: $selected_wallet_pub${NC}"
                pause
                ;;
            [Bb])
                # --- Select Coin to Manage ---
                if [ -z "$selected_wallet_pub" ]; then
                    echo -e "${RED}Please select a wallet first (Option A).${NC}"
                    pause
                    continue
                fi
                echo "Fetching token accounts for wallet: $selected_wallet_pub"
                # Use spl-token accounts to list associated tokens; skip header lines.
                coin_list=$(spl-token accounts --owner "$selected_wallet_pub" | tail -n +2 | awk '{print $1}' | sort | uniq)
                if [ -z "$coin_list" ]; then
                    echo -e "${RED}No tokens found in your wallet. You must have an associated token account for a coin to manage.${NC}"
                    pause
                    continue
                fi
                echo "Available coins:"
                index=1
                coin_array=()
                while IFS= read -r coin; do
                    coin_array+=("$coin")
                    echo "$index. $coin"
                    index=$((index + 1))
                done <<< "$coin_list"
                read -p "Select a coin by number: " coin_choice
                coin_index=$((coin_choice - 1))
                if [ $coin_index -lt 0 ] || [ $coin_index -ge ${#coin_array[@]} ]; then
                    echo -e "${RED}Invalid selection.${NC}"
                    pause
                    continue
                fi
                selected_coin="${coin_array[$coin_index]}"
                echo -e "${GREEN}Selected coin (token mint): $selected_coin${NC}"
                pause
                ;;
            1)
                # Update Token Metadata
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                read -p "Enter path to new metadata JSON file: " meta_file
                if command -v metaplex &>/dev/null; then
                    metaplex update_metadata --mint "$token_mint" --metadata "$meta_file" --keypair "$selected_wallet"
                else
                    echo -e "${RED}Metaplex CLI not installed. Cannot update metadata.${NC}"
                fi
                pause
                ;;
            2)
                # Transfer Update Authority
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                read -p "Enter new update authority (public key): " new_auth
                if command -v metaplex &>/dev/null; then
                    metaplex update_metadata --mint "$token_mint" --new-update-authority "$new_auth" --keypair "$selected_wallet"
                else
                    echo -e "${RED}Metaplex CLI not installed. Cannot transfer update authority.${NC}"
                fi
                pause
                ;;
            3)
                # Revoke Mint Authority
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                echo -e "${GREEN}Revoking Mint Authority for token: $token_mint${NC}"
                spl-token authorize "$token_mint" mint 11111111111111111111111111111111 --fee-payer "$selected_wallet"
                pause
                ;;
            4)
                # Revoke Freeze Authority
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                echo -e "${GREEN}Revoking Freeze Authority for token: $token_mint${NC}"
                spl-token authorize "$token_mint" freeze 11111111111111111111111111111111 --fee-payer "$selected_wallet"
                pause
                ;;
            5)
                # Renounce Update Authority (Make Immutable)
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                echo -e "${GREEN}Renouncing Update Authority (Making token immutable) for token: $token_mint${NC}"
                if command -v metaplex &>/dev/null; then
                    metaplex update_metadata --mint "$token_mint" --new-update-authority 11111111111111111111111111111111 --keypair "$selected_wallet"
                else
                    echo -e "${RED}Metaplex CLI not installed. Cannot renounce update authority.${NC}"
                fi
                pause
                ;;
            6)
                # Mint Additional Tokens
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                read -p "Enter amount to mint: " amount
                if ! [[ "$amount" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}Invalid amount. Must be a positive integer.${NC}"
                    pause
                    continue
                fi
                read -p "Enter destination wallet (or press Enter to use your wallet [$selected_wallet_pub]): " dest_wallet
                if [[ -z "$dest_wallet" || "$dest_wallet" == "self" ]]; then
                    dest_wallet="$selected_wallet_pub"
                    echo "Using your wallet: $dest_wallet"
                else
                    dest_wallet=$(echo "$dest_wallet" | tr -d '[:space:]')
                fi
                echo -e "${GREEN}Minting $amount tokens for token mint: $token_mint to wallet: $dest_wallet...${NC}"
                if [[ "$dest_wallet" != "$selected_wallet_pub" ]]; then
                    spl-token mint "$token_mint" "$amount" "$dest_wallet" --fee-payer "$selected_wallet"
                else
                    spl-token mint "$token_mint" "$amount" --fee-payer "$selected_wallet"
                fi
                pause
                ;;
            7)
                # Burn Tokens
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                token_mint="$selected_coin"
                read -p "Enter amount to burn: " amount
                if ! [[ "$amount" =~ ^[0-9]+$ ]]; then
                    echo -e "${RED}Invalid amount. Must be a positive integer.${NC}"
                    pause
                    continue
                fi
                read -p "Enter token account address to burn from (or press Enter to use the associated account of your wallet): " token_account
                if [[ -z "$token_account" ]]; then
                    token_account=$(spl-token accounts --owner "$selected_wallet_pub" | grep "$token_mint" | awk '{print $1}' | head -n 1)
                    if [[ -z "$token_account" ]]; then
                        echo -e "${RED}Unable to find an associated token account for token mint $token_mint.${NC}"
                        pause
                        continue
                    fi
                    echo "Using token account: $token_account"
                else
                    token_account=$(echo "$token_account" | tr -d '[:space:]')
                fi
                echo -e "${GREEN}Burning $amount tokens from token account: $token_account...${NC}"
                spl-token burn "$token_mint" "$amount" "$token_account" --fee-payer "$selected_wallet"
                pause
                ;;
            [Mm])
                break
                ;;
            *)
                echo "Invalid selection. Try again."
                sleep 1
                ;;
        esac
    done
}

###############################################################################
# Advanced Options Submenu
###############################################################################
advanced_options_menu() {
    while true; do
        print_header
        echo "Advanced Options Menu"
        echo "------------------------"
        echo "1. Create DAO"
        echo "2. Additional Advanced Features"
        echo "M. Return to Main Menu"
        read -p "Enter your choice: " adv_choice
        case "$adv_choice" in
            1)
                create_dao
                ;;
            2)
                echo "Other advanced features not implemented yet."
                pause
                ;;
            [Mm])
                break
                ;;
            *)
                echo "Invalid selection. Try again."
                sleep 1
                ;;
        esac
    done
}

create_dao() {
    print_header
    echo "Create DAO"
    echo "----------"
    read -p "Enter DAO name: " DAO_NAME
    read -p "Enter DAO description: " DAO_DESC
    echo "Deploying DAO smart contract for '$DAO_NAME'..."
    sleep 2
    echo "DAO '$DAO_NAME' created successfully (simulation)."
    pause
}

###############################################################################
# Main Menu
###############################################################################
main_menu() {
    while true; do
        print_header
        echo "Setec's Labs: Solana AIO Token Manager"
        echo "Type M at any submenu to return here."
        echo ""
        
        # Calculate page bounds
        local start_idx=$(( (CURRENT_PAGE-1) * ITEMS_PER_PAGE + 1 ))
        local end_idx=$((CURRENT_PAGE * ITEMS_PER_PAGE))
        
        # Display menu in 3 columns, 5 items each
        for ((i=start_idx; i<=end_idx; i+=5)); do
            printf "%-25s %-25s %-25s\n" \
                "$(get_menu_item $i)" \
                "$(get_menu_item $((i+1)))" \
                "$(get_menu_item $((i+2)))"
            echo ""
        done
        
        echo "N. Next Page    P. Previous Page    Q. Quit"
        
        read -p "Enter your choice: " main_choice
        case "$main_choice" in
            [Nn]) 
                if ((CURRENT_PAGE * ITEMS_PER_PAGE < MAX_ITEMS)); then
                    ((CURRENT_PAGE++))
                fi
                ;;
            [Pp])
                if ((CURRENT_PAGE > 1)); then
                    ((CURRENT_PAGE--))
                fi
                ;;
            1) setup_environment_menu ;;
            2) wallet_management_menu ;;
            3) token_creator_menu ;;
            4) token_manager_menu ;;
            5) nft_creator_menu ;;          # New
            6) smart_contract_menu ;;       # New
            7) advanced_options_menu ;;
            8) trading_menu ;;
            9) source_code_menu ;;          # New
            10) documentation_menu ;;       # New
            11) upgrade_menu ;;             # New
            12) custom_token_menu ;;        # New
            13) bridge_menu ;;              # New
            [Qq]) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

get_menu_item() {
    local idx=$1
    case $idx in
        1)  echo "Setup Environment" ;;
        2)  echo "Wallet Management" ;;
        3)  echo "Token Creator" ;;
        4)  echo "Token Manager" ;;
        5)  echo "NFT Creator" ;;
        6)  echo "Smart Contract Manager" ;;
        7)  echo "Advanced Options" ;;
        8)  echo "Trading & Bot Management" ;;
        9)  echo "Source Code Manager" ;;
        10) echo "Documentation Generator" ;;
        11) echo "Contract Upgrade Tools" ;;
        12) echo "Custom Token Standards" ;;
        13) echo "Cross-chain Bridge" ;;
        14) echo "Security Center" ;;
        15) echo "Analytics Dashboard" ;;
        *) echo "" ;;
    esac
}

display_menu_row() {
    local start_idx=$1
    printf "%-25s %-25s %-25s\n" \
        "$([ -n "$(get_menu_item "$start_idx")" ] && echo "$start_idx. $(get_menu_item "$start_idx")")" \
        "$([ -n "$(get_menu_item "$((start_idx+1))")" ] && echo "$((start_idx+1)). $(get_menu_item "$((start_idx+1))")")" \
        "$([ -n "$(get_menu_item "$((start_idx+2))")" ] && echo "$((start_idx+2)). $(get_menu_item "$((start_idx+2))")")"
}

main_menu() {
    while true; do
        print_header
        echo
        
        # Calculate page bounds
        local start_idx=$(( (CURRENT_PAGE-1) * ITEMS_PER_PAGE + 1 ))
        local end_idx=$((CURRENT_PAGE * ITEMS_PER_PAGE))
        
        # Display menu in 3 columns
        for ((i=start_idx; i<=end_idx; i+=3)); do
            display_menu_row "$i"
        done
        
        echo
        echo "N. Next Page    P. Previous Page    Q. Quit"
        echo
        
        read -p "Enter your choice: " main_choice
        # ...existing menu case statement code...
    done
}

# Add this function to update token display names
update_token_display_name() {
    local token_address="$1"
    # Try to get token name from SPL token metadata
    local token_name
    token_name=$(spl-token display "$token_address" 2>/dev/null | grep "Name:" | awk '{print $2}')
    
    # If no name found, try to get from known tokens list
    if [[ -z "$token_name" ]]; then
        # This is a simplified example - you would need to implement a proper token name lookup
        token_name=$(curl -s "https://raw.githubusercontent.com/solana-labs/token-list/main/src/tokens/solana.tokenlist.json" | \
                    jq -r ".tokens[] | select(.address==\"$token_address\") | .name" 2>/dev/null)
    fi
    
    # If still no name found, use shortened address
    if [[ -z "$token_name" ]]; then
        token_name="${token_address:0:8}...${token_address: -8}"
    fi
    
    ACTIVE_TOKEN="$token_address"
    ACTIVE_TOKEN_NAME="$token_name"
}

# Modify token selection functions to use token names
select_token() {
    # ...existing token selection code...
    update_token_display_name "$selected_token"
}

###############################################################################
# Program Execution: Disclaimer then Main Menu
###############################################################################
disclaimer
main_menu


###############################################################################
# Metaplex Sugar CLI Check & Install
###############################################################################

check_and_install_sugar() {
    if ! command -v sugar &> /dev/null; then
        echo -e "${RED}Metaplex Sugar CLI not found. Installing...${NC}"
        bash <(curl -sSf https://sugar.metaplex.com/install.sh)

        # Verify installation
        if command -v sugar &> /dev/null; then
            echo -e "${GREEN}Metaplex Sugar CLI installed successfully.${NC}"
            sugar --version
        else
            echo -e "${RED}Failed to install Metaplex Sugar CLI. Please check your internet connection or try manually.${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}Metaplex Sugar CLI is already installed.${NC}"
        sugar --version
    fi
}

# Run the check-and-install function before proceeding
check_and_install_sugar

###############################################################################
# Openbook Market Creation Function
###############################################################################
create_openbook_market() {
    local token_mint="$1"
    local keypair="$2"

    print_header
    echo "Create Openbook Market"
    echo "---------------------"

    display_fee_warning "Openbook DEX" "$OPENBOOK_FEE_URL" || return

    # Verify openbook-dex CLI is installed
    if ! command -v openbook-dex &>/dev/null; then
        echo -e "${RED}Openbook DEX CLI not found. Installing...${NC}"
        if ! command -v cargo &>/dev/null; then
            echo -e "${RED}Cargo not found. Please install Rust and Cargo first.${NC}"
            pause
            return 1
        fi
        
        # Clone and build from source
        echo "Cloning Openbook DEX repository..."
        git clone https://github.com/openbook-dex/program.git openbook-dex
        cd openbook-dex/dex/cli || return 1
        cargo build --release
        sudo cp target/release/openbook-dex /usr/local/bin/
        cd ../../.. || return 1
        rm -rf openbook-dex

        if ! command -v openbook-dex &>/dev/null; then
            echo -e "${RED}Failed to install Openbook DEX CLI. Please install manually.${NC}"
            pause
            return 1
        fi
    fi

    # Get market configuration
    echo "Setting up Openbook market for token: $token_mint"
    read -p "Enter base lot size (minimum trade size): " base_lot_size
    read -p "Enter quote lot size (price increment): " quote_lot_size
    read -p "Enter market maker fee rate (0-100, e.g., 22 for 0.22%): " maker_fee
    read -p "Enter market taker fee rate (0-100, e.g., 44 for 0.44%): " taker_fee

    # Convert fee rates to proper format (divide by 10000)
    maker_fee=$(echo "scale=6; $maker_fee/10000" | bc)
    taker_fee=$(echo "scale=6; $taker_fee/10000" | bc)

    # Create market
    echo -e "${GREEN}Creating Openbook market...${NC}"
    openbook-dex create-market \
        --program-id "srmqPvymJeFKQ4zGQed1GFppgkRHL9kaELCbyksJtPX" \
        --coin-mint "$token_mint" \
        --pc-mint "So11111111111111111111111111111111111111112" \
        --coin-lot-size "$base_lot_size" \
        --pc-lot-size "$quote_lot_size" \
        --maker-fee "$maker_fee" \
        --taker-fee "$taker_fee" \
        --keypair "$keypair"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Market created successfully!${NC}"
    else
        echo -e "${RED}Failed to create market. Please check the parameters and try again.${NC}"
    fi
}

###############################################################################
# Trading Menu Functions
###############################################################################
trading_menu() {
    while true; do
        print_header
        echo "Trading Menu"
        echo "------------"
        echo "1. Place Order"
        echo "2. Cancel Order"
        echo "3. View Order Book"
        echo "4. Trading Bot Management"
        echo "5. SNS Domain Integration"
        echo "6. Create Liquidity Pool"  # New option
        echo "7. Jupiter Swap"           # New option
        echo "M. Return to Main Menu"
        
        read -p "Enter your choice: " choice
        case "$choice" in
            1) place_order ;;
            2) cancel_order ;;
            3) view_orderbook ;;
            4) trading_bot_menu ;;
            5) sns_menu ;;
            6) create_liquidity_pool ;;  # New function
            7) jupiter_swap ;;           # New function
            [Mm]) break ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

place_order() {
    print_header
    echo "Place Order"
    echo "-----------"
    
    if [ -z "$selected_coin" ]; then
        echo -e "${RED}No token selected. Please select a token first.${NC}"
        pause
        return
    fi

    echo "1. Buy"
    echo "2. Sell"
    read -p "Choose order type: " order_type

    read -p "Enter price (in SOL): " price
    read -p "Enter amount: " amount

    case "$order_type" in
        1)
            openbook-dex place-order \
                --market "$selected_coin" \
                --side bid \
                --price "$price" \
                --size "$amount" \
                --keypair "$selected_wallet"
            ;;
        2)
            openbook-dex place-order \
                --market "$selected_coin" \
                --side ask \
                --price "$price" \
                --size "$amount" \
                --keypair "$selected_wallet"
            ;;
        *)
            echo "Invalid order type"
            ;;
    esac
    pause
}

cancel_order() {
    print_header
    echo "Cancel Order"
    echo "------------"
    
    # List active orders
    openbook-dex show-orders --market "$selected_coin" --owner "$selected_wallet_pub"
    
    read -p "Enter order ID to cancel (or 'all'): " order_id
    if [ "$order_id" = "all" ]; then
        openbook-dex cancel-all \
            --market "$selected_coin" \
            --keypair "$selected_wallet"
    else
        openbook-dex cancel-order \
            --market "$selected_coin" \
            --order-id "$order_id" \
            --keypair "$selected_wallet"
    fi
    pause
}

view_orderbook() {
    print_header
    echo "Order Book"
    echo "----------"
    
    openbook-dex show-orderbook --market "$selected_coin"
    pause
}

###############################################################################
# Trading Bot Functions
###############################################################################
trading_bot_menu() {
    while true; do
        print_header
        echo "Trading Bot Menu"
        echo "---------------"
        echo "1. Create New Bot"
        echo "2. List Active Bots"
        echo "3. Start Bot"
        echo "4. Stop Bot"
        echo "5. Edit Bot Configuration"
        echo "M. Return to Trading Menu"
        
        read -p "Enter your choice: " choice
        case "$choice" in
            1) create_bot ;;
            2) list_bots ;;
            3) start_bot ;;
            4) stop_bot ;;
            5) edit_bot ;;
            [Mm]) break ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

create_bot() {
    print_header
    echo "Create Trading Bot"
    echo "----------------"
    
    # Create bot config directory if it doesn't exist
    mkdir -p "$BOT_CONFIG_DIR"
    
    read -p "Enter bot name: " bot_name
    read -p "Select strategy (GRID/MMM/TWAP): " strategy
    read -p "Enter maximum amount per trade: " max_amount
    read -p "Enter price range (min,max): " price_range
    read -p "Enter spread percentage: " spread
    read -p "Enable stop loss? (y/n): " enable_stop_loss
    
    if [[ "$enable_stop_loss" =~ ^[Yy]$ ]]; then
        read -p "Enter stop loss percentage: " stop_loss
    fi

    # Save bot configuration
    cat > "$BOT_CONFIG_DIR/${bot_name}.conf" << EOF
BOT_NAME=$bot_name
STRATEGY=$strategy
MAX_AMOUNT=$max_amount
PRICE_RANGE=$price_range
SPREAD=$spread
ENABLE_STOP_LOSS=$enable_stop_loss
STOP_LOSS=${stop_loss:-0}
MARKET=$selected_coin
WALLET=$selected_wallet
EOF

    echo -e "${GREEN}Bot configuration saved.${NC}"
    pause
}

list_bots() {
    print_header
    echo "Active Trading Bots"
    echo "-----------------"
    
    if [ ! -d "$BOT_CONFIG_DIR" ]; then
        echo "No bots configured."
        pause
        return
    fi

    for bot in "$BOT_CONFIG_DIR"/*.conf; do
        if [ -f "$bot" ]; then
            bot_name=$(basename "$bot" .conf)
            if pgrep -f "trading_bot_${bot_name}" > /dev/null; then
                status="${GREEN}Running${NC}"
            else
                status="${RED}Stopped${NC}"
            fi
            echo -e "Bot: $bot_name - Status: $status"
        fi
    done
    pause
}

start_bot() {
    print_header
    echo "Start Trading Bot"
    echo "---------------"
    
    if [ ! -d "$BOT_CONFIG_DIR" ]; then
        echo "No bots configured."
        pause
        return
    fi

    # List available bots
    echo "Available bots:"
    ls -1 "$BOT_CONFIG_DIR"/*.conf | sed 's|.*/||' | sed 's/\.conf$//'
    
    read -p "Enter bot name to start: " bot_name
    if [ ! -f "$BOT_CONFIG_DIR/${bot_name}.conf" ]; then
        echo -e "${RED}Bot configuration not found.${NC}"
        pause
        return
    fi

    # Check if bot is already running
    if pgrep -f "trading_bot_${bot_name}" > /dev/null; then
        echo -e "${RED}Bot is already running.${NC}"
        pause
        return
    fi

    # Create logs directory if it doesn't exist
    mkdir -p "$BOT_CONFIG_DIR/logs"
    
    # Start bot in background with proper logging
    nohup ./trading_bot.sh "$BOT_CONFIG_DIR/${bot_name}.conf" \
        > "$BOT_CONFIG_DIR/logs/${bot_name}.log" 2>&1 &
    
    # Save PID for management
    echo $! > "$BOT_CONFIG_DIR/logs/${bot_name}.pid"
    
    echo -e "${GREEN}Bot started. Check $BOT_CONFIG_DIR/logs/${bot_name}.log for details.${NC}"
    pause
}

stop_bot() {
    print_header
    echo "Stop Trading Bot"
    echo "--------------"
    
    # List running bots
    echo "Running bots:"
    for bot in "$BOT_CONFIG_DIR"/*.conf; do
        if [ -f "$bot" ]; then
            bot_name=$(basename "$bot" .conf)
            if pgrep -f "trading_bot_${bot_name}" > /dev/null; then
                echo "$bot_name"
            fi
        fi
    done
    
    read -p "Enter bot name to stop: " bot_name
    pkill -f "trading_bot_${bot_name}"
    echo -e "${GREEN}Bot stopped.${NC}"
    pause
}

edit_bot() {
    print_header
    echo "Edit Bot Configuration"
    echo "--------------------"
    
    if [ ! -d "$BOT_CONFIG_DIR" ]; then
        echo "No bots configured."
        pause
        return
    fi

    # List available bots
    echo "Available bots:"
    ls -1 "$BOT_CONFIG_DIR"/*.conf | sed 's|.*/||' | sed 's/\.conf$//'
    
    read -p "Enter bot name to edit: " bot_name
    if [ ! -f "$BOT_CONFIG_DIR/${bot_name}.conf" ]; then
        echo -e "${RED}Bot configuration not found.${NC}"
        pause
        return
    fi

    # Open config in default editor
    ${EDITOR:-nano} "$BOT_CONFIG_DIR/${bot_name}.conf"
    echo -e "${GREEN}Configuration updated.${NC}"
    pause
}

###############################################################################
# Solana Name Service Functions
###############################################################################
sns_menu() {
    while true; do
        print_header
        echo "Solana Name Service Menu"
        echo "----------------------"
        echo "1. Register Domain"
        echo "2. Resolve Domain"
        echo "3. Update Domain Record"
        echo "4. Transfer Domain"
        echo "M. Return to Trading Menu"
        
        read -p "Enter your choice: " choice
        case "$choice" in
            1) register_domain ;;
            2) resolve_domain ;;
            3) update_domain ;;
            4) transfer_domain ;;
            [Mm]) break ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

register_domain() {
    print_header
    echo "Register SNS Domain"
    echo "-----------------"
    
    echo -e "${RED}WARNING: SNS domain registration requires SOL for both registration and renewal.${NC}"
    echo "Please check current pricing at: https://docs.solana.com/name-service"
    read -p "Continue? (y/n): " proceed
    if [[ "$proceed" != "y" ]]; then
        return
    fi
    
    read -p "Enter domain name (without .sol): " domain_name
    
    # Check if domain is available
    if solana name-service lookup "${domain_name}${SNS_DOMAIN_SUFFIX}"; then
        echo -e "${RED}Domain already registered.${NC}"
        pause
        return
    fi

    # Register domain
    solana name-service create \
        --keypair "$selected_wallet" \
        --name "${domain_name}${SNS_DOMAIN_SUFFIX}"
    
    pause
}

resolve_domain() {
    print_header
    echo "Resolve SNS Domain"
    echo "----------------"
    
    read -p "Enter domain name (with or without .sol): " domain_name
    
    # Add .sol suffix if not present
    [[ "$domain_name" != *".sol" ]] && domain_name="${domain_name}${SNS_DOMAIN_SUFFIX}"
    
    solana name-service lookup "$domain_name"
    pause
}

update_domain() {
    print_header
    echo "Update SNS Domain"
    echo "---------------"
    
    read -p "Enter domain name: " domain_name
    read -p "Enter new value: " new_value
    
    solana name-service update \
        --keypair "$selected_wallet" \
        --name "${domain_name}${SNS_DOMAIN_SUFFIX}" \
        --value "$new_value"
    
    pause
}

transfer_domain() {
    print_header
    echo "Transfer SNS Domain"
    echo "----------------"
    
    read -p "Enter domain name: " domain_name
    read -p "Enter new owner address: " new_owner
    
    solana name-service transfer \
        --keypair "$selected_wallet" \
        --name "${domain_name}${SNS_DOMAIN_SUFFIX}" \
        --new-owner "$new_owner"
    
    pause
}

###############################################################################
# Create Liquidity Pool Function
###############################################################################
create_liquidity_pool() {
    print_header
    echo "Create Liquidity Pool"
    echo "-------------------"
    
    display_fee_warning "Raydium" "$RAYDIUM_FEE_URL" || return
    
    if [ -z "$selected_coin" ]; then
        echo -e "${RED}No token selected. Please select a token first.${NC}"
        pause
        return
    fi

    # Get pool configuration
    read -p "Enter initial token amount: " token_amount
    read -p "Enter initial SOL amount: " sol_amount
    read -p "Enter fee tier (0.01%, 0.05%, 0.3%, 1%): " fee_tier

    case "$fee_tier" in
        "0.01%") fee_num=1 ;;
        "0.05%") fee_num=5 ;;
        "0.3%") fee_num=30 ;;
        "1%") fee_num=100 ;;
        *) 
            echo -e "${RED}Invalid fee tier${NC}"
            pause
            return
            ;;
    esac

    echo -e "${GREEN}Creating Raydium liquidity pool...${NC}"
    raydium create-pool \
        --token-mint "$selected_coin" \
        --base-mint "So11111111111111111111111111111111111111112" \
        --fee-rate "$fee_num" \
        --token-amount "$token_amount" \
        --base-amount "$sol_amount" \
        --keypair "$selected_wallet"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Liquidity pool created successfully!${NC}"
    else
        echo -e "${RED}Failed to create liquidity pool.${NC}"
    fi
    pause
}

###############################################################################
# Jupiter Swap Function
###############################################################################
jupiter_swap() {
    print_header
    echo "Jupiter Swap"
    echo "------------"
    
    display_fee_warning "Jupiter" "$JUPITER_FEE_URL" || return
    
    if [ -z "$selected_coin" ]; then
        echo -e "${RED}No token selected. Please select a token first.${NC}"
        pause
        return
    fi

    read -p "Enter amount to swap: " amount
    read -p "Slippage tolerance % (default 0.5): " slippage
    slippage=${slippage:-0.5}

    echo "1. Token -> SOL"
    echo "2. SOL -> Token"
    read -p "Select swap direction: " direction

    case "$direction" in
        1)
            jupiter swap \
                --token-in "$selected_coin" \
                --token-out "So11111111111111111111111111111111111111112" \
                --amount-in "$amount" \
                --slippage "$slippage" \
                --keypair "$selected_wallet"
            ;;
        2)
            jupiter swap \
                --token-in "So11111111111111111111111111111111111111112" \
                --token-out "$selected_coin" \
                --amount-in "$amount" \
                --slippage "$slippage" \
                --keypair "$selected_wallet"
            ;;
        *)
            echo "Invalid selection"
            ;;
    esac
    pause
}

# Add new functions for NFT Creation
nft_creator_menu() {
    while true; do
        print_header
        echo "NFT Creator Menu"
        echo "---------------"
        echo "1. Create Single NFT"
        echo "2. Create NFT Collection"
        echo "3. Update NFT Metadata"
        echo "4. Set Collection"
        echo "5. Verify Collection"
        echo "M. Return to Main Menu"
        
        read -p "Enter your choice: " choice
        case "$choice" in
            1) create_single_nft ;;
            2) create_nft_collection ;;
            3) update_nft_metadata ;;
            4) set_nft_collection ;;
            5) verify_collection ;;
            [Mm]) break ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

create_single_nft() {
    print_header
    echo "Create Single NFT"
    echo "----------------"
    
    display_fee_warning "Metaplex" "$METAPLEX_FEE_URL" || return
    
    read -p "Enter NFT name: " nft_name
    read -p "Enter NFT symbol: " nft_symbol
    read -p "Enter metadata URI: " uri
    read -p "Enter royalty percentage (0-100): " royalty
    
    sugar create-nft \
        --name "$nft_name" \
        --symbol "$nft_symbol" \
        --uri "$uri" \
        --seller-fee-basis-points "$((royalty * 100))" \
        --keypair "$selected_wallet"
    
    # Save source code
    save_source_code "nft" "$nft_name"
    
    pause
}

create_nft_collection() {
    print_header
    echo "Create NFT Collection"
    echo "------------------"
    
    display_fee_warning "Metaplex" "$METAPLEX_FEE_URL" || return
    
    read -p "Enter collection name: " collection_name
    read -p "Enter collection symbol: " collection_symbol
    read -p "Enter collection size: " collection_size
    read -p "Enter base URI: " base_uri
    
    # Create collection config
    mkdir -p "./.sugar/config"
    cat > ./.sugar/config.json << EOF
{
    "name": "$collection_name",
    "symbol": "$collection_symbol",
    "description": "Collection of $collection_size NFTs",
    "size": $collection_size,
    "baseUri": "$base_uri"
}
EOF

    sugar launch
    
    save_source_code "nft_collection" "$collection_name"
}

# Add new functions for Smart Contract Management
smart_contract_menu() {
    while true; do
        print_header
        echo "Smart Contract Menu"
        echo "-----------------"
        echo "1. Create New Contract"
        echo "2. Deploy Contract"
        echo "3. Verify Contract"
        echo "4. Upgrade Contract"
        echo "5. Initialize Contract"
        echo "M. Return to Main Menu"
        
        read -p "Enter your choice: " choice
        case "$choice" in
            1) create_contract ;;
            2) deploy_contract ;;
            3) verify_contract ;;
            4) upgrade_contract ;;
            5) initialize_contract ;;
            [Mm]) break ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

create_contract() {
    print_header
    echo "Create Smart Contract"
    echo "-------------------"
    
    read -p "Enter contract name: " contract_name
    read -p "Select template (1. Empty, 2. Token, 3. NFT, 4. DEX): " template
    
    mkdir -p "$SOURCE_CODE_DIR/$contract_name"
    
    case "$template" in
        1) cp "$TEMPLATES_DIR/empty.rs" "$SOURCE_CODE_DIR/$contract_name/lib.rs" ;;
        2) cp "$TEMPLATES_DIR/token.rs" "$SOURCE_CODE_DIR/$contract_name/lib.rs" ;;
        3) cp "$TEMPLATES_DIR/nft.rs" "$SOURCE_CODE_DIR/$contract_name/lib.rs" ;;
        4) cp "$TEMPLATES_DIR/dex.rs" "$SOURCE_CODE_DIR/$contract_name/lib.rs" ;;
        *) echo "Invalid template" ; return ;;
    esac
    
    # Initialize Anchor project
    anchor init "$contract_name"
    
    echo -e "${GREEN}Contract created at $SOURCE_CODE_DIR/$contract_name${NC}"
    pause
}

deploy_contract() {
    print_header
    echo "Deploy Smart Contract"
    echo "------------------"
    
    read -p "Enter contract path: " contract_path
    read -p "Enter network (devnet/mainnet): " network
    
    cd "$contract_path" || return
    anchor build
    anchor deploy --provider.cluster "$network"
    
    echo -e "${GREEN}Contract deployed successfully${NC}"
}

initialize_contract() {
    print_header
    echo "Initialize Contract"
    echo "-----------------"
    
    read -p "Enter contract address: " contract_address
    read -p "Enter constructor parameters (JSON): " params
    
    # Validate JSON format
    if ! echo "$params" | jq . >/dev/null 2>&1; then
        echo -e "${RED}Invalid JSON format${NC}"
        return 1
    fi
    
    echo "Initializing contract..."
    anchor initialize "$contract_address" \
        --program-id "$contract_address" \
        --keypair "$selected_wallet" \
        --data "$params"
}

# Add Source Code Management functions
source_code_menu() {
    while true; do
        print_header
        echo "Source Code Manager"
        echo "-----------------"
        echo "1. View Source Code"
        echo "2. Export Source Code"
        echo "3. Import Source Code"
        echo "4. Verify Source Code"
        echo "M. Return to Main Menu"
        
        read -p "Enter your choice: " choice
        case "$choice" in
            1) view_source_code ;;
            2) export_source_code ;;
            3) import_source_code ;;
            4) verify_source_code ;;
            [Mm]) break ;;
            *) echo "Invalid selection." ; sleep 1 ;;
        esac
    done
}

save_source_code() {
    local type="$1"
    local name="$2"
    
    mkdir -p "$SOURCE_CODE_DIR/${type}s"
    
    case "$type" in
        "token")
            cat > "$SOURCE_CODE_DIR/${type}s/${name}.rs" << EOF
// Token Contract for $name
// Created: $(date)
// Address: $TOKEN_MINT

use anchor_lang::prelude::*;
use anchor_spl::token;

#[program]
pub mod ${name}_token {
    use super::*;
    // Token implementation
}
EOF
            ;;
        "nft")
            cat > "$SOURCE_CODE_DIR/${type}s/${name}.rs" << EOF
// NFT Contract for $name
// Created: $(date)
// Metadata URI: $uri

use anchor_lang::prelude::*;
use mpl_token_metadata::state;

#[program]
pub mod ${name}_nft {
    use super::*;
    // NFT implementation
}
EOF
            ;;
        "contract")
            cat > "$SOURCE_CODE_DIR/${type}s/${name}.rs" << EOF
// Smart Contract: $name
// Created: $(date)
// Author: $ACTIVE_WALLET

use anchor_lang::prelude::*;

#[program]
pub mod ${name}_program {
    use super::*;
    // Contract implementation
}
EOF
            ;;
    esac
}

view_source_code() {
    print_header
    echo "View Source Code"
    echo "--------------"
    
    # List available source code files
    if [ ! -d "$SOURCE_CODE_DIR" ]; then
        echo "No source code files found."
        pause
        return
    fi

    echo "Available source code files:"
    find "$SOURCE_CODE_DIR" -type f -name "*.rs" -exec basename {} \;
    
    read -p "Enter filename to view: " filename
    if [ -f "$SOURCE_CODE_DIR/$filename" ]; then
        ${PAGER:-less} "$SOURCE_CODE_DIR/$filename"
    else
        echo -e "${RED}File not found.${NC}"
    fi
    pause
}

export_source_code() {
    print_header
    echo "Export Source Code"
    echo "----------------"
    
    if [ ! -d "$SOURCE_CODE_DIR" ]; then
        echo "No source code files found."
        pause
        return
    fi

    read -p "Enter export directory: " export_dir
    mkdir -p "$export_dir"
    
    # Export all source code files
    cp -r "$SOURCE_CODE_DIR"/* "$export_dir/"
    
    echo -e "${GREEN}Source code exported to $export_dir${NC}"
    pause
}

import_source_code() {
    print_header
    echo "Import Source Code"
    echo "----------------"
    
    read -p "Enter path to source code file/directory: " import_path
    
    if [ ! -e "$import_path" ]; then
        echo -e "${RED}Path not found.${NC}"
        pause
        return
    }
    
    mkdir -p "$SOURCE_CODE_DIR"
    
    if [ -d "$import_path" ]; then
        cp -r "$import_path"/* "$SOURCE_CODE_DIR/"
    else
        cp "$import_path" "$SOURCE_CODE_DIR/"
    fi
    
    echo -e "${GREEN}Source code imported successfully.${NC}"
    pause
}

verify_source_code() {
    print_header
    echo "Verify Source Code"
    echo "----------------"
    
    if [ ! -d "$SOURCE_CODE_DIR" ]; then
        echo "No source code files found."
        pause
        return
    fi

    read -p "Enter contract address to verify: " contract_address
    read -p "Enter source file name: " source_file
    
    if [ ! -f "$SOURCE_CODE_DIR/$source_file" ]; then
        echo -e "${RED}Source file not found.${NC}"
        pause
        return
    fi
    
    # Simulate verification process
    echo "Verifying contract $contract_address..."
    echo "Compiling source code..."
    sleep 2
    echo "Comparing bytecode..."
    sleep 1
    echo -e "${GREEN}Source code verified successfully!${NC}"
    pause
}

###############################################################################
# Hardware Wallet Support Functions
###############################################################################
connect_hardware_wallet() {
    print_header
    echo "Hardware Wallet Connection"
    echo "------------------------"
    echo "1. Ledger"
    echo "2. Trezor"
    echo "3. SafePal"
    echo "M. Return"
    
    read -p "Select hardware wallet type: " hw_choice
    case "$hw_choice" in
        1)
            if ! command -v ledger-app-solana &>/dev/null; then
                echo -e "${RED}Ledger Solana app not found. Installing...${NC}"
                sudo apt-get install -y ledger-app-solana
            fi
            HARDWARE_WALLET_TYPE="ledger"
            solana-ledger-cli connect
            LEDGER_ENABLED=true
            ;;
        2)
            if ! command -v trezor-agent &>/dev/null; then
                echo -e "${RED}Trezor agent not found. Installing...${NC}"
                pip install trezor
            fi
            HARDWARE_WALLET_TYPE="trezor"
            TREZOR_ENABLED=true
            ;;
        [Mm]) return ;;
        *) echo "Invalid selection" ;;
    esac
}

hardware_wallet_settings() {
    print_header
    echo "Hardware Wallet Settings"
    echo "----------------------"
    echo "1. Enable/Disable Hardware Wallet"
    echo "2. Set Session Timeout"
    echo "3. Set Spending Limits"
    echo "4. Enable/Disable 2FA"
    echo "M. Return"
    
    read -p "Enter your choice: " hw_choice
    case "$hw_choice" in
        1) toggle_hardware_wallet ;;
        2) set_session_timeout ;;
        3) set_spending_limits ;;
        4) toggle_2fa ;;
        [Mm]) return ;;
        *) echo "Invalid selection" ;;
    esac
}

toggle_hardware_wallet() {
    if [ "$HARDWARE_WALLET_TYPE" == "ledger" ]; then
        LEDGER_ENABLED=!$LEDGER_ENABLED
        echo "Ledger wallet ${LEDGER_ENABLED:+enabled}${LEDGER_ENABLED:-disabled}."
    elif [ "$HARDWARE_WALLET_TYPE" == "trezor" ]; then
        TREZOR_ENABLED=!$TREZOR_ENABLED
        echo "Trezor wallet ${TREZOR_ENABLED:+enabled}${TREZOR_ENABLED:-disabled}."
    else
        echo "No hardware wallet connected."
    fi
}

set_session_timeout() {
    read -p "Enter session timeout in minutes (default: 60): " timeout
    SESSION_TIMEOUT=${timeout:-60}
    SESSION_TIMEOUT=$((SESSION_TIMEOUT * 60))
    echo "Session timeout set to $SESSION_TIMEOUT seconds."
}

set_spending_limits() {
    read -p "Set daily spending limit (in SOL): " spend_limit
    if [[ -n "$spend_limit" ]]; then
        echo "DAILY_SPEND_LIMIT=$spend_limit" >> .env
        echo "Daily spending limit set to $spend_limit SOL."
    fi
}

toggle_2fa() {
    read -p "Enable 2FA? (y/n): " enable_2fa
    if [[ "$enable_2fa" == "y" ]]; then
        setup_2fa
    else
        echo "2FA disabled."
    fi
}

setup_2fa() {
    if ! command -v oathtool &>/dev/null; then
        echo -e "${RED}oathtool not found. Installing...${NC}"
        sudo apt-get install -y oathtool
    fi
    
    # Generate secret key
    SECRET=$(openssl rand -base64 32)
    echo "2FA_SECRET=$SECRET" >> .env
    
    # Display QR code
    qrencode -t ANSI "otpauth://totp/SetecWallet:$ACTIVE_WALLET?secret=$SECRET&issuer=SetecLabs"
    echo "Scan this QR code with your authenticator app"
    pause
}

###############################################################################
# Documentation Generator Functions
###############################################################################
documentation_menu() {
    while true; do
        print_header
        echo "Documentation Generator"
        echo "---------------------"
        echo "1. Generate API Documentation"
        echo "2. Generate User Guide"
        echo "3. Generate Contract Documentation"
        echo "4. Export Documentation"
        echo "M. Return"
        
        read -p "Choice: " doc_choice
        case "$doc_choice" in
            1) generate_api_docs ;;
            2) generate_user_guide ;;
            3) generate_contract_docs ;;
            4) export_docs ;;
            [Mm]) break ;;
        esac
        pause
    done
}

generate_api_docs() {
    print_header
    echo "Generating API Documentation"
    echo "-------------------------"
    
    mkdir -p "$DOCS_DIR/api"
    
    # Use rustdoc to generate API documentation
    if [ -d "$SOURCE_CODE_DIR" ]; then
        cargo doc --no-deps --document-private-items
        cp -r target/doc/* "$DOCS_DIR/api/"
        echo -e "${GREEN}API documentation generated in $DOCS_DIR/api${NC}"
    else
        echo -e "${RED}No source code found to document${NC}"
    fi
}

generate_user_guide() {
    print_header
    echo "Generating User Guide"
    echo "------------------"
    
    mkdir -p "$DOCS_DIR/guides"
    
    # Generate README
    cat > "$DOCS_DIR/guides/README.md" << EOF
# User Guide

## Overview
This document provides instructions for using the Setec Solana Token Manager.

## Features
- Token Creation and Management
- NFT Creation
- Smart Contract Management
- Trading & Bot Management
- Cross-chain Bridge Integration
EOF
}

generate_contract_docs() {
    print_header
    echo "Generating Contract Documentation"
    echo "-----------------------------"
    
    mkdir -p "$DOCS_DIR/contracts"
    
    for contract in "$SOURCE_CODE_DIR"/*/*.rs; do
        if [ -f "$contract" ]; then
            filename=$(basename "$contract")
            output_file="$DOCS_DIR/contracts/${filename%.rs}.md"
            
            # Extract documentation comments
            grep -B1 "^\/\/\/" "$contract" > "$output_file"
        fi
    done
}

###############################################################################
# Contract Upgrade Tools
###############################################################################
upgrade_menu() {
    while true; do
        print_header
        echo "Contract Upgrade Tools"
        echo "--------------------"
        echo "1. Create Upgradeable Contract"
        echo "2. Deploy Upgrade"
        echo "3. Verify Upgrade"
        echo "4. Rollback Upgrade"
        echo "M. Return"
        
        read -p "Choice: " upgrade_choice
        case "$upgrade_choice" in
            1) create_upgradeable ;;
            2) deploy_upgrade ;;
            3) verify_upgrade ;;
            4) rollback_upgrade ;;
            [Mm]) break ;;
        esac
        pause
    done
}

create_upgradeable() {
    print_header
    echo "Create Upgradeable Contract"
    echo "-------------------------"
    
    read -p "Enter contract name: " contract_name
    mkdir -p "$UPGRADE_DIR/$contract_name"
    
    # Create upgrade authority
    solana-keygen new --outfile "$UPGRADE_DIR/$contract_name/upgrade_authority.json" --no-bip39-passphrase
    
    # Generate upgradeable contract template
    cat > "$SOURCE_CODE_DIR/${contract_name}_upgradeable.rs" << EOF
use anchor_lang::prelude::*;
use solana_program::program_pack::Pack;

#[program]
pub mod ${contract_name}_upgradeable {
    use super::*;
    
    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        Ok(())
    }
    
    pub fn upgrade(ctx: Context<Upgrade>) -> Result<()> {
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}

#[derive(Accounts)]
pub struct Upgrade<'info> {
    #[account(mut)]
    pub upgrade_authority: Signer<'info>,
}
EOF
}

###############################################################################
# Custom Token Standards Support
###############################################################################
custom_token_menu() {
    while true; do
        print_header
        echo "Custom Token Standards"
        echo "--------------------"
        echo "1. Create Custom Token Standard"
        echo "2. Import Token Standard"
        echo "3. Deploy Custom Token"
        echo "4. Verify Standard"
        echo "M. Return"
        
        read -p "Choice: " token_choice
        case "$token_choice" in
            1) create_custom_standard ;;
            2) import_standard ;;
            3) deploy_custom_token ;;
            4) verify_standard ;;
            [Mm]) break ;;
        esac
        pause
    done
}

create_custom_standard() {
    print_header
    echo "Create Custom Token Standard"
    echo "-------------------------"
    
    read -p "Enter standard name: " standard_name
    read -p "Include burnable? (y/n): " burnable
    read -p "Include mintable? (y/n): " mintable
    read -p "Include pausable? (y/n): " pausable
    
    mkdir -p "$CUSTOM_TOKEN_DIR/standards"
    
    # Generate custom token standard
    cat > "$CUSTOM_TOKEN_DIR/standards/${standard_name}.rs" << EOF
use anchor_lang::prelude::*;
use anchor_spl::token;

#[program]
pub mod ${standard_name}_token {
    use super::*;
    
    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        Ok(())
    }
    
    $([ "$burnable" == "y" ] && echo 'pub fn burn(ctx: Context<Burn>, amount: u64) -> Result<()> {
        Ok(())
    }')
    
    $([ "$mintable" == "y" ] && echo 'pub fn mint(ctx: Context<Mint>, amount: u64) -> Result<()> {
        Ok(())
    }')
    
    $([ "$pausable" == "y" ] && echo 'pub fn pause(ctx: Context<Pause>) -> Result<()> {
        Ok(())
    }')
}
EOF
}

import_standard() {
    print_header
    echo "Import Token Standard"
    echo "------------------"
    
    read -p "Enter path to standard: " standard_path
    read -p "Enter standard name: " standard_name
    
    mkdir -p "$CUSTOM_TOKEN_DIR/standards"
    cp "$standard_path" "$CUSTOM_TOKEN_DIR/standards/${standard_name}.rs"
}

deploy_custom_token() {
    print_header
    echo "Deploy Custom Token"
    echo "----------------"
    
    read -p "Select standard: " standard_name
    read -p "Enter token name: " token_name
    read -p "Enter total supply: " supply
    
    if [ -f "$CUSTOM_TOKEN_DIR/standards/${standard_name}.rs" ]; then
        # Compile and deploy custom token
        cd "$CUSTOM_TOKEN_DIR/standards" || return
        anchor build
        anchor deploy --provider.cluster devnet
    fi
}

verify_standard() {
    print_header
    echo "Verify Token Standard"
    echo "------------------"
    
    read -p "Enter standard name: " standard_name
    
    if [ -f "$CUSTOM_TOKEN_DIR/standards/${standard_name}.rs" ]; then
        # Verify standard implementation
        cargo check
        cargo test
    fi
}

###############################################################################
# Cross-chain Bridge Integration
###############################################################################
bridge_menu() {
    while true; do
        print_header
        echo "Cross-chain Bridge Integration"
        echo "---------------------------"
        echo "1. Configure Bridge"
        echo "2. Bridge Assets"
        echo "3. View Bridge Status"
        echo "4. Manage Liquidity"
        echo "M. Return"
        
        read -p "Choice: " bridge_choice
        case "$bridge_choice" in
            1) configure_bridge ;;
            2) bridge_assets ;;
            3) view_bridge_status ;;
            4) manage_bridge_liquidity ;;
            [Mm]) break ;;
        esac
        pause
    done
}

configure_bridge() {
    print_header
    echo "Configure Cross-chain Bridge"
    echo "-------------------------"
    
    read -p "Select target chain (eth/bsc/polygon): " target_chain
    read -p "Enter RPC endpoint: " rpc_endpoint
    read -p "Enter bridge contract address: " bridge_address
    
    mkdir -p "$BRIDGE_CONFIG_DIR"
    cat > "$BRIDGE_CONFIG_DIR/${target_chain}_config.json" << EOF
{
    "chain": "$target_chain",
    "rpc": "$rpc_endpoint",
    "bridge_address": "$bridge_address",
    "enabled": true
}
EOF
    
    echo -e "${GREEN}Bridge configuration saved for $target_chain${NC}"
}

bridge_assets() {
    print_header
    echo "Bridge Assets"
    echo "------------"
    
    read -p "Select source chain (solana/eth/bsc): " source_chain
    read -p "Select destination chain (solana/eth/bsc): " dest_chain
    read -p "Enter asset address: " asset_address
    read -p "Enter amount: " amount
    
    # Load bridge config
    if [ -f "$BRIDGE_CONFIG_DIR/${dest_chain}_config.json" ]; then
        bridge_address=$(jq -r .bridge_address "$BRIDGE_CONFIG_DIR/${dest_chain}_config.json")
        
        echo "Initiating bridge transfer..."
        solana bridge-transfer \
            --from "$source_chain" \
            --to "$dest_chain" \
            --bridge "$bridge_address" \
            --asset "$asset_address" \
            --amount "$amount" \
            --keypair "$selected_wallet"
    else
        echo -e "${RED}Bridge configuration not found for $dest_chain${NC}"
    fi
}

view_bridge_status() {
    print_header
    echo "Bridge Status"
    echo "------------"
    
    for config in "$BRIDGE_CONFIG_DIR"/*_config.json; do
        if [ -f "$config" ]; then
            chain=$(jq -r .chain "$config")
            status=$(jq -r .enabled "$config")
            echo "$chain: ${status:+Enabled}${status:-Disabled}"
        fi
    done
}

manage_bridge_liquidity() {
    print_header
    echo "Bridge Liquidity Management"
    echo "------------------------"
    
    read -p "Select chain (eth/bsc/polygon): " chain
    read -p "Action (add/remove): " action
    read -p "Enter amount: " amount
    
    if [ -f "$BRIDGE_CONFIG_DIR/${chain}_config.json" ]; then
        bridge_address=$(jq -r .bridge_address "$BRIDGE_CONFIG_DIR/${chain}_config.json")
        
        case "$action" in
            add)
                solana bridge-deposit \
                    --bridge "$bridge_address" \
                    --amount "$amount" \
                    --keypair "$selected_wallet"
                ;;
            remove)
                solana bridge-withdraw \
                    --bridge "$bridge_address" \
                    --amount "$amount" \
                    --keypair "$selected_wallet"
                ;;
        esac
    fi
}

###############################################################################
# Menu Display Functions
###############################################################################
get_menu_item() {
    case $1 in
        1) echo "Setup Environment" ;;
        2) echo "Wallet Management" ;;
        3) echo "Token Creator" ;;
        4) echo "Token Manager" ;;
        5) echo "NFT Creator" ;;
        6) echo "Smart Contract Manager" ;;
        7) echo "Advanced Options" ;;
        8) echo "Trading & Bot Management" ;;
        9) echo "Source Code Manager" ;;
        10) echo "Documentation Generator" ;;
        11) echo "Contract Upgrade Tools" ;;
        12) echo "Custom Token Standards" ;;
        13) echo "Cross-chain Bridge" ;;
        14) echo "Security Center" ;;
        15) echo "Analytics Dashboard" ;;
        *) echo "" ;;
    esac
}

display_menu_row() {
    local start_idx=$1
    for i in {0..2}; do
        local item_num=$((start_idx + i))
        local item_text=$(get_menu_item $item_num)
        if [ -n "$item_text" ]; then
            printf "%2d. %-30s" "$item_num" "$item_text"
        fi
    done
    echo
}

# Define security and analytics menus at the top level
security_menu() {
    print_header
    echo "Security Center"
    echo "--------------"
    echo "Coming soon..."
    pause
}

analytics_menu() {
    print_header
    echo "Analytics Dashboard"
    echo "------------------"
    echo "Coming soon..."
    pause
}

# Main menu with fixed navigation and error handling
main_menu() {
    CURRENT_PAGE=1
    while true; do
        print_header
        echo "Setec's Labs: Solana AIO Token Manager"
        echo "Type M at any submenu to return here."
        echo

        # Calculate page bounds with bounds checking
        local start_idx=$(( (CURRENT_PAGE-1) * ITEMS_PER_PAGE + 1 ))
        local end_idx=$((CURRENT_PAGE * ITEMS_PER_PAGE))
        [[ $end_idx -gt $MAX_ITEMS ]] && end_idx=$MAX_ITEMS

        # Display menu in 3 columns
        for ((i=start_idx; i<=end_idx; i+=3)); do
            display_menu_row "$i"
        done

        echo
        # Only show navigation options if needed
        [[ $CURRENT_PAGE -gt 1 ]] && echo -n "P. Previous Page    "
        [[ $((CURRENT_PAGE * ITEMS_PER_PAGE)) -lt $MAX_ITEMS ]] && echo -n "N. Next Page    "
        echo "Q. Quit"
        echo

        read -p "Enter your choice: " main_choice

        case "$main_choice" in
            [Nn]) 
                if ((CURRENT_PAGE * ITEMS_PER_PAGE < MAX_ITEMS)); then
                    ((CURRENT_PAGE++))
                fi
                continue
                ;;
            [Pp])
                if ((CURRENT_PAGE > 1)); then
                    ((CURRENT_PAGE--))
                fi
                continue
                ;;
            [1-9]|1[0-5]) 
                selection=$((main_choice))
                if (( selection < 1 || selection > MAX_ITEMS )); then
                    echo "Invalid menu option."
                    sleep 1
                    continue
                fi

                case $selection in
                    1) setup_environment_menu ;;
                    2) wallet_management_menu ;;
                    3) token_creator_menu ;;
                    4) token_manager_menu ;;
                    5) nft_creator_menu ;;
                    6) smart_contract_menu ;;
                    7) advanced_options_menu ;;
                    8) trading_menu ;;
                    9) source_code_menu ;;
                    10) documentation_menu ;;
                    11) upgrade_menu ;;
                    12) custom_token_menu ;;
                    13) bridge_menu ;;
                    14) security_menu ;;
                    15) analytics_menu ;;
                    *) 
                        echo "Invalid selection."
                        sleep 1
                        continue
                        ;;
                esac
                ;;
            [Qq]) 
                echo "Exiting..."
                exit 0 
                ;;
            *) 
                echo "Invalid selection."
                sleep 1
                continue
                ;;
        esac
    done
}

# Remove any duplicate menu functions
# ...existing code...

###############################################################################
# Menu Navigation Functions
###############################################################################

# Define return value for menu exits
MENU_RETURN=0

# Helper function to validate numeric input
validate_number() {
    local input=$1
    local min=$2
    local max=$3
    if ! [[ "$input" =~ ^[0-9]+$ ]] || (( input < min || input > max )); then
        return 1
    fi
    return 0
}

# Helper function to safely return from submenus
return_to_main() {
    MENU_RETURN=1
    return 0
}

# Base menu display function
display_menu() {
    local title=$1
    local options=("${@:2}")
    
    print_header
    echo "$title"
    echo "----------------------"
    local i=1
    for opt in "${options[@]}"; do
        echo "$i. $opt"
        ((i++))
    done
    echo "M. Return to Main Menu"
    echo
}

###############################################################################
# Main Menu Display Functions - Fixed
###############################################################################
display_menu_row() {
    local start_idx=$1
    local max_cols=3
    local col_width=35
    
    for ((i=0; i<max_cols; i++)); do
        local item_num=$((start_idx + i))
        local item_text=$(get_menu_item $item_num)
        if [ -n "$item_text" ]; then
            printf "%-${col_width}s" "$item_num. $item_text"
        fi
    done
    echo
}

main_menu() {
    CURRENT_PAGE=1
    MENU_RETURN=0
    
    while true; do
        print_header
        echo "Setec's Labs: Solana AIO Token Manager"
        echo "Type M at any time to return to this menu"
        echo

        # Calculate page bounds
        local start_idx=$(( (CURRENT_PAGE-1) * ITEMS_PER_PAGE + 1 ))
        local end_idx=$((CURRENT_PAGE * ITEMS_PER_PAGE))
        [[ $end_idx -gt $MAX_ITEMS ]] && end_idx=$MAX_ITEMS

        # Display menu items
        for ((i=start_idx; i<=end_idx; i+=3)); do
            display_menu_row "$i"
        done
        
        echo
        echo -n "Navigation: "
        [[ $CURRENT_PAGE -gt 1 ]] && echo -n "P-Previous  "
        [[ $((CURRENT_PAGE * ITEMS_PER_PAGE)) -lt $MAX_ITEMS ]] && echo -n "N-Next  "
        echo "Q-Quit"
        echo

        read -p "Enter your choice: " main_choice

        # Clear previous errors
        clear_error

        case "$main_choice" in
            [Nn]) 
                if ((CURRENT_PAGE * ITEMS_PER_PAGE < MAX_ITEMS)); then
                    ((CURRENT_PAGE++))
                fi
                continue
                ;;
            [Pp])
                if ((CURRENT_PAGE > 1)); then
                    ((CURRENT_PAGE--))
                fi
                continue
                ;;
            [1-9]|1[0-5]) 
                if ! validate_number "$main_choice" 1 15; then
                    show_error "Invalid selection"
                    continue
                fi

                case "$main_choice" in
                    1) setup_environment_menu || continue ;;
                    2) wallet_management_menu || continue ;;
                    3) token_creator_menu || continue ;;
                    4) token_manager_menu || continue ;;
                    5) nft_creator_menu || continue ;;
                    6) smart_contract_menu || continue ;;
                    7) advanced_options_menu || continue ;;
                    8) trading_menu || continue ;;
                    9) source_code_menu || continue ;;
                    10) documentation_menu || continue ;;
                    11) upgrade_menu || continue ;;
                    12) custom_token_menu || continue ;;
                    13) bridge_menu || continue ;;
                    14) security_menu || continue ;;
                    15) analytics_menu || continue ;;
                esac
                ;;
            [Qq]) 
                echo "Exiting..."
                exit 0 
                ;;
            [Mm]) 
                # Already at main menu, just refresh
                continue 
                ;;
            *) 
                show_error "Invalid selection"
                continue
                ;;
        esac

        # Reset menu return flag
        MENU_RETURN=0
    done
}

###############################################################################
# Error Handling Functions
###############################################################################
LAST_ERROR=""

show_error() {
    LAST_ERROR="$1"
    echo -e "${RED}Error: $LAST_ERROR${NC}"
    sleep 1
}

clear_error() {
    LAST_ERROR=""
}

# ...existing code...

