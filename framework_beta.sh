# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Dependency Check (Runs Only on First Run)
DEPENDENCY_FILE="$HOME/.framework_dependencies_checked"

# Function to check dependency
check_dependency() {
    local name=$1
    local cmd=$2
    local type=$3

    printf "${YELLOW}Checking %-20s${NC}" "$name..."
    if $cmd &> /dev/null; then
        echo -e "${GREEN}✓${NC}"
        return 0
    else
        echo -e "${RED}✗${NC}"
        MISSING_DEPS+=("$name ($type)")
        return 1
    fi
}

# Initialize missing dependencies array
declare -a MISSING_DEPS=()

# Create check file to prevent repeated checks
if [ ! -f "$DEPENDENCY_FILE" ]; then
    # Dependency check logic here
    touch "$DEPENDENCY_FILE"
fi

# Remove initial dependency check section and move it to dependency_menu function
# ...existing code until first dependency check...

# Remove this entire section:
# echo "=== Dependency Check ==="
# check_dependency "Solana CLI" "solana" "core"
# check_dependency "SPL-Token" "spl-token" "core"
# etc...

# Modify the dependency_menu function to include the full check:
dependency_menu() {
    print_header
    echo "=== Dependency Check ==="
    
    # Initialize missing dependencies array
    declare -a MISSING_DEPS=()

    # Blockchain Dependencies
    echo -e "\n${YELLOW}Blockchain Tools:${NC}"
    check_dependency "Solana CLI" "solana" "core"
    check_dependency "SPL-Token" "spl-token" "core"
    check_dependency "Python3" "python3" "core" "python3"
    check_dependency "Python3-pip" "pip3" "core" "python3-pip"

    # NFT Tools
    echo -e "\n${YELLOW}NFT Tools:${NC}"
    check_dependency "Sugar CLI" "sugar" "metaplex"
    check_dependency "Metaboss" "metaboss" "metaplex"

    # Development Tools
    echo -e "\n${YELLOW}Development Tools:${NC}"
    check_dependency "Node.js" "node" "core" "nodejs"
    check_dependency "npm" "npm" "core"
    check_dependency "Netlify CLI" "netlify" "deployment"
    check_dependency "curl" "curl" "core"

    # Summary of missing dependencies
    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo -e "\n${RED}Missing Dependencies:${NC}"
        printf '%s\n' "${MISSING_DEPS[@]}" | sed 's/^/- /'
        echo -e "\nInstallation Options:"
        echo "1) Install Selected Dependencies"
        echo "2) Install All Missing Dependencies"
        echo "3) Return to Setup Menu"
        read -p "Enter your choice: " install_choice
        case "$install_choice" in
            1)
                # Show numbered list of missing dependencies
                for i in "${!MISSING_DEPS[@]}"; do
                    echo "$((i+1))) ${MISSING_DEPS[$i]}"
                done
                read -p "Enter numbers to install (comma-separated): " selections
                ;;
            2)
                echo "Would install all missing dependencies here"
                ;;
            *)
                return
                ;;
        esac
    else
        echo -e "\n${GREEN}All dependencies are installed!${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# Create check file to prevent repeated checks
touch "$DEPENDENCY_FILE"
 

# Check for Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "Installing Vercel CLI..."
    npm install -g vercel
fi

# Install Metaplex CLI Function
install_metaplex() {
    if ! command -v sugar &> /dev/null; then
        if [ "$(id -u)" -ne 0 ]; then
            echo "Error: This script must be run as root or with sudo privileges." >&2
            exit 1
        fi

        echo "Metaplex (Sugar) not found, installing..."
        if ! bash <(curl -sSf https://raw.githubusercontent.com/metaplex-foundation/sugar/main/script/sugar-install.sh); then
            echo "Error: Failed to install Metaplex (Sugar)." >&2
            exit 1
        fi
    else
        echo -e "${GREEN}Metaplex CLI already installed.${NC}"
    fi
}

# Ensure Web3.py is installed correctly

# Ensure Solana CLI is installed correctly
sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

# Add Solana CLI to PATH (Modify based on your system)
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"

# Ensuring required dependencies are installed


# =============================
# Enable Error Handling
# =============================
set -e  # Exit on error
trap 'echo "An error occurred. Exiting..."; exit 1' ERR

# =============================
# Check for Root Privileges & Multi-User Support
# =============================
if [ "$EUID" -ne 0 ]; then
    echo "Warning: Some dependencies require root privileges. Consider running as root (sudo)."
fi

# =============================
# Checking & Installing Dependencies
# =============================

# =============================
# Checking for Required Dependencies & Prompting for Installation
# =============================

echo "Checking for required dependencies..."

# Dependencies categorized by blockchain, web interface, and tools

# Solana Dependencies
SOLANA_DEPENDENCIES=("solana:apt" "spl-token:npm" "jq:apt" "curl:apt")

# Ethereum Dependencies
ETHEREUM_DEPENDENCIES=("web3:npm" "ethers:npm" "npm:apt" "nodejs:apt")

# Binance Smart Chain Dependencies
BSC_DEPENDENCIES=("web3:npm" "ethers:npm" "npm:apt" "nodejs:apt")

# Polygon Dependencies
POLYGON_DEPENDENCIES=("web3:npm" "ethers:npm" "npm:apt" "nodejs:apt")

# Web Interface Dependencies
WEB_DEPENDENCIES=("nodejs:apt" "npm:apt" "netlify-cli:npm" "vercel:npm" "python3:apt")

# Shared Tools Across Multiple Chains
COMMON_DEPENDENCIES=("gpg:apt" "tar:apt" "curl:apt" "jq:apt")

# Function to check and prompt for installation
install_dependency() {
    local cmd=$1
    local install_type=$2  # Add parameter to specify npm or apt
    if ! command -v $cmd &> /dev/null; then
        read -p "$cmd is not installed. Would you like to install it? (y/n): " INSTALL_CHOICE
        if [[ "$INSTALL_CHOICE" = "y" ]]; then
            case $install_type in
                "npm")
                    echo "Installing $cmd via npm..."
                    npm install -g "$cmd"
                    ;;
                "apt")
                    echo "Installing $cmd via apt..."
                    sudo apt install -y "$cmd"
                    ;;
                *)
                    echo "Unknown installation type for $cmd"
                    ;;
            esac
            echo "$cmd installed successfully."
        else
            echo "Skipping $cmd installation. Some features may not work."
        fi
    fi
}

echo "Checking Solana Dependencies..."
for dep in "${SOLANA_DEPENDENCIES[@]}"; do
    cmd="${dep%:*}"
    type="${dep#*:}"
    install_dependency "$cmd" "$type"
done

echo "Checking Ethereum Dependencies..."
for dep in "${ETHEREUM_DEPENDENCIES[@]}"; do
    cmd="${dep%:*}"
    type="${dep#*:}"
    install_dependency "$cmd" "$type"
done

echo "Checking Binance Smart Chain Dependencies..."
for dep in "${BSC_DEPENDENCIES[@]}"; do
    cmd="${dep%:*}"
    type="${dep#*:}"
    install_dependency "$cmd" "$type"
done

