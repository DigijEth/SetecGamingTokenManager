**Setec Gaming Lab's
– All-In-One Token Creator**

**Donations:** If you find this script helpful, please consider sending a tip to setec.sol on Solana. Your support helps us keep building!

**GitHub Repository:** https://github.com/DigijEth/Solena-anti-bot-Token

This script should work on most debian based linux distros.

------------------------------------------------------------------

**FEATURES**

- Automatic Dependency Checks & Installation:
  The script verifies (and optionally installs) key dependencies via apt-get or cargo:
  1. Node.js + npm
  2. Rust (cargo)
  3. solana CLI (auto-install from official script if you approve)
  4. spl-token CLI (via cargo)
  5. anchor (via cargo, if you want to build/deploy an Anchor program)
  6. netlify-cli and vercel (via npm)

- Interactive Token Creation:
  Prompts for name, symbol, total supply, decimals, freeze authority, tax settings, anti-bot cooldown, multi-signature admin, etc.

- On-Chain Security & Anti-Bot:
  Lock tax rate, anti-flash loan placeholders, anti-bot cooldown, and blacklist/whitelist logic (requires a custom program for real enforcement).

- Optional Anchor Program Deployment:
  Detects multiple Anchor programs in a programs/ directory and can build and deploy them if selected.

- Frontend Deployment:
  Integrates with Vercel or Netlify for easy frontend hosting.

- Built-In Logging:
  Logs all operations to a timestamped log file. Optionally uses security.log if logging is enabled.

- Cleanup & Testing:
  Offers an optional dev/test cleanup step to burn all minted tokens and close accounts. Also allows linting, testing, and local dev server if a package.json is present.

------------------------------------------------------------------

REQUIREMENTS

1. Debian/Ubuntu (or another apt-get-based system).
2. Basic shell utilities (bash, curl, grep, etc.).
3. Internet connection (for installing dependencies and fetching external scripts).

Note: The script will prompt before installing anything. You can pre-install dependencies yourself if you prefer.

------------------------------------------------------------------

Note: The script uses the old solana install method. Before running the script run:

sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

then use the skip option.

INSTALLATION AND USAGE

1. Clone or download this repository:
   
git clone https://github.com/DigijEth/Solena-anti-bot-Token.git

cd Solena-anti-bot-Token

3. Make the script executable:
   
    chmod +x framework.sh

5. Run the script:

    ./framework.sh

7. Install Dependencies and setup a wallet then create!!!

Note: If you select to change  the prefix, changing all 4 can cause the token creation to take hours.


------------------------------------------------------------------

EXAMPLE FLOW

./setec-labs-creator.sh

The script will ask about decimals (default is 9), Solana network (Testnet, Devnet, or Mainnet), token name, symbol, supply, tax features, etc. Eventually it creates and mints your token, logs everything, and ends with “All steps completed!”

------------------------------------------------------------------

FAQ AND TROUBLESHOOTING

1. solana CLI not installed:
   The script can auto-install it from the official Solana release script if you approve, or you can install it manually first.

2. spl-token CLI missing:
   The script offers to cargo install it. If you refuse, it exits. You can run cargo install spl-token-cli later, then re-run the script.

3. Anchor missing:
   You can let the script install anchor via cargo or handle it yourself if you plan to build/deploy on-chain programs.

4. Low SOL balance:
   The script warns if your balance is under 0.001. You can continue, but risk failing if you don’t have enough SOL for fees.

5. Frontend deployment:
   If you say yes, it runs vercel deploy --prod or netlify deploy --prod. If you want a local dev server, it runs npm install && npm run dev.

------------------------------------------------------------------

CONTRIBUTING

We welcome PRs for new features, bug fixes, or enhancements. If you want bridging, advanced liquidity, or integrated tax logic, remember you must also implement or modify on-chain programs. This script only sets up the environment and calls the standard tools.

------------------------------------------------------------------

DONATIONS

If you find this script helpful, please donate to setec.sol on Solana. Your contributions fuel continued development!

------------------------------------------------------------------

LICENSE

This project is licensed under the GNU General Public License v3.0. See LICENSE for details.

------------------------------------------------------------------

Thank you for using the Setec Gaming Lab All-In-One Token Creator! If you have questions or suggestions, open an issue or a pull request in the official repository: https://github.com/DigijEth/Solena-anti-bot-Token.
