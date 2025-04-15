const ethers = require('ethers')
const { Contract } = require('ethers')
const { parseEther, formatEther, parseUnits, formatUnits, AbiCoder } = require('ethers/lib/utils')
const BigNumberJs = require("bignumber.js")
const vaultABI = require('../abis/oracleVault.json')
const strategyABI = require('../abis/strategy.json')
const liquidityAmountsABI = require('../abis/liquidityAmounts.json')
const erc20ABI = require('../abis/erc20.json')
const pairABI = require('../abis/pair.json')
const addresses = require('./config')

require("dotenv").config()

const { PRIVATE_KEY, RPC_FANTOM_TESTNET_URL } = process.env

const provider = new ethers.providers.JsonRpcProvider(RPC_FANTOM_TESTNET_URL);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const deltaUpper = 25;
const deltaLower = 25;


async function main() {
    const constants = addresses[await signer.getChainId()];

    const strategy = new Contract(constants.strategy, strategyABI, signer);

    const pairAddress = await strategy.getPair()

    const pair = new Contract(pairAddress, pairABI, signer);

    const activeId = await pair.getActiveId()

    const id = parseInt(activeId.toString())


    const { amountX, amountY } = await strategy.getBalances()

    const idleAmount = 0.6

    const amountXIn = new BigNumberJs.BigNumber(amountX._hex).times( new BigNumberJs.BigNumber(1 - idleAmount)).toFixed(0)
    const amountYin = new BigNumberJs.BigNumber(amountY._hex).times( new BigNumberJs.BigNumber(1 - idleAmount)).toFixed(0)

    
    // const distributionsX = [0.2, 0.2, 0.2, 0.2] 
    // const distributionsY = distributionsX.reverse()

    const distributions = [ [0, 0.2], [0, 0.2], [0, 0.2], [0.2, 0.2], [0.2, 0], [0.2, 0], [0.2, 0] ]
                            .flatMap( (val) => val  ).map( val => parseEther(val.toString()))

    const encoded2 = ethers.utils.solidityPack(distributions.map( val => `uint64`), distributions)

    const newLower = id - 3
    const newUpper = id + 3
    const slippageId = 5
    const args = [
        newLower,
        newUpper,
        id,
        slippageId,
        amountXIn,
        amountYin,
        encoded2
    ]

    console.log(args)

    const tx = await strategy.rebalance(...args)

    await tx.wait()

}


async function getLiqudities(constants, id, binStep, amountX, amountY) {
    const liquidityAmounts = new Contract(constants.liquidityAmounts, liquidityAmountsABI, signer)

    const ids = [
        ...new Array(deltaLower).fill(id - deltaLower).map( (val, index) => val + index),
        id,
        ...new Array(deltaUpper).fill(id).map( (val, index) => val + (index + 1) )
    ]

    console.debug("ids", ids)
    const liquidities = await liquidityAmounts.getLiquiditiesForAmounts(
        ids,
        binStep,
        amountX,
        amountY
    )
    return liquidities
}



main().catch( err => console.error(err));