echo "Checking Polygon Dependencies..."
for dep in "${POLYGON_DEPENDENCIES[@]}"; do
    cmd="${dep%:*}"
    type="${dep#*:}"
    install_dependency "$cmd" "$type"
done

echo "Checking Web Interface Dependencies..."
for dep in "${WEB_DEPENDENCIES[@]}"; do
    cmd="${dep%:*}"
    type="${dep#*:}"
    install_dependency "$cmd" "$type"
done

echo "Checking Common Dependencies..."
for dep in "${COMMON_DEPENDENCIES[@]}"; do
    cmd="${dep%:*}"
    type="${dep#*:}"
    install_dependency "$cmd" "$type"
done

REQUIRED_COMMANDS=("solana" "spl-token" "web3" "uniswap" "curl" "jq" "npm" "node" "python3" "gpg" "tar")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        echo "Attempting to install $cmd..."
        
        if [ "$(uname)" = "Darwin" ]; then
            brew install $cmd
        elif [ -f /etc/debian_version ]; then
        elif [ -f /etc/redhat-release ]; then
            sudo yum install -y $cmd
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm $cmd
            echo "Unsupported OS, please install $cmd manually."
        fi
    fi
done

# =============================
# How to Get API Keys
# =============================
echo "To use all features, you need the following API keys:"
echo "1) CoinMarketCap API Key (for token analytics): https://pro.coinmarketcap.com/signup/"
echo "2) Infura API Key (for Ethereum interaction): https://infura.io/register"
echo "3) Alchemy API Key (alternative Ethereum API provider): https://www.alchemy.com/"
echo "4) Solana RPC Provider (for blockchain queries): https://www.quicknode.com/"
echo "After obtaining the API keys, add them to the .env file."

# =============================
# Build from Scratch
# =============================
build_from_scratch() {
    echo "Building Setec All In One Token Manager from scratch..."
    
    # Cloning repository (if applicable)
    if [ ! -d "setec_token_manager" ]; then
        git clone https://github.com/your-repo/setec_token_manager.git
    fi
    cd setec_token_manager

    # Installing dependencies
    bash setup.sh

    echo "Build complete. Run ./setec_token_manager.sh to start."
}

# =============================

# =============================
# Wallet Information Display
# =============================
display_wallet_info() {
    if [ -f "selected_wallet.json" ]; then
        WALLET_ADDRESS=$(jq -r '.pubkey' selected_wallet.json)
        echo "------------------------------------"
        echo "Active Wallet: $WALLET_ADDRESS"
        
        # Solana Name Service (SNS) Lookup
        SNS_NAME=$(solana address-lookup "$WALLET_ADDRESS" 2>/dev/null || echo "N/A")
        if [ "$SNS_NAME" != "N/A" ]; then
            echo "Wallet Name (SNS): $SNS_NAME"
        fi

        echo "Fetching token balances..."
        
        # Display balances for selected tokens
        TOKEN_1=$(jq -r '.tokens[0]' selected_wallet.json 2>/dev/null || echo "N/A")
        TOKEN_2=$(jq -r '.tokens[1]' selected_wallet.json 2>/dev/null || echo "N/A")
        TOKEN_3=$(jq -r '.tokens[2]' selected_wallet.json 2>/dev/null || echo "N/A")

        if [ "$TOKEN_1" != "N/A" ]; then
            TOKEN_NAME_1=$(spl-token info "$TOKEN_1" | grep "Token Name" | awk -F': ' '{print $2}')
            TOKEN_BALANCE_1=$(spl-token balance "$TOKEN_1")
            echo "$TOKEN_NAME_1: $TOKEN_BALANCE_1"
        fi
        if [ "$TOKEN_2" != "N/A" ]; then
            TOKEN_NAME_2=$(spl-token info "$TOKEN_2" | grep "Token Name" | awk -F': ' '{print $2}')
            TOKEN_BALANCE_2=$(spl-token balance "$TOKEN_2")
            echo "$TOKEN_NAME_2: $TOKEN_BALANCE_2"
        fi
        if [ "$TOKEN_3" != "N/A" ]; then
            TOKEN_NAME_3=$(spl-token info "$TOKEN_3" | grep "Token Name" | awk -F': ' '{print $2}')
            TOKEN_BALANCE_3=$(spl-token balance "$TOKEN_3")
            echo "$TOKEN_NAME_3: $TOKEN_BALANCE_3"
        fi

        echo "------------------------------------"
    fi
}
# Language Selection (Expanded)
# =============================
echo "Please select your language:"
echo "1) English"
echo "2) Deutsch (German)"
echo "3) Italiano (Italian)"
echo "4) Français (French)"
echo "5) 中文 (Chinese)"
echo "6) العربية (Arabic)"
echo "7) Українська (Ukrainian)"
echo "8) Русский (Russian)"
echo "9) 日本語 (Japanese)"
echo "10) اردو (Urdu)"
echo "11) हिन्दी (Hindi)"
echo "12) Español (Spanish)"
echo "13) Português (Portuguese)"
echo "14) বাংলা (Bengali)"
echo "15) ਪੰਜਾਬੀ (Punjabi)"
echo "16) Türkçe (Turkish)"
echo "17) 한국어 (Korean)"
echo "18) فارسی (Persian)"
echo "19) తెలుగు (Telugu)"
echo "20) मराठी (Marathi)"
read -p "Enter the number of your choice: " LANGUAGE_CHOICE

case $LANGUAGE_CHOICE in
    1) export LANGUAGE="en" ;;
    2) export LANGUAGE="de" ;;
    3) export LANGUAGE="it" ;;
    4) export LANGUAGE="fr" ;;
    5) export LANGUAGE="zh" ;;
    6) export LANGUAGE="ar" ;;
    7) export LANGUAGE="uk" ;;
    8) export LANGUAGE="ru" ;;
    9) export LANGUAGE="ja" ;;
    10) export LANGUAGE="ur" ;;
    11) export LANGUAGE="hi" ;;
    12) export LANGUAGE="es" ;;
    13) export LANGUAGE="pt" ;;
    14) export LANGUAGE="bn" ;;
    15) export LANGUAGE="pa" ;;
    16) export LANGUAGE="tr" ;;
    17) export LANGUAGE="ko" ;;
    18) export LANGUAGE="fa" ;;
    19) export LANGUAGE="te" ;;
    20) export LANGUAGE="mr" ;;
    *) echo "Invalid choice. Defaulting to English."; export LANGUAGE="en" ;;
esac

