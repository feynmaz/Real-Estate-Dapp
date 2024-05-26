/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config();
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = "https://rpc.ankr.com/eth_sepolia"

module.exports = {
  defaultNetwork: "eth_sepolia",
  networks: {
    hardhat: {
      chainId: 80002,
    },
    eth_sepolia: {
      url: RPC_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  },

  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
