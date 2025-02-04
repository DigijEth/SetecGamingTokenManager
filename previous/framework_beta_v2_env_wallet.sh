
# Create .env file for user API keys
if [ ! -f .env ]; then
    echo "Creating .env file for storing API keys..."
    cat <<EOL > .env
API_KEY=""
SECRET_KEY=""
EOL
    echo "Environment file .env created. Please update it with your API credentials."
fi
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

###############################################################################
# Utility Functions
###############################################################################
print_header() {
    clear
    echo -e "${GREEN}---------------------------------------------------------------"
    echo -e "| Setec Gaming Labs Presents: Setec Solana Token Manager       |"
    echo -e "---------------------------------------------------------------${NC}"
}

pause() {
    echo "Press Enter to continue..."
    read -r
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
if ! command -v sugar &> /dev/null; then
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo privileges." >&2
    exit 1
fi

# Check for required dependencies
REQUIRED_COMMANDS=("sugar" "openbook" "raydium" "jupiter" "solana")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed. Please install it before running this script." >&2
        exit 1
    fi
done
    echo "Metaplex (Sugar) not found, installing..."
    if ! bash <(curl -sSf https://raw.githubusercontent.com/metaplex-foundation/sugar/main/script/sugar-install.sh); then
        echo "Error: Failed to install Metaplex (Sugar). Please check your internet connection and try again." >&2
        exit 1
    fi
fi
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
        echo "M. Return to Main Menu"
        read -p "Enter your choice: " choice
        case "$choice" in
            1) create_wallet ;;
            2) view_wallet ;;
            3) set_active_wallet ;;
            4) manage_tokens ;;
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
if ! command -v sugar &> /dev/null; then
    echo "Metaplex (Sugar) not found, installing..."
    if ! bash <(curl -sSf https://raw.githubusercontent.com/metaplex-foundation/sugar/main/script/sugar-install.sh); then
        echo "Error: Failed to install Metaplex (Sugar). Please check your internet connection and try again." >&2
        exit 1
    fi
fi
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
if ! command -v sugar &> /dev/null; then
    echo "Metaplex (Sugar) not found, installing..."
    if ! bash <(curl -sSf https://raw.githubusercontent.com/metaplex-foundation/sugar/main/script/sugar-install.sh); then
        echo "Error: Failed to install Metaplex (Sugar). Please check your internet connection and try again." >&2
        exit 1
    fi
fi
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
if ! command -v sugar &> /dev/null; then
    echo "Metaplex (Sugar) not found, installing..."
    if ! bash <(curl -sSf https://raw.githubusercontent.com/metaplex-foundation/sugar/main/script/sugar-install.sh); then
        echo "Error: Failed to install Metaplex (Sugar). Please check your internet connection and try again." >&2
        exit 1
    fi
fi
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
        echo "1. Setup Environment"
        echo "2. Wallet Management"
        echo "3. Token Creator"
        echo "4. Token Manager"
        echo "5. Advanced Options"
        echo "Q. Quit"
        read -p "Enter your choice: " main_choice
        case "$main_choice" in
            1) setup_environment_menu ;;
            2) wallet_management_menu ;;
            3) token_creator_menu ;;
            4) token_manager_menu ;;
            5) advanced_options_menu ;;
            [Qq]) echo "Exiting..."; exit 0 ;;
            *)
                echo "Invalid selection. Please try again."
                sleep 1
                ;;
        esac
    done
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


# Anti-bot protection options for token creation
ANTI_BOT_PROTECTION="--enable-anti-bot"
TOKEN_CREATION_CMD="$TOKEN_CREATION_CMD $ANTI_BOT_PROTECTION"
if ! $TOKEN_CREATION_CMD; then
    echo "Error: Token creation failed. Please check the logs for more details." >&2
    exit 1
fi

# Option to export contract source code
EXPORT_CONTRACT_SOURCE="yes"
if [ "$EXPORT_CONTRACT_SOURCE" = "yes" ]; then
    echo "Exporting contract source code..."
if ! mkdir -p contract_source; then
    echo "Error: Failed to create contract source directory." >&2
    exit 1
fi
if ! cp -r ./contracts contract_source/; then
    echo "Error: Failed to export contract source files." >&2
    exit 1
fi
    echo "Contract source exported to contract_source/ directory."
fi

# Option to create an OpenBook market
CREATE_OPENBOOK_MARKET="no"
if [ "$CREATE_OPENBOOK_MARKET" = "yes" ]; then
    echo "Creating OpenBook market..."
    if ! openbook create-market --quote-mint <QUOTE_MINT> --base-mint <BASE_MINT>; then
        echo "Error: Failed to create OpenBook market." >&2
        exit 1
    fi
    echo "OpenBook market successfully created."
fi

# Option to create a Liquidity Pool on Jupiter or Raydium
CREATE_LIQUIDITY_POOL="no"
PLATFORM="Raydium"  # Options: Raydium, Jupiter
if [ "$CREATE_LIQUIDITY_POOL" = "yes" ]; then
    echo "Creating Liquidity Pool on $PLATFORM..."
    if [ "$PLATFORM" = "Raydium" ]; then
        if ! raydium create-pool --base-mint <BASE_MINT> --quote-mint <QUOTE_MINT> --initial-liquidity <AMOUNT>; then
            echo "Error: Failed to create Liquidity Pool on Raydium." >&2
            exit 1
        fi
    elif [ "$PLATFORM" = "Jupiter" ]; then
        if ! jupiter create-pool --base-mint <BASE_MINT> --quote-mint <QUOTE_MINT> --initial-liquidity <AMOUNT>; then
            echo "Error: Failed to create Liquidity Pool on Jupiter." >&2
            exit 1
        fi
    else
        echo "Error: Invalid liquidity pool platform selected. Choose either Raydium or Jupiter." >&2
        exit 1
    fi
    echo "Liquidity Pool successfully created on $PLATFORM."
fi

# Import Wallet from Seed Phrase
IMPORT_WALLET="no"
if [ "$IMPORT_WALLET" = "yes" ]; then
    read -p "Enter your 12/24-word seed phrase: " SEED_PHRASE
    if ! solana-keygen recover --force --outfile imported_wallet.json prompt://; then
        echo "Error: Failed to import wallet from seed phrase." >&2
        exit 1
    fi
    echo "Wallet successfully imported and stored in imported_wallet.json."
fi

# Export Wallet Seed Phrase
EXPORT_WALLET="no"
if [ "$EXPORT_WALLET" = "yes" ]; then
    echo "WARNING: Never share your seed phrase! Anyone with access can drain your wallet!"
    if ! solana-keygen recover --no-bip39-passphrase --outfile exported_seed.json prompt://; then
        echo "Error: Failed to export wallet seed phrase." >&2
        exit 1
    fi
    echo "Seed phrase exported to exported_seed.json. Keep it secure!"
fi