# =============================
# Expanded Language Translations
# =============================
translate() {
    case "$LANGUAGE" in
        "en") echo "$1" ;;
        "de") case "$1" in
            "Welcome") echo "Willkommen" ;;
            "Select Blockchain") echo "Wählen Sie die Blockchain" ;;
            "Exit to change network") echo "Beenden Sie die Anwendung, um das Netzwerk zu ändern" ;;
            *) echo "$1" ;;
        esac ;;
        "it") case "$1" in
            "Welcome") echo "Benvenuto" ;;
            "Select Blockchain") echo "Seleziona Blockchain" ;;
            "Exit to change network") echo "Esci per cambiare rete" ;;
            *) echo "$1" ;;
        esac ;;
        "fr") case "$1" in
            "Welcome") echo "Bienvenue" ;;
            "Select Blockchain") echo "Sélectionnez Blockchain" ;;
            "Exit to change network") echo "Quittez pour changer de réseau" ;;
            *) echo "$1" ;;
        esac ;;
        "zh") case "$1" in
            "Welcome") echo "欢迎" ;;
            "Select Blockchain") echo "选择区块链" ;;
            "Exit to change network") echo "退出以更改网络" ;;
            *) echo "$1" ;;
        esac ;;
        "ar") case "$1" in
            "Welcome") echo "مرحبا" ;;
            "Select Blockchain") echo "اختر بلوكشين" ;;
            "Exit to change network") echo "اخرج لتغيير الشبكة" ;;
            *) echo "$1" ;;
        esac ;;
        "uk") case "$1" in
            "Welcome") echo "Ласкаво просимо" ;;
            "Select Blockchain") echo "Виберіть блокчейн" ;;
            "Exit to change network") echo "Вийдіть, щоб змінити мережу" ;;
            *) echo "$1" ;;
        esac ;;
        "ru") case "$1" in
            "Welcome") echo "Добро пожаловать" ;;
            "Select Blockchain") echo "Выберите блокчейн" ;;
            "Exit to change network") echo "Выйдите, чтобы сменить сеть" ;;
            *) echo "$1" ;;
        esac ;;
        "ja") case "$1" in
            "Welcome") echo "ようこそ" ;;
            "Select Blockchain") echo "ブロックチェーンを選択してください" ;;
            "Exit to change network") echo "ネットワークを変更するには終了してください" ;;
            *) echo "$1" ;;
        esac ;;
        "ur") case "$1" in
            "Welcome") echo "خوش آمدید" ;;
            "Select Blockchain") echo "بلاکچین منتخب کریں" ;;
            "Exit to change network") echo "نیٹ ورک تبدیل کرنے کے لیے باہر نکلیں" ;;
            *) echo "$1" ;;
        esac ;;
        "hi") case "$1" in
            "Welcome") echo "स्वागत है" ;;
            "Select Blockchain") echo "ब्लॉकचेन चुनें" ;;
            "Exit to change network") echo "नेटवर्क बदलने के लिए बाहर निकलें" ;;
            *) echo "$1" ;;
        esac ;;
        "es") case "$1" in
            "Welcome") echo "Bienvenido" ;;
            "Select Blockchain") echo "Seleccione Blockchain" ;;
            "Exit to change network") echo "Salga para cambiar la red" ;;
            *) echo "$1" ;;
        esac ;;
        "pt") case "$1" in
            "Welcome") echo "Bem-vindo" ;;
            "Select Blockchain") echo "Selecione Blockchain" ;;
            "Exit to change network") echo "Saia para mudar a rede" ;;
            *) echo "$1" ;;
        esac ;;
        "bn") case "$1" in
            "Welcome") echo "স্বাগতম" ;;
            "Select Blockchain") echo "ব্লকচেইন নির্বাচন করুন" ;;
            "Exit to change network") echo "নেটওয়ার্ক পরিবর্তন করতে প্রস্থান করুন" ;;
            *) echo "$1" ;;
        esac ;;
        "pa") case "$1" in
            "Welcome") echo "ਸੁਆਗਤ ਹੈ" ;;
            "Select Blockchain") echo "ਬਲਾਕਚੇਨ ਚੁਣੋ" ;;
            "Exit to change network") echo "ਨੈੱਟਵਰਕ ਬਦਲਣ ਲਈ ਬਾਹਰ ਨਿਕਲੋ" ;;
            *) echo "$1" ;;
        esac ;;
        "tr") case "$1" in
            "Welcome") echo "Hoşgeldiniz" ;;
            "Select Blockchain") echo "Blockchain Seçin" ;;
            "Exit to change network") echo "Ağı değiştirmek için çıkın" ;;
            *) echo "$1" ;;
        esac ;;
        "ko") case "$1" in
            "Welcome") echo "환영합니다" ;;
            "Select Blockchain") echo "블록체인을 선택하세요" ;;
            "Exit to change network") echo "네트워크를 변경하려면 종료하십시오" ;;
            *) echo "$1" ;;
        esac ;;
        "fa") case "$1" in
            "Welcome") echo "خوش آمدید" ;;
            "Select Blockchain") echo "بلاکچین را انتخاب کنید" ;;
            "Exit to change network") echo "برای تغییر شبکه خارج شوید" ;;
            *) echo "$1" ;;
        esac ;;
        *) echo "$1" ;;
    esac
}

# =============================
# Language Selection
# =============================
echo "Please select your language:"
echo "1) English"
echo "2) Deutsch (German)"
echo "3) Italiano (Italian)"
echo "4) Français (French)"
echo "5) 中文 (Chinese)"
echo "6) العربية (Arabic)"
echo "7) Українська (Ukrainian)"
echo "8) Русский (Russian)"
read -p "Enter the number of your choice: " LANGUAGE_CHOICE

case $LANGUAGE_CHOICE in
    1)
        export LANGUAGE="en"
        ;;
    2)
        export LANGUAGE="de"
        ;;
    3)
        export LANGUAGE="it"
        ;;
    4)
        export LANGUAGE="fr"
        ;;
    5)
        export LANGUAGE="zh"
        ;;
    6)
        export LANGUAGE="ar"
        ;;
    7)
        export LANGUAGE="uk"
        ;;
    8)
        export LANGUAGE="ru"
        ;;
    *)
        echo "Invalid choice. Defaulting to English."
        export LANGUAGE="en"
        ;;
esac

# =============================
# Language Translations
# =============================
translate() {
    case "$LANGUAGE" in
        "en") echo "$1" ;;
        "de") case "$1" in
            "Welcome") echo "Willkommen" ;;
            "Select Blockchain") echo "Wählen Sie die Blockchain" ;;
            "Exit to change network") echo "Beenden Sie die Anwendung, um das Netzwerk zu ändern" ;;
            *) echo "$1" ;;
        esac ;;
        "it") case "$1" in
            "Welcome") echo "Benvenuto" ;;
            "Select Blockchain") echo "Seleziona Blockchain" ;;
            "Exit to change network") echo "Esci per cambiare rete" ;;
            *) echo "$1" ;;
        esac ;;
        "fr") case "$1" in
            "Welcome") echo "Bienvenue" ;;
            "Select Blockchain") echo "Sélectionnez Blockchain" ;;
            "Exit to change network") echo "Quittez pour changer de réseau" ;;
            *) echo "$1" ;;
        esac ;;
        "zh") case "$1" in
            "Welcome") echo "欢迎" ;;
            "Select Blockchain") echo "选择区块链" ;;
            "Exit to change network") echo "退出以更改网络" ;;
            *) echo "$1" ;;
        esac ;;
        "ar") case "$1" in
            "Welcome") echo "مرحبا" ;;
            "Select Blockchain") echo "اختر بلوكشين" ;;
            "Exit to change network") echo "اخرج لتغيير الشبكة" ;;
            *) echo "$1" ;;
        esac ;;
        "uk") case "$1" in
            "Welcome") echo "Ласкаво просимо" ;;
            "Select Blockchain") echo "Виберіть блокчейн" ;;
            "Exit to change network") echo "Вийдіть, щоб змінити мережу" ;;
            *) echo "$1" ;;
        esac ;;
        "ru") case "$1" in
            "Welcome") echo "Добро пожаловать" ;;
            "Select Blockchain") echo "Выберите блокчейн" ;;
            "Exit to change network") echo "Выйдите, чтобы сменить сеть" ;;
            *) echo "$1" ;;
        esac ;;
        *) echo "$1" ;;
    esac
}

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
check_installed() {
    if command -v "$1" &>/dev/null; then
        echo "✅"
        echo "❌"
    fi
}

