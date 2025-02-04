Note: Make sure PIP is installed.

### **Setec All In One Token Manager**  
#### **A Comprehensive Blockchain & Token Management System**
---

# **Overview**
The **Setec All In One Token Manager** is a **powerful, multi-functional blockchain toolkit** designed to manage wallets, create and trade tokens, and deploy a Web3-enabled cloud service.  

🔹 **Supports multiple blockchains** (Solana, Ethereum, BSC, Polygon)  
🔹 **Can be deployed as a local CLI tool or a hosted cloud service**  
🔹 **Web3-ready with Phantom, MetaMask, and Solflare wallet support**  
🔹 **Secure API key management with encryption**  
🔹 **Live token analytics & trading via Uniswap integration**  
🔹 **Multi-user cloud application with MySQL authentication**  

---

# **Table of Contents**
1. [Features](#features)  
2. [Installation & Setup](#installation--setup)  
    - [Local CLI Version](#local-cli-version)  
    - [Cloud-Hosted Version](#cloud-hosted-version)  
3. [Usage](#usage)  
4. [Dependency Management](#dependency-management)  
5. [Security](#security)  
6. [Web Interface Deployment](#web-interface-deployment)  
7. [Hosting on a Server](#hosting-on-a-server)  
8. [Secret Menu](#secret-menu)  
9. [Troubleshooting](#troubleshooting)  
10. [Contributing](#contributing)  

---

# **1. Features**
### ✅ **Blockchain Support**
- Manage **Solana, Ethereum, Binance Smart Chain (BSC), and Polygon** tokens.  
- **Live token analytics** with Uniswap and CoinMarketCap integration.  
- **Create, mint, burn, and transfer tokens** securely.  

### ✅ **Web3 & Wallet Support**
- **Connect MetaMask, Phantom, and Solflare wallets**.  
- Supports **hardware wallets** and **multiple API keys**.  

### ✅ **User Authentication & API Management**
- **Secure login system** (cloud version) using **MySQL authentication**.  
- **Encrypted API key management** via **GPG encryption**.  

### ✅ **Web3-Ready Web Interface**
- **Deploy a GUI with a single command**.  
- Hosted via **Nginx & Flask**, accessible from any browser.  

---

# **2. Installation & Setup**
## **Local CLI Version**
### **Requirements**
- **OS:** Debian 12.9, Ubuntu 22.04+
- **Dependencies:** `solana`, `web3`, `jq`, `curl`, `npm`, `nodejs`, `python3`, `gpg`, `tar`

### **Install the CLI Version**
```bash
git clone https://github.com/DigijEth/SetecGamingTokenManager.git
cd SetecGamingTokenManager
chmod +x framework_betav3.sh
./framework_betav2.sh
```

---

## **Cloud-Hosted Version**
### **Requirements**
- **Cloud Server:** Ubuntu 22.04+, Debian 12.9+
- **Software Stack:** Python, Flask, MySQL, Nginx, Certbot
- **Hardware Requirements:** 2GB RAM, 1 CPU, 20GB Storage

### **Install & Deploy the Cloud Version**
```bash
git clone https://github.com/DigijEth/SetecGamingTokenManager.git
cd SetecGamingToken
chmod +x framework_beta_cloud_service.sh
./framework_beta_cloud_service.sh
```
- Enter your **domain/subdomain** (e.g., `setec.yourdomain.com`)  
- Follow the prompts to **configure MySQL and SSL certificates**  

Once completed, the application will be available at:  
🔗 **`https://setec.yourdomain.com`**

---

# **3. Usage**
### **Launching the CLI Version**
```bash
./framework_beta_v2_cloud_service.sh
```
### **Launching the Web Interface**
```bash
python3 -m http.server 8080 --directory web_interface
```
Then open:  
🔗 **`http://127.0.0.1:8080`**

### **Deploy as a Systemd Service**
```bash
sudo systemctl enable setec-web3
sudo systemctl start setec-web3
```

---

# **4. Dependency Management**
### **Automatic Installation**
At startup, the system **checks for missing dependencies** and prompts for installation:
```bash
Would you like to install missing dependencies? (y/n)
```
### **Manual Installation**
```bash
sudo apt update
sudo apt install solana web3 jq curl npm nodejs python3 gpg tar
```

---

# **5. Security**
### **GPG Encryption for API Keys**
- On first launch, **API keys are encrypted** with **AES-256**.
- **Decrypt on startup** (3 attempts allowed).
```bash
gpg --decrypt .env.gpg > .env
```

---

# **6. Web Interface Deployment**
- **Select a template:**  
  ✅ Simple (default)  
  ✅ Custom (create your own)
```bash
Would you like to create a custom web interface? (y/n)
```

- Start the local server:
```bash
python3 -m http.server 8080 --directory web_interface
```

---

# **7. Hosting on a Server**
- Automatically configures **MySQL, Flask, Nginx, and SSL**.
```bash
Would you like to deploy Setec Token Manager as a cloud-based service? (y/n)
```
- Runs as a **secure systemd service**.

---

# **8. Secret Menu**
🎉 Hidden **Easter Egg!** Type:
```
Too Many Secrets
```
✨ **Options:**  
🔹 Play **Classic Snake**  
🔹 Return to Main Menu  
🔹 **More secret features coming soon!**

---

# **9. Troubleshooting**
### **Common Issues**
**🔴 Missing Dependencies?**
```bash
sudo apt install <missing-package>
```
**🔴 Web Interface Not Starting?**
```bash
sudo systemctl restart setec-web3
```
**🔴 Forgot Database Password?**
```bash
sudo mysql -e "ALTER USER 'setec_user'@'localhost' IDENTIFIED BY 'NewSecurePass!';"
```

---

# **10. Contributing**
💡 **Have ideas? Found a bug?**  
Contributions are welcome! Open an issue or submit a pull request.  

📩 **Contact**: setec-support@example.com  
🌍 **Website**: [setec.yourdomain.com](https://setec.yourdomain.com)  

---

### **License**
🔓 **GNU General Public License v3.0** – Open-source and free to modify under the terms of the GNU GPL v3.  
📜 **Details:** [GNU GPL 3.0 License](https://www.gnu.org/licenses/gpl-3.0.en.html)  

---

### **Donations**
💰 **Support Development!**  
If you find Setec Token Manager useful, consider donating:  

💎 **Ethereum & EVM Chains:** `digij.eth` (**0x2d22029df730321a5d2b48e6926c4e3923f808cf**)  
💎 **Solana Donations:** `setec.sol` (**6b7Wmfw5zMFRLypdM4nCNZTCrdJZJw8WyfrDufj6jEJm**)  

---

This **README is fully updated** with the **GNU GPL 3.0 license** and **correct donation addresses**. Let me know if you need any refinements! 🚀
