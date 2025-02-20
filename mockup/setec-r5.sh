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
ENCRYPTED_ENV=".env.encrypted"
API_CONFIG=".api_config"
IMAGE_DIR="./images"

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
# Games Menu Functions (Inserted from setec-online-r3.sh)
###############################################################################
games_menu() {
    while true; do
        print_header
        echo "Games Menu"
        echo "------------------------"
        echo "1. Play Dice Roll"
        echo "2. Play Number Guessing"
        echo "3. Play Dragons of Despair"
        echo "4. Exit to Main Menu"
        read -p "Enter your choice: " game_choice
        case "$game_choice" in
            1) play_dice_roll ;;
            2) play_number_guess ;;
            3) dragons_of_despair ;;
            4) break ;;
            *) echo "Invalid selection. Try again." ;;
        esac
        pause
    done
}

play_dice_roll() {
    print_header
    echo "Rolling the dice..."
    sleep 1
    roll=$((RANDOM % 6 + 1))
    echo "You rolled a $roll!"
    pause
}

play_number_guess() {
    print_header
    target=$((RANDOM % 10 + 1))
    attempts=0
    while true; do
        read -p "Guess a number between 1 and 10: " guess
        ((attempts++))
        if [[ "$guess" -eq "$target" ]]; then
            echo "Congratulations! You guessed it in $attempts attempts."
            break
        elif [[ "$guess" -lt "$target" ]]; then
            echo "Too low! Try again."
        else
            echo "Too high! Try again."
        fi
    done
    pause
}

dragons_of_despair() {
    print_header
    echo "----------------------"
    echo "Dragons of Despair"
    echo "----------------------"
    echo "The world of Karnyndor stands on the brink of ruin. Once a land of peace and prosperity, it now trembles under"
    echo "the shadow of the Dragonlords, ancient tyrants who have returned to claim their dominion. The gods, long silent,"
    echo "have abandoned the mortal realm—until now."
    echo ""
    echo "In Dragons of Despair, you and your band of unlikely heroes must uncover the truth behind the lost relics of the gods,"
    echo "relics that may be the key to turning the tide of war. Battle through ruined kingdoms, forge uneasy alliances,"
    echo "and defy the will of the Dragonlords themselves in an epic quest for salvation."
    echo ""
    echo "But beware—whispers speak of a traitor among you, and the fate of Karnyndor may rest on choices that will test your"
    echo "courage, loyalty, and the very bonds of fate itself."
    echo "----------------------"
    echo "The war has begun. Will you rise or fall in the age of dragons?"
    echo "----------------------"
    
    while true; do
        echo "1. Play"
        echo "2. Staking Menu"
        echo "3. Return to Games Menu"
        read -p "Enter your choice: " dod_choice
        case "$dod_choice" in
            1) echo "You enter the world of Karnyndor, preparing for your first battle..."; pause ;;
            2) staking_menu ;;
            3) break ;;
            *) echo "Invalid selection. Try again." ;;
        esac
    done
}