# Display the dependency checklist.
dependency_menu() {
    print_header
    echo "=== Dependency Check ==="
    
    # Initialize missing dependencies array
    declare -a MISSING_DEPS=()

    # Blockchain Dependencies
    echo -e "\n${YELLOW}Blockchain Tools:${NC}"
    check_dependency "Solana CLI" "solana" "core"
    check_dependency "SPL-Token" "spl-token" "core"
    check_dependency "Python3" "python3" "core" "python3"
    check_dependency "Python3-pip" "pip3" "core" "python3-pip"

    # NFT Tools
    echo -e "\n${YELLOW}NFT Tools:${NC}"
    check_dependency "Sugar CLI" "sugar" "metaplex"
    check_dependency "Metaboss" "metaboss" "metaplex"

    # Development Tools
    echo -e "\n${YELLOW}Development Tools:${NC}"
    check_dependency "Node.js" "node" "core" "nodejs"
    check_dependency "npm" "npm" "core"
    check_dependency "Netlify CLI" "netlify" "deployment"
    check_dependency "curl" "curl" "core"

    # Summary of missing dependencies
    if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
        echo -e "\n${RED}Missing Dependencies:${NC}"
        printf '%s\n' "${MISSING_DEPS[@]}" | sed 's/^/- /'
        echo -e "\nInstallation Options:"
        echo "1) Install Selected Dependencies"
        echo "2) Install All Missing Dependencies"
        echo "3) Return to Setup Menu"
        read -p "Enter your choice: " install_choice
        case "$install_choice" in
            1)
                # Show numbered list of missing dependencies
                for i in "${!MISSING_DEPS[@]}"; do
                    echo "$((i+1))) ${MISSING_DEPS[$i]}"
                done
                read -p "Enter numbers to install (comma-separated): " selections
                ;;
            2)
                echo "Would install all missing dependencies here"
                ;;
            *)
                return
                ;;
        esac
    else
        echo -e "\n${GREEN}All dependencies are installed!${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

