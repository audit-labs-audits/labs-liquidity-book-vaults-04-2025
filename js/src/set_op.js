const ethers = require('ethers')
const { Contract } = require('ethers')
const { parseEther, formatEther, parseUnits, formatUnits } = require('ethers/lib/utils')
const { BigNumber: BigNumberJs} = require("bignumber.js")
const vaultABI = require('../abis/oracleVault.json')
const strategyABI = require('../abis/strategy.json')
const factoryABI = require('../abis/vaultFactory.json')
const erc20ABI = require('../abis/erc20.json')
const addresses = require('./config')

require("dotenv").config()

const { PRIVATE_KEY, RPC_FANTOM_TESTNET_URL } = process.env

const provider = new ethers.providers.JsonRpcProvider(RPC_FANTOM_TESTNET_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const operator = "0xcaD3477b8D2569c849298E82D10046eD422AC258"

async function main() {

    const constants = addresses[await signer.getChainId()];

    const strategy = new Contract(constants.strategy, strategyABI, signer);
    const vaultFactory = new Contract(constants.vaultFactory, factoryABI, signer);

    const tx = await vaultFactory.setOperator(strategy.address, operator);
    await tx.wait();

}

main().catch( err => console.error(err));