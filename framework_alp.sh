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
HARDWARE_WALLET_SUPPORT=true
LOG_DIR="./logs"
BACKUP_DIR="./backups"
CONFIG_DIR="./configs"
PRICE_FEED_URL="https://api.coingecko.com/api/v3"

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

load_price_feed() {
    local coin="$1"
    local price=$(curl -s "$PRICE_FEED_URL/simple/price?ids=solana&vs_currencies=usd" | jq -r '.solana.usd')
    echo "$price"
}

save_transaction_history() {
    local tx_type="$1"
    local amount="$2"
    local description="$3"
    
    mkdir -p "$LOG_DIR/transactions"
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $tx_type: $amount - $description" >> "$LOG_DIR/transactions/history.log"
}

backup_wallet_config() {
    local wallet_name="$1"
    mkdir -p "$BACKUP_DIR/wallets"
    cp "$HOME/.config/solana/${wallet_name}.json" "$BACKUP_DIR/wallets/"
    echo "Backup created: $BACKUP_DIR/wallets/${wallet_name}.json"
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
        
        # Show wallet stats if active
        if [[ -n "${ACTIVE_WALLET:-}" ]]; then
            local sol_price=$(load_price_feed "solana")
            local balance=$(solana balance | awk '{print $1}')
            local usd_value=$(echo "$balance * $sol_price" | bc)
            
            echo -e "${GREEN}Wallet Stats${NC}"
            echo "Address: $ACTIVE_WALLET"
            echo "Balance: ◎$balance ($usd_value USD)"
            echo "Network: $NETWORK_URL"
            
            # Show recent transactions
            if [ -f "$LOG_DIR/transactions/history.log" ]; then
                echo -e "\nRecent Transactions:"
                tail -n 3 "$LOG_DIR/transactions/history.log"
            fi
        fi
        
        echo -e "\nWallet Options:"
        echo "1. Create Wallet           # Create new software wallet"
        echo "2. Import Hardware Wallet  # Connect Ledger device"
        echo "3. View Wallet Details     # Show full transaction history"
        echo "4. Export Wallet           # Backup wallet"
        echo "5. Send/Receive            # Transfer SOL/tokens"
        echo "6. Token Management        # Manage token holdings" 
        echo "7. Transaction History     # View all transactions"
        echo "8. Address Book            # Manage saved addresses"
        echo "9. Security Settings       # Configure wallet security"
        echo "M. Return to Main Menu"

        read -p "Enter choice: " choice
        case "$choice" in
            1) create_software_wallet ;;
            2) connect_hardware_wallet ;;
            3) view_wallet_details ;;
            4) export_wallet_backup ;;
            5) transfer_menu ;;
            6) token_management ;;
            7) show_transaction_history ;;
            8) address_book_menu ;;
            9) security_settings ;;
            [Mm]) break ;;
            *) echo "Invalid selection" ; sleep 1 ;;
        esac
    done
}

create_software_wallet() {
    print_header
    echo "Create New Software Wallet"
    echo "-------------------------"
    read -p "Enter wallet name: " wallet_name
    
    # Create wallet with additional security options
    read -p "Use BIP39 passphrase? (y/n): " use_passphrase
    if [[ "$use_passphrase" == "y" ]]; then
        solana-keygen new --outfile "$HOME/.config/solana/${wallet_name}.json" --force
    else
        solana-keygen new --outfile "$HOME/.config/solana/${wallet_name}.json" --no-bip39-passphrase --force
    fi
    
    # Backup the new wallet
    backup_wallet_config "$wallet_name"
    
    # Log creation
    save_transaction_history "CREATE" "0" "Created new wallet: $wallet_name"
    
    pause
}

connect_hardware_wallet() {
    if ! $HARDWARE_WALLET_SUPPORT; then
        echo "Hardware wallet support not enabled"
        pause
        return
    fi
    
    print_header
    echo "Connect Hardware Wallet"
    echo "---------------------"
    
    echo "Scanning for Ledger devices..."
    # Add actual Ledger detection/connection code here
    
    pause
}