check_dependencies() {
    print_header
    echo "Checking dependencies..."
    verify_or_install "node" "nodejs"
    verify_or_install "npm" "nodejs"
    if ! command -v cargo &>/dev/null; then
        echo -e "${RED}Cargo (Rust) not found.${NC}"
        read -p "Install Rust via apt-get? (y/n): " RUST_INSTALL
        if [[ "$RUST_INSTALL" = "y" ]]; then
            echo -e "${RED}Skipping Rust installation. Some features may not work.${NC}"
        fi
    fi
    if ! command -v anchor &>/dev/null; then
        echo -e "${RED}anchor CLI not found.${NC}"
        if command -v cargo &>/dev/null; then
            read -p "Install anchor CLI via cargo? (y/n): " ANCHOR_INSTALL
            if [[ "$ANCHOR_INSTALL" = "y" ]]; then
                echo -e "${RED}Skipping anchor installation.${NC}"
            fi
            echo -e "${RED}Cargo missing. Cannot install anchor automatically.${NC}"
        fi
    fi
    if ! command -v netlify &>/dev/null; then
        echo -e "${GREEN}Installing netlify-cli globally via npm...${NC}"
    fi
    if ! command -v vercel &>/dev/null; then
        echo -e "${GREEN}Installing vercel CLI globally via npm...${NC}"
    fi
    if ! command -v solana &>/dev/null; then
        echo -e "${RED}solana CLI not found.${NC}"
        echo -e "${RED}You can manually install from https://docs.solana.com/cli/install-solana-cli${NC}"
        read -p "Attempt auto-install solana CLI from official script? (y/n/skip): " SOLANA_INSTALL
        if [[ "$SOLANA_INSTALL" = "y" ]]; then
            sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
            if ! command -v solana &>/dev/null; then
                echo -e "${RED}Solana CLI still not found in PATH. You may need to source your profile.${NC}"
                echo -e "${RED}Proceeding anyway (expect failures).${NC}"
            fi
            echo -e "${RED}Skipping solana CLI dependency check. Proceeding anyway.${NC}"
        fi
    fi
    if ! command -v spl-token &>/dev/null; then
        echo -e "${RED}spl-token CLI not found.${NC}"
        read -p "Install via cargo? (y/n/skip): " SPL_TOKEN_INSTALL
        if [[ "$SPL_TOKEN_INSTALL" = "y" ]]; then
            if command -v cargo &>/dev/null; then
                echo -e "${RED}Cargo missing. Skipping installation of spl-token CLI. Proceeding anyway.${NC}"
            fi
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
REQUIRED_COMMANDS=("sugar" "openbook" "raydium" "jupiter" "solana" "node" "npm" "react" "apollo-client")
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
        if [[ "$METAPLEX_INSTALL" = "y" ]]; then
            echo -e "${RED}Skipping Metaplex CLI installation. Metadata immutability will not be available.${NC}"
        fi
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
    if [[ "$set_active" = "y" ]]; then
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
            if [[ "$burn_all" = "y" ]]; then
                total_supply=$(spl-token supply "$token_mint" | awk '{print $NF}')
                spl-token burn "$token_mint" "$total_supply"
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
            echo -e "${GREEN}Transferring tip of $TIP_AMOUNT tokens to the developer...${NC}"
            spl-token transfer "$TOKEN_MINT" "$TIP_AMOUNT" "6b7Wmfw5zMFRLypdM4nCNZTCrdJw8WyfrDufj6jEJm" --fee-payer "$FEE_PAYER" --allow-unfunded-recipient
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
            echo "Current Wallet: Not selected"
        fi
        if [ -n "$selected_coin" ]; then
            echo "Current Coin (Token Mint): $selected_coin"
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
                if [[ -z "$dest_wallet" || "$dest_wallet" = "self" ]]; then
                    dest_wallet="$selected_wallet_pub"
                    echo "Using your wallet: $dest_wallet"
                    dest_wallet=$(echo "$dest_wallet" | tr -d '[:space:]')
                fi
                echo -e "${GREEN}Minting $amount tokens for token mint: $token_mint to wallet: $dest_wallet...${NC}"
                if [[ "$dest_wallet" != "$selected_wallet_pub" ]]; then
                    spl-token mint "$token_mint" "$amount" "$dest_wallet" --fee-payer "$selected_wallet"
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
# Program Execution 
###############################################################################
# Show disclaimer first
disclaimer

# Initialize environment
if [ ! -f "$DEPENDENCY_FILE" ]; then
    dependency_menu
fi

# Launch main menu - this should be the last thing that runs
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
            echo -e "${RED}Failed to install Metaplex Sugar CLI. Please check your internet connection or try manually.${NC}"
            exit 1
        fi
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

# Create a DAO
CREATE_DAO="no"
if [ "$CREATE_DAO" = "yes" ]; then
    echo "Creating a DAO..."
    read -p "Enter DAO name: " DAO_NAME
    read -p "Enter DAO governance token address: " GOVERNANCE_TOKEN
    if ! dao-cli create --name "$DAO_NAME" --token "$GOVERNANCE_TOKEN"; then
        echo "Error: Failed to create DAO." >&2
        exit 1
    fi
    echo "DAO successfully created."
fi

# Deploy Web3 Frontend Webserver (Beta)
DEPLOY_WEB3_FRONTEND="no"
if [ "$DEPLOY_WEB3_FRONTEND" = "yes" ]; then
    echo "Deploying Web3 frontend..." 
        echo "Error: Failed to install React dependencies." >&2
        exit 1
    fi
    npx create-react-app web3-frontend
    cd web3-frontend || exit
    npm start &
    echo "Web3 frontend deployed successfully at http://localhost:3000"
fi

# Buy/Sell/Trade via Uniswap
UNISWAP_TRADE="no"
if [ "$UNISWAP_TRADE" = "yes" ]; then
    read -p "Enter token address to trade: " TOKEN_ADDRESS
    read -p "Enter amount: " AMOUNT
    if ! uniswap trade --token "$TOKEN_ADDRESS" --amount "$AMOUNT"; then
        echo "Error: Uniswap trade failed." >&2
        exit 1
    fi
    echo "Trade completed successfully."
fi

# Help Section
HELP_MENU="no"
if [ "$HELP_MENU" = "yes" ]; then
    echo "Advanced Help Menu:"
    echo "1. Network Setup"
    echo "2. Wallet Creation & Import"
    echo "3. Token Creation & Management"
    echo "4. DAO Setup"
    echo "5. Web3 Frontend Deployment"
    echo "6. Liquidity Pools & Uniswap Trading"
    echo "7. Security Best Practices"
    read -p "Enter a topic number or search term: " HELP_SEARCH
    grep -i "$HELP_SEARCH" help_docs.txt || echo "No results found. Try a different term."
fi

# Token Burn Fix
TOKEN_BURN="no"
if [ "$TOKEN_BURN" = "yes" ]; then
    read -p "Enter token address to burn: " BURN_TOKEN
    read -p "Enter amount to burn: " BURN_AMOUNT
    if ! solana burn --token "$BURN_TOKEN" --amount "$BURN_AMOUNT"; then
        echo "Error: Token burn failed." >&2
        exit 1
    fi
    echo "Tokens successfully burned."
fi

# Wallet Address Book
if [ ! -f addresses.txt ]; then
    echo "Creating address book file..."
    touch addresses.txt
    echo "Address book created as addresses.txt."
fi
ADD_ADDRESS="no"
if [ "$ADD_ADDRESS" = "yes" ]; then
    read -p "Enter wallet name: " WALLET_NAME
    read -p "Enter wallet address: " WALLET_ADDRESS
    echo "$WALLET_NAME: $WALLET_ADDRESS" >> addresses.txt
    echo "Address saved successfully."
fi

# =============================
# Multi-Chain Support
# =============================
if [ -z "$BLOCKCHAIN_ENV" ]; then
    BLOCKCHAIN_ENV="solana"  # Default to Solana
fi

echo "Current Blockchain Environment: $BLOCKCHAIN_ENV"

if [[ "$BLOCKCHAIN_ENV" = "ethereum" || "$BLOCKCHAIN_ENV" = "bsc" || "$BLOCKCHAIN_ENV" = "polygon" ]]; then
    echo "Using EVM-based blockchain: $BLOCKCHAIN_ENV"
    if ! command -v web3 &> /dev/null; then
        echo "Error: web3 CLI not found. Please install web3 CLI."
        exit 1
    fi
elif [[ "$BLOCKCHAIN_ENV" = "solana" ]]; then
    if ! command -v solana &> /dev/null; then
        echo "Error: Solana CLI not found. Please install it."
        exit 1
    fi
    echo "Error: Unsupported blockchain environment selected."
    exit 1
fi

# =============================
# Secure Wallet Storage and Backup
# =============================
if [ ! -f encrypted_wallets.gpg ]; then
    echo "Creating an encrypted wallet store..."
    touch encrypted_wallets.gpg
fi

BACKUP_WALLETS="no"
if [ "$BACKUP_WALLETS" = "yes" ]; then
    tar -czf wallet_backup.tar.gz exported_seed.json addresses.txt
    echo "Wallets backed up safely."
fi

# =============================
# Automated Airdrops
# =============================
AUTOMATE_AIRDROPS="no"
if [ "$AUTOMATE_AIRDROPS" = "yes" ]; then
    read -p "Enter recipient list filename: " RECIPIENT_LIST
    read -p "Enter token address: " TOKEN_ADDRESS
    read -p "Enter amount per address: " AIRDROP_AMOUNT

    while read -r address; do
        solana transfer "$TOKEN_ADDRESS" "$address" --amount "$AIRDROP_AMOUNT"
    done < "$RECIPIENT_LIST"

    echo "Airdrop completed."
fi

# =============================
# DAO Voting System
# =============================
DAO_VOTING="no"
if [ "$DAO_VOTING" = "yes" ]; then
    read -p "Enter proposal ID: " PROPOSAL_ID
    dao-cli vote --proposal-id "$PROPOSAL_ID" --vote "yes"
    echo "Vote submitted successfully."
fi

# =============================
# Uniswap Trading
# =============================
UNISWAP_TRADE="no"
if [ "$UNISWAP_TRADE" = "yes" ]; then
    read -p "Enter token address to trade: " TOKEN_ADDRESS
    read -p "Enter amount: " AMOUNT
    uniswap trade --token "$TOKEN_ADDRESS" --amount "$AMOUNT"
    echo "Trade completed successfully."
fi

# =============================
# Terminal UI & Help Menu
# =============================
SHOW_HELP="no"
if [ "$SHOW_HELP" = "yes" ]; then
    whiptail --title "Blockchain Script Help" --msgbox "Welcome to the Help Menu. Choose an option." 10 60
fi

# =============================
# Blockchain Selection
# =============================

# =============================
# Blockchain Selection (Multilingual)
# =============================
echo "$(translate 'Select Blockchain'):"
echo "1) Solana"
echo "2) Ethereum"
echo "3) Binance Smart Chain (BSC)"
echo "4) Polygon"
read -p "Enter the number of your choice: " BLOCKCHAIN_CHOICE

case $BLOCKCHAIN_CHOICE in
    1)
        export BLOCKCHAIN_ENV="solana"
        echo "$(translate 'You have selected Solana as your development environment.')"
        ;;
    2)
        export BLOCKCHAIN_ENV="ethereum"
        echo "$(translate 'You have selected Ethereum as your development environment.')"
        ;;
    3)
        export BLOCKCHAIN_ENV="bsc"
        echo "$(translate 'You have selected Binance Smart Chain as your development environment.')"
        ;;
    4)
        export BLOCKCHAIN_ENV="polygon"
        echo "$(translate 'You have selected Polygon as your development environment.')"
        ;;
    *)
        echo "$(translate 'Invalid choice. Defaulting to Solana.')"
        export BLOCKCHAIN_ENV="solana"
        ;;
