const ethers = require('ethers')
const { Contract } = require('ethers')
const { parseEther, formatEther, parseUnits, formatUnits } = require('ethers/lib/utils')
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

const priceFromBinId = (id, binStep, decimalsX, decimalsY) => {
    const TOKEN_X_DECIMALS = new BigNumberJs(10).pow(decimalsX)
    const TOKEN_Y_DECIMALS = new BigNumberJs(10).pow(decimalsY)

    const binPrice = (1 + binStep / 10_000) ** (id - 8388608)
    return new BigNumberJs(binPrice).multipliedBy(TOKEN_X_DECIMALS).div(TOKEN_Y_DECIMALS).toNumber()
  }

async function main() {
    const constants = addresses[await signer.getChainId()];

    const vault = new Contract(constants.vault, vaultABI, signer);
    const strategy = new Contract(constants.strategy, strategyABI, signer);

    const pairAddress = await strategy.getPair()

    const pair = new Contract(pairAddress, pairABI, signer);

    const [ _1, _2, activeId ] = await pair.getReservesAndId()
    const { binStep } = await pair.feeParameters()

    console.log(`Strategy ${strategy.address}`)
    console.log(`ActiveId ${activeId.toString()}`)

    const id = parseInt(activeId.toString())

    const upperId = id + deltaUpper;
    const lowerId = id - deltaLower;

    const slippageId = 10;

    const { amountX, amountY } = await strategy.getBalances()
    const { amountX: idleX, amountY: idleY } = await strategy.getIdleBalances()

    console.log(`Amount X ${amountX.toString()}`)
    console.log(`Amount Y ${amountY.toString()}`)
    console.log(`BinStep ${binStep.toString()}`)

    const binYPrice = priceFromBinId(parseInt(activeId.toString()), binStep, 18, 8)

    console.log(`Bin price ${binYPrice}`)

    const amountXNumber = new BigNumberJs(amountX.toString()).div(10**18).toNumber()
    const amountYNumber = new BigNumberJs(amountY.toString()).div(10**8).toNumber()
    const amountXInY = amountXNumber * binYPrice

    console.log("AmountXinY", amountXInY)
    console.log("AmountY", amountYNumber)

    console.log("Liquidity", amountXInY + amountYNumber)
    
    const idleXNumber = new BigNumberJs(idleX.toString()).div(10**18).toNumber()
    const idleYNumber = new BigNumberJs(idleY.toString()).div(10**8).toNumber()
    const idleXInY = idleXNumber * binYPrice

    console.log("idleXInY", idleXInY, idleXNumber)
    console.log("idleYNumber", idleYNumber)

    const meanY = amountYNumber / (deltaLower +1)
    const meanX = amountXInY / (deltaUpper+1)
    const liqLower = new Array(deltaLower).fill(meanY).map( val => new BigNumberJs(val).multipliedBy(10**8).toFixed(0) )
    const liqUpper = new Array(deltaUpper).fill(meanX).map(val => new BigNumberJs(val).multipliedBy(10**8).toFixed(0))

    const liq = (amountXInY + amountYNumber) / (deltaLower + deltaUpper + 1)


    const linear = new Array(deltaLower + deltaUpper + 1).fill(0).reduce( (acc, current, index) => {
        if (acc.length === 0) {
            return [0.02]
        }
        return [...acc, acc[index-1] + 0.02 ]
    }, [])

    let desiredL2 = new Array(deltaLower + deltaUpper + 1).fill(liq)
            .map( val => new BigNumberJs(val).times(10**8))
            .map( (bn, index) => bn.times(0.7).toFixed(0))
            
            // bin art
            // .map( (bn, index) => bn.times(linear[index]).toFixed(0))
            //.map( (bn, index) => bn.times( index % 2 ? 1.0 : 0.2).toFixed(0) )
    
    



    // [...liqLower, new BigNumberJs(meanY + meanX).multipliedBy(10**8).toFixed(0), ...liqUpper].map( val => new BigNumberJs(val).times(0.90).toFixed(0))
    console.log(`desiredL 2 ${desiredL2}`)
    

    const maxPercentageToAddX = amountXInY / (amountXInY + amountYNumber)
    const maxPercentageToAddY = amountYNumber / (amountXInY + amountYNumber)

    console.log("maxPercentageToAddX", maxPercentageToAddX)
    console.log("maxPercentageToAddY", maxPercentageToAddY )

    // console.log(`Liquidities ${await getLiqudities(constants, id, binStep, amountX, amountY)}`)

    // desiredL2 = (await getLiqudities(constants, id, binStep, amountX, amountY)).map( val => new BigNumberJs(val._hex).times(0.6).toFixed(0))
    // console.log(`desiredL 2 ${desiredL2}`)

    console.log("rebalance...")

    // desiredL2 = [160000000,160000000,160000000,160000000,160000000,160000000,160000000,160000000,160000000,160000000,160000000]

    let args = [
        lowerId,
        upperId,
        activeId.toString(),
        slippageId,
        [
            ...desiredL2
        ],
        parseEther("1").toString(),
        parseEther("1").toString(),
    ]

    console.log(args)

    const tx = await strategy.rebalance(
        ...args
    )

    await tx.wait()
    
    console.log("finish")
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