const ethers = require('ethers')
const { Contract } = require('ethers')
const { parseEther, formatEther, parseUnits, formatUnits } = require('ethers/lib/utils')
const { BigNumber: BigNumberJs} = require("bignumber.js")
const vaultABI = require('../abis/oracleVault.json')
const strategyABI = require('../abis/strategy.json')
const erc20ABI = require('../abis/erc20.json')
const addresses = require('./config')

require("dotenv").config()

const { PRIVATE_KEY, RPC_FANTOM_TESTNET_URL } = process.env

const provider = new ethers.providers.JsonRpcProvider(RPC_FANTOM_TESTNET_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const AUM_FEE = 450 // 4.5 % 

async function main() {

    


}