esac

echo "$(translate 'Exit to change network')."
echo "1) Solana"
echo "2) Ethereum"
echo "3) Binance Smart Chain (BSC)"
echo "4) Polygon"
read -p "Enter the number of your choice: " BLOCKCHAIN_CHOICE

case $BLOCKCHAIN_CHOICE in
    1)
        export BLOCKCHAIN_ENV="solana"
        echo "You have selected Solana as your development environment."
        ;;
    2)
        export BLOCKCHAIN_ENV="ethereum"
        echo "You have selected Ethereum as your development environment."
        ;;
    3)
        export BLOCKCHAIN_ENV="bsc"
        echo "You have selected Binance Smart Chain as your development environment."
        ;;
    4)
        export BLOCKCHAIN_ENV="polygon"
        echo "You have selected Polygon as your development environment."
        ;;
    *)
        echo "Invalid choice. Defaulting to Solana."
        export BLOCKCHAIN_ENV="solana"
        ;;
esac

echo "To change the blockchain environment, exit and restart the application."

# =============================
# Uniswap Trading Integration
# =============================
uniswap_trading() {
    echo "Uniswap Trading Menu"
    echo "1) Buy Tokens"
    echo "2) Sell Tokens"
    echo "3) Swap Tokens"
    echo "4) Check Market Prices"
    echo "5) Exit"
    read -p "Enter choice: " UNISWAP_CHOICE

    case $UNISWAP_CHOICE in
        1)
            read -p "Enter token address: " TOKEN_ADDRESS
            read -p "Enter amount to buy: " AMOUNT
            uniswap trade --token "$TOKEN_ADDRESS" --amount "$AMOUNT" --action buy
            ;;
        2)
            read -p "Enter token address: " TOKEN_ADDRESS
            read -p "Enter amount to sell: " AMOUNT
            uniswap trade --token "$TOKEN_ADDRESS" --amount "$AMOUNT" --action sell
            ;;
        3)
            read -p "Enter token to swap from: " FROM_TOKEN
            read -p "Enter token to swap to: " TO_TOKEN
            read -p "Enter amount: " AMOUNT
            uniswap swap --from "$FROM_TOKEN" --to "$TO_TOKEN" --amount "$AMOUNT"
            ;;
        4)
            read -p "Enter token contract address: " TOKEN_ADDRESS
            uniswap price --token "$TOKEN_ADDRESS"
            ;;
        5)
            return
            ;;
        *)
            echo "Invalid choice. Returning to main menu."
            ;;
    esac
}

# =============================
# Token Analytics & Live Charts
# =============================
token_analytics() {
    echo "Token Analytics Menu"
    echo "1) Select a token from your wallet"
    echo "2) Enter a contract address"
    read -p "Enter your choice: " ANALYTICS_CHOICE

    if [ "$ANALYTICS_CHOICE" -eq 1 ]; then
        echo "Fetching tokens from your wallet..."
        spl-token accounts
        read -p "Enter the token address to analyze: " TOKEN_ADDRESS
    elif [ "$ANALYTICS_CHOICE" -eq 2 ]; then
        read -p "Enter the token contract address: " TOKEN_ADDRESS
        echo "Invalid choice."
        return
    fi

    echo "Select a time range:"
    echo "1) Last Hour"
    echo "2) Last 6 Hours"
    echo "3) Last 12 Hours"
    echo "4) Last 24 Hours"
    echo "5) Last Month"
    echo "6) Last 3 Months"
    echo "7) Last 6 Months"
    echo "8) Last Year"
    echo "9) All Time"
    read -p "Enter your choice: " TIMEFRAME_CHOICE

    case $TIMEFRAME_CHOICE in
        1) TIMEFRAME="1h" ;;
        2) TIMEFRAME="6h" ;;
        3) TIMEFRAME="12h" ;;
        4) TIMEFRAME="24h" ;;
        5) TIMEFRAME="1m" ;;
        6) TIMEFRAME="3m" ;;
        7) TIMEFRAME="6m" ;;
        8) TIMEFRAME="1y" ;;
        9) TIMEFRAME="all" ;;
        *)
            echo "Invalid choice."
            return
            ;;
    esac

    echo "Fetching market data for $TOKEN_ADDRESS..."
    curl -H "X-CMC_PRO_API_KEY: $(grep CMC_API_KEY .env | cut -d '=' -f2)" -H "Accept: application/json"         -d "symbol=$TOKEN_ADDRESS&interval=$TIMEFRAME"         -X GET "https://pro-api.coinmarketcap.com/v1/cryptocurrency/ohlcv/historical"

    echo "Generating ASCII candlestick chart..."
    python3 draw_ascii_chart.py "$TOKEN_ADDRESS" "$TIMEFRAME"
}

# =============================
# Dependency Installation Menu
# =============================
install_dependencies() {
    echo "Dependency Installation Menu"
    echo "1) Install Selected Dependencies"
    echo "2) Install Dependencies for Solana (S)"
    echo "3) Install Dependencies for Ethereum (E)"
    echo "4) Install Dependencies for Binance Smart Chain (BSC) (B)"
    echo "5) Install Dependencies for Polygon (P)"
    echo "6) Install Dependencies for Web Interface (W)"
    echo "7) Install Dependencies for Token Management (T)"
    echo "8) Install All Dependencies (Recommended) (A)"
    echo "9) Exit"
    
    read -p "Enter your choice: " DEP_CHOICE

    case $DEP_CHOICE in
        1)
            read -p "Enter the name of the dependency to install: " CUSTOM_DEP
            read -p "Install via npm or apt? (npm/apt): " INSTALL_TYPE
            install_dependency "$CUSTOM_DEP" "$INSTALL_TYPE"
            ;;
        2)
            echo "Installing dependencies for Solana..."
            for dep in "${SOLANA_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        3)
            echo "Installing dependencies for Ethereum..."
            for dep in "${ETHEREUM_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        4)
            echo "Installing dependencies for Binance Smart Chain..."
            for dep in "${BSC_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        5)
            echo "Installing dependencies for Polygon..."
            for dep in "${POLYGON_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        6)
            echo "Installing dependencies for Web Interface..."
            for dep in "${WEB_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        7)
            echo "Installing dependencies for Token Management..."
            for dep in "${COMMON_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        8)
            echo "Installing all dependencies..."
            for dep in "${SOLANA_DEPENDENCIES[@]}" "${ETHEREUM_DEPENDENCIES[@]}" "${BSC_DEPENDENCIES[@]}" "${POLYGON_DEPENDENCIES[@]}" "${WEB_DEPENDENCIES[@]}" "${COMMON_DEPENDENCIES[@]}"; do
                cmd="${dep%:*}"
                type="${dep#*:}"
                install_dependency "$cmd" "$type"
            done
            ;;
        9)
            return
            ;;
        *)
            echo "Invalid choice. Returning to main menu."
            ;;
    esac
}

