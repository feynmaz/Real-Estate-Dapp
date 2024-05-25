/** @type import('hardhat/config').HardhatUserConfig */
require('dotenv').config();
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = "https://rpc.ankr.com/polygon_amoy"

module.exports = {
  defaultNetwork: "polygon_amoy",
  networks: {
    hardhat: {
      chainId: 80002,
    },
    polygon_amoy: {
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