# New Staking Menu for Dragons of Despair
staking_menu() {
    print_header
    echo "========================================"
    echo "       Dragons of Despair"
    echo "         Staking Options"
    echo "========================================"
    echo ""
    echo "Staking Explanation:"
    echo "When you stake your assets in Dragons of Despair, you lock them in a contract that"
    echo "helps provide stability to the ecosytem while you get exclusive bonuses and rewards."
    echo " "
    echo "Bonuses include:"
    echo " - Early Access to New Races, Classes, and Content"
    echo " - Bonus EXP"
    echo " - Fee-Free Auction House Transactions for the duration of your staking contract"
    echo " - Daily Token Rewards"
    echo ""
    echo "Staking Options:"
    echo "1. Stake for 30 days"
    echo "2. Stake for 60 days"
    echo "3. Stake for 90 days"
    echo "4. Return to Dragons of Despair Menu"
    echo ""
    read -p "Enter your choice: " stake_choice
    case "$stake_choice" in
        1) echo "You selected 30-day staking. Rewards will be applied accordingly."; pause ;;
        2) echo "You selected 60-day staking. Rewards will be applied accordingly."; pause ;;
        3) echo "You selected 90-day staking. Rewards will be applied accordingly."; pause ;;
        4) return ;;
        *) echo "Invalid selection."; pause; staking_menu ;;
    esac
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
    echo " 8. Metaplex Sugar CLI    : $(check_installed sugar)"
    echo " 9. Openbook DEX CLI      : $(check_installed openbook)"
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
            # Recommended: Node.js + npm, Rust, Solana CLI (stable), spl-token CLI, Anchor CLI, and Metaplex Sugar CLI.
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
                     8)
                        if ! command -v sugar &>/dev/null; then
                            bash <(curl -sSf https://sugar.metaplex.com/install.sh)
                        fi
                        ;;
                    9)
                        if ! command -v openbook &>/dev/null; then
                            cargo install openbook-dex-cli
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
    if ! command -v openbook &>/dev/null; then
        echo -e "${RED}Openbook DEX CLI not found.${NC}"
        read -p "Install via cargo? (y/n): " OPENBOOK_INSTALL
        if [[ "$OPENBOOK_INSTALL" == "y" ]]; then
            cargo install openbook-dex-cli
        else
            echo -e "${RED}Skipping Openbook DEX CLI installation. Market creation will not be available.${NC}"
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
        echo "3. API Management"
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
            3)
                api_management_menu
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
# Install Metaplex Sugar CLI Function
###############################################################################
install_metaplex() {
    if ! command -v sugar &>/dev/null; then
        echo -e "${RED}Metaplex Sugar CLI not found.${NC}"
        read -p "Install Metaplex Sugar CLI? (y/n): " METAPLEX_INSTALL
        if [[ "$METAPLEX_INSTALL" == "y" ]]; then
            bash <(curl -sSf https://sugar.metaplex.com/install.sh)
            if ! command -v sugar &>/dev/null; then
                echo -e "${RED}Failed to install Metaplex Sugar CLI.${NC}"
                return 1
            fi
            echo -e "${GREEN}Metaplex Sugar CLI installed successfully.${NC}"
            sugar --version
        else
            echo -e "${RED}Skipping Metaplex Sugar CLI installation. Metadata management will not be available.${NC}"
        fi
    else
        echo -e "${GREEN}Found Metaplex Sugar CLI.${NC}"
        sugar --version
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

    # Prompt for decimals
    echo -e "${GREEN}Enter number of decimals for token (default: 6):${NC}"
    echo "Common values:"
    echo "6 - Standard token (like USDC)"
    echo "9 - Higher precision token (like SPL tokens)"
    echo "0 - Non-divisible token"
    read -p "Enter decimals (0-9): " DECIMALS
    DECIMALS=${DECIMALS:-6}
    if ! [[ "$DECIMALS" =~ ^[0-9]$ ]]; then
        echo -e "${RED}Invalid decimals value. Using default (6).${NC}"
        DECIMALS=6
    fi

    # --- Anti-Bot Protection ---
    echo -e "${GREEN}Anti-Bot Protection Setup${NC}"
    read -p "Enable transaction limit per wallet? (y/n): " ENABLE_TX_LIMIT
    if [[ "$ENABLE_TX_LIMIT" =~ ^[Yy]$ ]]; then
        read -p "Enter maximum transactions per wallet per day: " MAX_TX_PER_WALLET
        read -p "Enter maximum token amount per transaction: " MAX_AMOUNT_PER_TX
    fi

    read -p "Enable honeypot detection? (y/n): " ENABLE_HONEYPOT
    if [[ "$ENABLE_HONEYPOT" =~ ^[Yy]$ ]]; then
        read -p "Enter blacklist checking delay (seconds): " HONEYPOT_DELAY
    fi

    # --- Security Features ---
    echo -e "${GREEN}Security Features Setup${NC}"
    read -p "Enable automatic blacklist for suspicious addresses? (y/n): " ENABLE_BLACKLIST
    read -p "Enable transaction rate limiting? (y/n): " ENABLE_RATE_LIMIT
    if [[ "$ENABLE_RATE_LIMIT" =~ ^[Yy]$ ]]; then
        read -p "Enter minimum time between transactions (seconds): " TX_RATE_LIMIT
    fi

    read -p "Enable maximum wallet holding? (y/n): " ENABLE_MAX_WALLET
    if [[ "$ENABLE_MAX_WALLET" =~ ^[Yy]$ ]]; then
        read -p "Enter maximum tokens per wallet (percentage of total supply): " MAX_WALLET_PERCENT
    fi

    # Setup metadata
    setup_token_metadata "$TOKEN_NAME" "$TOKEN_SYMBOL"

    # Create token with security features
    echo -e "${GREEN}Creating token mint with $DECIMALS decimals...${NC}"
    CREATE_TOKEN_ARGS=(
        --decimals "$DECIMALS"
        --fee-payer "$FEE_PAYER"
    )

    # Add security feature flags
    if [[ "$ENABLE_TX_LIMIT" =~ ^[Yy]$ ]]; then
        CREATE_TOKEN_ARGS+=(
            --max-tx-per-wallet "$MAX_TX_PER_WALLET"
            --max-amount-per-tx "$MAX_AMOUNT_PER_TX"
        )
    fi

    if [[ "$ENABLE_HONEYPOT" =~ ^[Yy]$ ]]; then
        CREATE_TOKEN_ARGS+=(--honeypot-delay "$HONEYPOT_DELAY")
    fi

    if [[ "$ENABLE_BLACKLIST" =~ ^[Yy]$ ]]; then
        CREATE_TOKEN_ARGS+=(--enable-blacklist)
    fi

    if [[ "$ENABLE_RATE_LIMIT" =~ ^[Yy]$ ]]; then
        CREATE_TOKEN_ARGS+=(--tx-rate-limit "$TX_RATE_LIMIT")
    fi

    if [[ "$ENABLE_MAX_WALLET" =~ ^[Yy]$ ]]; then
        CREATE_TOKEN_ARGS+=(--max-wallet-percent "$MAX_WALLET_PERCENT")
    fi

    # Create the token with all specified features
    CREATE_TOKEN_OUTPUT=$(spl-token create-token "${CREATE_TOKEN_ARGS[@]}")
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
# Token Creation Helper Functions
###############################################################################
setup_token_metadata() {
    local token_name="$1"
    local token_symbol="$2"
    
    print_header
    echo "Token Metadata Setup"
    echo "-------------------"
    
    # Description
    read -p "Enter token description: " TOKEN_DESCRIPTION
    
    # Image handling
    echo "Image Options:"
    echo "1. Use URL"
    echo "2. Select from images folder"
    read -p "Select option (1-2): " image_choice
    
    case "$image_choice" in
        1)
            read -p "Enter image URL: " TOKEN_IMAGE_URL
            ;;
        2)
            if [[ ! -d "$IMAGE_DIR" ]]; then
                echo -e "${RED}Images directory not found. Creating...${NC}"
                mkdir -p "$IMAGE_DIR"
            fi
            
            # List available images
            images=("$IMAGE_DIR"/*.{png,jpg,jpeg,gif})
            if [[ ${#images[@]} -eq 0 ]]; then
                echo -e "${RED}No images found in $IMAGE_DIR. Please add images and try again.${NC}"
                read -p "Enter image URL instead: " TOKEN_IMAGE_URL
            else
                echo "Available images:"
                for i in "${!images[@]}"; do
                    echo "$((i+1)). $(basename "${images[$i]}")"
                done
                read -p "Select image number: " img_num
                if [[ -n "${images[$((img_num-1))]}" ]]; then
                    TOKEN_IMAGE_URL="file://${images[$((img_num-1))]}"
                else
                    echo -e "${RED}Invalid selection. Please enter a URL instead: ${NC}"
                    read -p "Enter image URL: " TOKEN_IMAGE_URL
                fi
            fi
            ;;
        *)
            echo -e "${RED}Invalid choice. Using placeholder URL.${NC}"
            TOKEN_IMAGE_URL="https://example.com/token-image.png"
            ;;
    esac

    # Create metadata JSON
    cat > "token_metadata.json" << EOF
{
    "name": "$token_name",
    "symbol": "$token_symbol",
    "description": "$TOKEN_DESCRIPTION",
    "image": "$TOKEN_IMAGE_URL",
    "attributes": [],
    "properties": {
        "files": [
            {
                "uri": "$TOKEN_IMAGE_URL",
                "type": "image/png"
            }
        ]
    }
}
EOF
    echo -e "${GREEN}Metadata configuration saved.${NC}"
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
        echo "8. Create Openbook Market Listing"
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
                read -p "Enter path to config.json file: " config_file
                if command -v sugar &>/dev/null; then
                    if [ ! -f "$config_file" ]; then
                        echo -e "${RED}Config file not found. Creating template...${NC}"
                        echo '{
  "name": "My Token",
  "symbol": "TKN",
  "description": "Token Description",
  "image": "https://example.com/image.png",
  "properties": {
    "files": [
      {
        "uri": "https://example.com/image.png",
        "type": "image/png"
      }
    ]
  }
}' > "config.json"
                        echo "Please edit config.json and run this command again."
                        pause
                        continue
                    fi
                    sugar deploy -c "$config_file" --keypair "$selected_wallet"
                else
                    echo -e "${RED}Metaplex Sugar CLI not installed. Cannot update metadata.${NC}"
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
                if command -v sugar &>/dev/null; then
                    sugar update_metadata --mint "$token_mint" --new-update-authority "$new_auth" --keypair "$selected_wallet"
                else
                    echo -e "${RED}Metaplex Sugar CLI not installed. Cannot transfer update authority.${NC}"
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
                if command -v sugar &>/dev/null; then
                    sugar update_metadata --mint "$token_mint" --new-update-authority 11111111111111111111111111111111 --keypair "$selected_wallet"
                else
                    echo -e "${RED}Metaplex Sugar CLI not installed. Cannot renounce update authority.${NC}"
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
            8)
                # Create Openbook Market
                if [ -z "$selected_coin" ]; then
                    echo -e "${RED}No coin selected. Please select a coin to manage (Option B).${NC}"
                    pause
                    continue
                fi
                if [ -z "$selected_wallet" ]; then
                    echo -e "${RED}No wallet selected. Please select a wallet first (Option A).${NC}"
                    pause
                    continue
                fi
                create_openbook_market "$selected_coin" "$selected_wallet"
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
        echo "6. Games Menu"
        echo "Q. Quit"
        read -p "Enter your choice: " main_choice
        case "$main_choice" in
            1) setup_environment_menu ;;
            2) wallet_management_menu ;;
            3) token_creator_menu ;;
            4) token_manager_menu ;;
            5) advanced_options_menu ;;
            6) games_menu ;;
            [Qq]) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid selection. Please try again." ; sleep 1 ;;
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
# API Management Functions
###############################################################################
encrypt_env() {
    if [[ -f ".env" ]]; then
        openssl enc -aes-256-cbc -salt -in .env -out "$ENCRYPTED_ENV" -pass pass:"${1:-default_passphrase}"
        rm .env
        echo -e "${GREEN}Environment file encrypted successfully.${NC}"
    else
        echo -e "${RED}No .env file found to encrypt.${NC}"
    fi
}

decrypt_env() {
    if [[ -f "$ENCRYPTED_ENV" ]]; then
        openssl enc -aes-256-cbc -d -in "$ENCRYPTED_ENV" -out .env -pass pass:"${1:-default_passphrase}"
        echo -e "${GREEN}Environment file decrypted successfully.${NC}"
    else
        echo -e "${RED}No encrypted environment file found.${NC}"
    fi
}

api_management_menu() {
    while true; do
        print_header
        echo "API Management Menu"
        echo "-----------------"
        echo "1. Add New API Key"
        echo "2. List API Keys"
        echo "3. Remove API Key"
        echo "4. Update API Key"
        echo "5. Encrypt Environment File"
        echo "6. Decrypt Environment File"
        echo "M. Return to Setup Environment Menu"
        
        read -p "Enter your choice: " api_choice
        case "$api_choice" in
            1)
                read -p "Enter API name (e.g., ALCHEMY, INFURA): " api_name
                read -s -p "Enter API key: " api_key
                echo
                read -s -p "Confirm API key: " api_key_confirm
                echo
                
                if [[ "$api_key" == "$api_key_confirm" ]]; then
                    echo "${api_name}_API_KEY=${api_key}" >> .env
                    echo "${api_name}=${api_name}" >> "$API_CONFIG"
                    echo -e "${GREEN}API key added successfully.${NC}"
                else
                    echo -e "${RED}API keys do not match. Please try again.${NC}"
                fi
                ;;
            2)
                if [[ -f "$API_CONFIG" ]]; then
                    echo "Configured APIs:"
                    while IFS= read -r line; do
                        api_name="${line%%=*}"
                        echo "- $api_name"
                    done < "$API_CONFIG"
                else
                    echo "No APIs configured yet."
                fi
                ;;
            3)
                if [[ -f "$API_CONFIG" ]]; then
                    echo "Select API to remove:"
                    mapfile -t apis < "$API_CONFIG"
                    for i in "${!apis[@]}"; do
                        echo "$((i+1)). ${apis[$i]%%=*}"
                    done
                    read -p "Enter number to remove: " remove_num
                    if [[ -n "${apis[$((remove_num-1))]}" ]]; then
                        api_to_remove="${apis[$((remove_num-1))]%%=*}"
                        sed -i "/${api_to_remove}_API_KEY/d" .env
                        sed -i "/${api_to_remove}/d" "$API_CONFIG"
                        echo -e "${GREEN}API removed successfully.${NC}"
                    else
                        echo -e "${RED}Invalid selection.${NC}"
                    fi
                else
                    echo "No APIs configured to remove."
                fi
                ;;
            4)
                if [[ -f "$API_CONFIG" ]]; then
                    echo "Select API to update:"
                    mapfile -t apis < "$API_CONFIG"
                    for i in "${!apis[@]}"; do
                        echo "$((i+1)). ${apis[$i]%%=*}"
                    done
                    read -p "Enter number to update: " update_num
                    if [[ -n "${apis[$((update_num-1))]}" ]]; then
                        api_to_update="${apis[$((update_num-1))]%%=*}"
                        read -s -p "Enter new API key: " new_api_key
                        echo
                        read -s -p "Confirm new API key: " new_api_key_confirm
                        echo
                        if [[ "$new_api_key" == "$new_api_key_confirm" ]]; then
                            sed -i "s/${api_to_update}_API_KEY=.*/${api_to_update}_API_KEY=${new_api_key}/" .env
                            echo -e "${GREEN}API key updated successfully.${NC}"
                        else
                            echo -e "${RED}API keys do not match. Please try again.${NC}"
                        fi
                    else
                        echo -e "${RED}Invalid selection.${NC}"
                    fi
                else
                    echo "No APIs configured to update."
                fi
                ;;
            5)
                read -s -p "Enter encryption passphrase: " enc_pass
                echo
                read -s -p "Confirm encryption passphrase: " enc_pass_confirm
                echo
                if [[ "$enc_pass" == "$enc_pass_confirm" ]]; then
                    encrypt_env "$enc_pass"
                else
                    echo -e "${RED}Passphrases do not match. Please try again.${NC}"
                fi
                ;;
            6)
                read -s -p "Enter decryption passphrase: " dec_pass
                echo
                decrypt_env "$dec_pass"
                ;;
            [Mm])
                break
                ;;
            *)
                echo "Invalid selection. Try again."
                sleep 1
                ;;
        esac
        pause
    done
}