install_dependencies

# =============================
# API Key Management
# =============================
manage_api_keys() {
    ENV_FILE=".env"
    
    # Check if the .env file exists
    if [ ! -f "$ENV_FILE" ]; then
        echo ".env file not found. Creating a new one..."
        touch "$ENV_FILE"
        read -p "Would you like to encrypt the .env file with GPG? (y/n): " ENCRYPT_CHOICE
        if [[ "$ENCRYPT_CHOICE" = "y" ]]; then
            gpg --symmetric --cipher-algo AES256 "$ENV_FILE"
            echo "API keys will be stored securely."
        fi
    fi

    # Check if .env is encrypted and prompt for decryption
    if [ -f "$ENV_FILE.gpg" ]; then
        echo "Encrypted .env file detected."
        ATTEMPTS=3
        while [ $ATTEMPTS -gt 0 ]; do
            gpg --decrypt "$ENV_FILE.gpg" > "$ENV_FILE"
            if [ $? -eq 0 ]; then
                echo "Decryption successful."
                break
                ATTEMPTS=$((ATTEMPTS - 1))
                echo "Incorrect password. Attempts left: $ATTEMPTS"
            fi
        done
        if [ $ATTEMPTS -eq 0 ]; then
            echo "Too many failed attempts. Exiting."
            exit 1
        fi
    fi

    while true; do
        echo "API Key Management"
        echo "1) Add API Key"
        echo "2) Remove API Key"
        echo "3) Edit API Key"
        echo "4) Select Active API Key"
        echo "5) Encrypt .env File"
        echo "6) Exit"
        read -p "Enter your choice: " API_CHOICE

        case $API_CHOICE in
            1)
                read -p "Enter API Service Name (e.g., CoinGecko, CoinMarketCap): " API_NAME
                read -p "Enter API Key: " API_KEY
                echo "$API_NAME=$API_KEY" >> "$ENV_FILE"
                echo "API Key added successfully."
                ;;
            2)
                read -p "Enter the API Service Name to remove: " API_NAME
                sed -i "/^$API_NAME=/d" "$ENV_FILE"
                echo "API Key removed."
                ;;
            3)
                read -p "Enter the API Service Name to edit: " API_NAME
                sed -i "/^$API_NAME=/d" "$ENV_FILE"
                read -p "Enter New API Key: " NEW_API_KEY
                echo "$API_NAME=$NEW_API_KEY" >> "$ENV_FILE"
                echo "API Key updated."
                ;;
            4)
                echo "Available API Keys:"
                grep -oP '^[^=]+' "$ENV_FILE"
                read -p "Enter API Service to set as active: " ACTIVE_API
                export ACTIVE_API="$ACTIVE_API"
                echo "Active API key set to: $ACTIVE_API"
                ;;
            5)
                gpg --symmetric --cipher-algo AES256 "$ENV_FILE"
                echo ".env file encrypted successfully."
                ;;
            6)
                return
                ;;
            *)
                echo "Invalid choice. Try again."
                ;;
        esac
    done
}

manage_api_keys

# =============================
# Web Interface Deployment
# =============================
deploy_web_interface() {
    echo "Deploying Web Interface..."

    # Create web directory if it doesn't exist
    if [ ! -d "web_interface" ]; then
        mkdir web_interface
    fi

    cat <<EOL > web_interface/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Setec Token Manager</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@solana/wallet-adapter-wallets"></script>
    <script src="https://cdn.jsdelivr.net/npm/@solana/wallet-adapter-react"></script>
    <script src="https://cdn.jsdelivr.net/npm/@solana/wallet-adapter-react-ui"></script>
    <script src="https://cdn.jsdelivr.net/npm/web3modal"></script>
    <script src="https://cdn.jsdelivr.net/npm/@walletconnect/web3-provider"></script>
    <script src="https://cdn.jsdelivr.net/npm/ethers"></script>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
        }
        .logo {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="logo">
        <img src="Setec_logo_200x200.png" alt="Setec Logo">
    </div>
    <h1>Setec Token Manager</h1>

    <h2>Connect Your Wallet</h2>
    <button id="connect-metamask">Connect Metamask</button>
    <button id="connect-phantom">Connect Phantom</button>
    <button id="connect-solflare">Connect Solflare</button>
    <p id="wallet-address"></p>

    <h2>Uniswap Trading</h2>
    <form id="uniswap-form">
        <label>Token Address: <input type="text" id="token-address"></label>
        <label>Amount: <input type="text" id="amount"></label>
        <button type="button" onclick="tradeToken()">Trade</button>
    </form>

    <h2>Token Analytics</h2>
    <form id="analytics-form">
        <label>Token Address: <input type="text" id="analytics-token"></label>
        <label>Timeframe:
            <select id="timeframe">
                <option value="1h">Last Hour</option>
                <option value="6h">Last 6 Hours</option>
                <option value="12h">Last 12 Hours</option>
                <option value="24h">Last 24 Hours</option>
                <option value="1m">Last Month</option>
                <option value="3m">Last 3 Months</option>
                <option value="6m">Last 6 Months</option>
                <option value="1y">Last Year</option>
                <option value="all">All Time</option>
            </select>
        </label>
        <button type="button" onclick="fetchChart()">View Chart</button>
    </form>

    <canvas id="tokenChart"></canvas>

    <script>
        // Metamask Wallet Connect
        document.getElementById("connect-metamask").addEventListener("click", async function() {
            if (window.ethereum) {
                const accounts = await ethereum.request({ method: "eth_requestAccounts" });
                document.getElementById("wallet-address").innerText = "Connected: " + accounts[0];
                alert("Please install MetaMask!");
            }
        });

        // Phantom Wallet Connect
        document.getElementById("connect-phantom").addEventListener("click", async function() {
            if (window.solana && window.solana.isPhantom) {
                const response = await window.solana.connect();
                document.getElementById("wallet-address").innerText = "Connected: " + response.publicKey.toString();
                alert("Please install Phantom Wallet!");
            }
        });

        // Solflare Wallet Connect
        document.getElementById("connect-solflare").addEventListener("click", async function() {
            const solflare = new Solflare();
            solflare.connect().then(() => {
                document.getElementById("wallet-address").innerText = "Connected: " + solflare.publicKey.toString();
            }).catch(() => {
                alert("Failed to connect to Solflare.");
            });
        });

        async function fetchChart() {
            let token = document.getElementById("analytics-token").value;
            let timeframe = document.getElementById("timeframe").value;

            let response = await fetch("https://pro-api.coinmarketcap.com/v1/cryptocurrency/ohlcv/historical?symbol=" + token + "&interval=" + timeframe, {
                headers: {
                    "X-CMC_PRO_API_KEY": "573b6b8b-d839-4838-8f5d-b33c1a5b0300",
                    "Accept": "application/json"
                }
            });

            let data = await response.json();
            let prices = data.data.quotes.map(q => q.quote.USD.close);
            let labels = data.data.quotes.map(q => q.time_open);

            let ctx = document.getElementById("tokenChart").getContext("2d");
            new Chart(ctx, {
                type: "candlestick",
                data: {
                    labels: labels,
                    datasets: [{
                        label: "Price",
                        data: prices
                    }]
                }
            });
        }
    </script>
</body>
</html>
EOL

    echo "Web Interface deployed in 'web_interface' directory. Run a local server to access it."
}

