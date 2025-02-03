#!/usr/bin/env bash

# Set up Web3 Token Manager Web Application

PROJECT_DIR="setec-token-manager"

echo "Creating project directory..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR" || exit

# ---------------------- Backend Setup ----------------------
echo "Setting up backend (Node.js + Express + Web3.js)..."
mkdir backend
cd backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express cors dotenv @solana/web3.js body-parser child_process

# Create basic server file
cat <<EOL > server.js
const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const { exec } = require("child_process");

dotenv.config();
const app = express();
app.use(cors());
app.use(express.json());

app.post("/update-metadata", (req, res) => {
    const { mint, metadataPath } = req.body;
    if (!mint || !metadataPath) {
        return res.status(400).json({ error: "Missing parameters" });
    }

    const cmd = \`sugar update -m \${mint} -f \${metadataPath}\`;
    exec(cmd, (error, stdout, stderr) => {
        if (error) return res.status(500).json({ error: stderr });
        res.json({ message: stdout });
    });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));
EOL

cd ..

# ---------------------- Frontend Setup ----------------------
echo "Setting up frontend (React + Next.js + TailwindCSS)..."
mkdir frontend
cd frontend

# Initialize Next.js project
npx create-next-app@latest . --use-npm --ts --no-eslint --no-experimental-appdir

# Install dependencies
npm install @solana/web3.js @solana/wallet-adapter-react @solana/wallet-adapter-react-ui @solana/wallet-adapter-phantom tailwindcss postcss autoprefixer dotenv

# Set up TailwindCSS
npx tailwindcss init -p

# Configure Tailwind
cat <<EOL > tailwind.config.js
module.exports = {
  content: ["./pages/**/*.{js,ts,jsx,tsx}", "./components/**/*.{js,ts,jsx,tsx}"],
  theme: { extend: {} },
  plugins: [],
};
EOL

# Create .env file
cat <<EOL > .env
NEXT_PUBLIC_BACKEND_URL=http://localhost:5000
EOL

# Create Next.js main page with Web3 integration
cat <<EOL > pages/index.tsx
import { useWallet, WalletMultiButton } from "@solana/wallet-adapter-react-ui";
import { useState } from "react";

export default function Home() {
  const { publicKey } = useWallet();
  const [mint, setMint] = useState("");
  const [metadata, setMetadata] = useState("");

  const updateMetadata = async () => {
    if (!publicKey) return alert("Connect your wallet first!");
    const response = await fetch(process.env.NEXT_PUBLIC_BACKEND_URL + "/update-metadata", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ mint, metadataPath: metadata }),
    });
    const data = await response.json();
    alert(data.message || data.error);
  };

  return (
    <div className="flex flex-col items-center p-10">
      <WalletMultiButton />
      <input type="text" placeholder="Token Mint" onChange={(e) => setMint(e.target.value)} className="mt-5 p-2 border" />
      <input type="text" placeholder="Metadata Path" onChange={(e) => setMetadata(e.target.value)} className="mt-2 p-2 border" />
      <button onClick={updateMetadata} className="mt-3 p-2 bg-blue-500 text-white">Update Metadata</button>
    </div>
  );
}
EOL

cd ..

echo "Setup complete! Run 'cd backend && node server.js' to start the backend and 'cd frontend && npm run dev' to start the frontend."
