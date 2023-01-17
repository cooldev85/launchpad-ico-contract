import dontenv from 'dotenv'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-solhint'
import '@nomiclabs/hardhat-truffle5'
import '@nomiclabs/hardhat-waffle'
import "@nomicfoundation/hardhat-toolbox";
import 'hardhat-deploy'
import 'hardhat-gas-reporter'

import { HardhatUserConfig } from "hardhat/config";

dontenv.config();

const accounts = [process.env.PRIVKEY || ''];

const config: HardhatUserConfig = {
  	networks: {
		tneon: {
			url: "https://testnet.neonlink.io",
			accounts
		},
		neon: {
			url: "https://mainnet.neonlink.io",
			accounts
		},
		local: {
			url: "http://localhost:8545",
			accounts
		}
	},
	etherscan: {
		// Your API key for Etherscan
		// Obtain one at https://etherscan.io/
		apiKey: ""
	},
	solidity: {
		compilers: [
			{
				version: '0.8.17',
				settings: {
					optimizer: {
						enabled: true,
						runs: 10000,
					},
					// viaIR: true
				}
			},
		]
	},
	mocha: {
		timeout: 200000
	}
};

export default config;