# =============================
# Web Interface Deployment with Web3 Support
# =============================
deploy_web_interface() {
    echo "Deploying Web Interface..."

    # Set default IP and port
    WEB_IP="127.0.0.1"
    WEB_PORT="8080"

    # Allow user to choose between simple or custom templates
    echo "Choose web interface mode:"
    echo "1) Use Simple (Default) Template"
    echo "2) Create Your Own Custom Web Interface"
    read -p "Enter choice: " WEB_MODE

    if [ "$WEB_MODE" -eq 2 ]; then
        echo "Creating a custom web interface..."
        mkdir -p web_interface
        touch web_interface/custom_index.html
        echo "Edit web_interface/custom_index.html to customize your web app."
        echo "Starting web server..."
        echo "Using default template..."
        
        # Create web directory if it doesn't exist
        if [ ! -d "web_interface" ]; then
            mkdir web_interface
        fi

        cat <<EOL > web_interface/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Setec Token Manager</title>
    <script src="https://cdn.jsdelivr.net/npm/web3"></script>
    <script src="https://cdn.jsdelivr.net/npm/@solana/wallet-adapter-wallets"></script>
    <script src="https://cdn.jsdelivr.net/npm/@solana/wallet-adapter-react"></script>
    <script src="https://cdn.jsdelivr.net/npm/@solana/wallet-adapter-react-ui"></script>
    <script src="https://cdn.jsdelivr.net/npm/web3modal"></script>
    <script src="https://cdn.jsdelivr.net/npm/@walletconnect/web3-provider"></script>
    <script src="https://cdn.jsdelivr.net/npm/ethers"></script>
    <style>
        body {
            text-align: center;
            font-family: Arial, sans-serif;
        }
        .logo {
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="logo">
        <img src="Setec_logo_200x200.png" alt="Setec Logo">
    </div>
    <h1>Setec Token Manager</h1>

    <h2>Connect Your Wallet</h2>
    <button id="connect-metamask">Connect Metamask</button>
    <button id="connect-phantom">Connect Phantom</button>
    <button id="connect-solflare">Connect Solflare</button>
    <p id="wallet-address"></p>

    <h2>Uniswap Trading</h2>
    <form id="uniswap-form">
        <label>Token Address: <input type="text" id="token-address"></label>
        <label>Amount: <input type="text" id="amount"></label>
        <button type="button" onclick="tradeToken()">Trade</button>
    </form>

    <h2>Token Analytics</h2>
    <form id="analytics-form">
        <label>Token Address: <input type="text" id="analytics-token"></label>
        <label>Timeframe:
            <select id="timeframe">
                <option value="1h">Last Hour</option>
                <option value="6h">Last 6 Hours</option>
                <option value="12h">Last 12 Hours</option>
                <option value="24h">Last 24 Hours</option>
                <option value="1m">Last Month</option>
                <option value="3m">Last 3 Months</option>
                <option value="6m">Last 6 Months</option>
                <option value="1y">Last Year</option>
                <option value="all">All Time</option>
            </select>
        </label>
        <button type="button" onclick="fetchChart()">View Chart</button>
    </form>

    <canvas id="tokenChart"></canvas>

    <script>
        // Web3 Wallet Connection
        document.getElementById("connect-metamask").addEventListener("click", async function() {
            if (window.ethereum) {
                const accounts = await ethereum.request({ method: "eth_requestAccounts" });
                document.getElementById("wallet-address").innerText = "Connected: " + accounts[0];
                alert("Please install MetaMask!");
            }
        });

        document.getElementById("connect-phantom").addEventListener("click", async function() {
            if (window.solana && window.solana.isPhantom) {
                const response = await window.solana.connect();
                document.getElementById("wallet-address").innerText = "Connected: " + response.publicKey.toString();
                alert("Please install Phantom Wallet!");
            }
        });

        document.getElementById("connect-solflare").addEventListener("click", async function() {
            const solflare = new Solflare();
            solflare.connect().then(() => {
                document.getElementById("wallet-address").innerText = "Connected: " + solflare.publicKey.toString();
            }).catch(() => {
                alert("Failed to connect to Solflare.");
            });
        });
    </script>
</body>
</html>
EOL
    fi

    echo "Starting local web server..."
    cd web_interface
    python3 -m http.server $WEB_PORT &
    cd ..

    echo "Web Interface launched at: http://$WEB_IP:$WEB_PORT"
}

deploy_web_interface

# =============================
# Display Web Interface Info (If Running)
# =============================
check_web_interface() {
    if pgrep -f "python3 -m http.server" > /dev/null; then
        echo "Web Interface is running at: http://127.0.0.1:8080"
    fi
}

check_web_interface

# =============================
# Secret Menu Activation
# =============================
check_secret_menu() {
    read -p "Enter command: " USER_INPUT
    if [[ "$USER_INPUT" = "Too Many Secrets" || "$USER_INPUT" = "too many secrets" ]]; then
        secret_menu
    fi
}

# =============================
# Secret Menu
# =============================
secret_menu() {
    echo "--------------------------------"
    echo "🎉 Congrats!!! Check Back Soon... More will be coming! 🎉"
    echo "--------------------------------"
    echo "1) Play Classic Snake"
    echo "2) Return to Main Menu"
    read -p "Enter your choice: " SECRET_CHOICE

    case $SECRET_CHOICE in
        1)
            play_snake
            ;;
        2)
            return
            ;;
        *)
            echo "Invalid choice. Returning to main menu."
            ;;
    esac
}

# =============================
# Classic Snake Game
# =============================
play_snake() {
    echo "Starting Classic Snake..."
    curl -s https://raw.githubusercontent.com/alexdantas/bash-snake/master/snake.sh | bash
}

check_secret_menu

# =============================
# Update Dependencies Before Installation
# =============================
update_dependencies() {
    echo "Updating package lists..."
    sudo apt update && sudo apt upgrade -y
}

read -p "Would you like to update all dependencies before installation? (y/n): " UPDATE_CHOICE
if [[ "$UPDATE_CHOICE" = "y" ]]; then
    update_dependencies
fi

# =============================
# Deploy Web3 Interface as a Systemd Service
# =============================
deploy_web3_service() {
    echo "Setting up Web3 Interface as a systemd service..."

    cat <<EOL | sudo tee /etc/systemd/system/setec-web3.service
[Unit]
Description=Setec Web3 Interface
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 8080 --directory web_interface
WorkingDirectory=$HOME
User=$USER
Restart=always

[Install]
WantedBy=multi-user.target
EOL

    sudo systemctl daemon-reload
    sudo systemctl enable setec-web3.service
    sudo systemctl start setec-web3.service

    echo "Web3 Interface service installed and started successfully."
    echo "Access it at: http://127.0.0.1:8080"
}

read -p "Would you like to set up the Web3 Interface as a background service? (y/n): " SERVICE_CHOICE
if [[ "$SERVICE_CHOICE" = "y" ]]; then
    deploy_web3_service
fi