view_wallet_details() {
    print_header
    echo "Wallet Details"
    echo "-------------"
    
    if [ -z "$ACTIVE_WALLET" ]; then
        echo "No active wallet selected"
        pause
        return
    fi
    
    local sol_price=$(load_price_feed "solana")
    local balance=$(solana balance)
    
    echo "Address: $ACTIVE_WALLET"
    echo "Balance: $balance"
    echo "USD Value: $sol_price"
    echo ""
    echo "Transaction History:"
    if [ -f "$LOG_DIR/transactions/history.log" ]; then
        cat "$LOG_DIR/transactions/history.log"
    else
        echo "No transaction history found"
    fi
    
    pause
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

import_wallet() {
    print_header
    echo "Import Wallet from Seed Phrase"
    echo "------------------------------"
    echo -e "${RED}WARNING: Only enter your seed phrase if you are in a secure environment!"
    echo "Make sure no one can see your screen and you are not on a public network.${NC}"
    echo ""
    read -p "Do you wish to continue? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
        return
    fi

    read -p "Enter number of words (12/24): " word_count
    if [[ ! "$word_count" =~ ^(12|24)$ ]]; then
        echo -e "${RED}Error: Only 12 or 24 word seeds are supported${NC}"
        pause
        return
    fi

    echo "Enter your seed phrase words one by one:"
    seed_phrase=""
    for i in $(seq 1 $word_count); do
        read -p "Word $i: " word
        seed_phrase+="$word "
    done

    # Remove trailing space
    seed_phrase="${seed_phrase% }"

    # Create new keypair file
    read -p "Enter name for the wallet: " wallet_name
    if [[ -z "$wallet_name" ]]; then
        wallet_name="imported_wallet_$(date +%s)"
    fi

    echo "$seed_phrase" | solana-keygen recover "prompt:" -o "$HOME/.config/solana/${wallet_name}.json"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Wallet imported successfully${NC}"
        read -p "Set as active wallet? (y/n): " set_active
        if [[ "$set_active" == "y" ]]; then
            ACTIVE_WALLET=$(solana address -k "$HOME/.config/solana/${wallet_name}.json")
            echo "ACTIVE_WALLET=$ACTIVE_WALLET" >> .env
            solana config set --keypair "$HOME/.config/solana/${wallet_name}.json"
        fi
    else
        echo -e "${RED}Failed to import wallet. Please verify your seed phrase.${NC}"
    fi
    pause
}

export_wallet() {
    print_header
    echo -e "${RED}⚠️  WARNING - CRITICAL SECURITY INFORMATION ⚠️${NC}"
    echo "=================================================="
    echo -e "${RED}Your seed phrase is the master key to your wallet."
    echo "Anyone with these words can steal your funds."
    echo ""
    echo "NEVER:"
    echo "- Share these words with anyone"
    echo "- Enter them on any website"
    echo "- Store them in plain text or screenshots"
    echo "- Export them on a public computer${NC}"
    echo "=================================================="
    echo ""
    read -p "I understand the risks and wish to continue (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Export cancelled."
        pause
        return
    fi

    if [ -z "$selected_wallet" ]; then
        echo "No wallet selected. Please select a wallet first."
        pause
        return
    fi

    # Clear screen for additional security
    clear
    echo -e "${RED}🔒 YOUR SEED PHRASE WILL BE SHOWN IN 5 SECONDS"
    echo "Please ensure no one can see your screen${NC}"
    sleep 5
    clear

    echo -e "${RED}YOUR SEED PHRASE:${NC}"
    echo "=================================================="
    solana-keygen recover -k "$selected_wallet" --force
    echo "=================================================="
    echo -e "${RED}Store these words safely and never share them${NC}"
    
    read -p "Press Enter once you have safely stored your seed phrase..."
    clear  # Clear screen after viewing for security
}

export_wallet_backup() {
    print_header
    echo "Export Wallet Backup"
    echo "-------------------"
    
    if [ -z "$ACTIVE_WALLET" ]; then
        echo "No active wallet selected"
        pause
        return
    fi
    
    local wallet_name=$(basename "$ACTIVE_WALLET")
    backup_wallet_config "$wallet_name"
    
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
        echo "1. Setup Environment"
        echo "2. Wallet Management"
        echo "3. Token Creator"
        echo "4. Token Manager"
        echo "5. NFT Creator"              # New
        echo "6. Smart Contract Manager"    # New
        echo "7. Advanced Options"          # Moved
        echo "8. Trading & Bot Management"  # Moved
        echo "9. Source Code Manager"       # New
        echo "Q. Quit"
        
        read -p "Enter your choice: " main_choice
        case "$main_choice" in
            1) setup_environment_menu ;;
            2) wallet_management_menu ;;
            3) token_creator_menu ;;
            4) token_manager_menu ;;
            5) nft_creator_menu ;;          # New
            6) smart_contract_menu ;;       # New
            7) advanced_options_menu ;;
            8) trading_menu ;;
            9) source_code_menu ;;          # New
            [Qq]) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid selection." ; sleep 1 ;;
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

###############################################################################
# Openbook Market Creation Function
###############################################################################
create_openbook_market() {
    local token_mint="$1"
    local keypair="$2"

    print_header
    echo "Create Openbook Market"
    echo "---------------------"

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

