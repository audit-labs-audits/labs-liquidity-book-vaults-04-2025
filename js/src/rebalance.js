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

const deltaUpper = 5;
const deltaLower = 5;

const shape = [0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02, 0.02]


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

    const [reservesX, reservesY, activeId ] = await pair.getReservesAndId()
    const { binStep } = await pair.feeParameters()

    console.log(`ActiveId ${activeId.toString()}`)

    const id = parseInt(activeId.toString())

    const upperId = id + deltaUpper;
    const lowerId = id - deltaLower;

    const slippageId = 10;

    const { amountX, amountY } = await strategy.getBalances()

    console.log(`Amount X ${amountX.toString()}`)
    console.log(`Amount Y ${amountY.toString()}`)
    console.log(`BinStep ${binStep.toString()}`)

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

    console.log(`Liquidity ${liquidities[5]} ${ liquidities[5] / (deltaLower + deltaUpper +1)}`)

    console.log("Shape sum", shape.reduce( (acc, cur) => acc + cur, 0))

    const desiredL = liquidities.map( (value) => Math.floor(parseInt(value.toString()) * 0.01) ) // shape.map( (value, index) => (parseInt(liquidities[0]) * value).toFixed(0))

    console.log("DesiredL ", desiredL, desiredL.reduce( (acc, c) => acc+ parseInt(c), 0))

    const binYPrice = priceFromBinId(parseInt(activeId.toString()), binStep, 18, 8)

    console.log(`Bin price ${binYPrice}`)

    const amountXNumber = new BigNumberJs(amountX.toString()).div(10**18).toNumber()
    const amountYNumber = new BigNumberJs(amountY.toString()).div(10**8).toNumber()
    const amountXInY = amountXNumber * binYPrice

    const meanY = amountYNumber / (deltaLower + 1)
    const meanX = amountXInY / (deltaUpper + 1)
    const liqLower = new Array(deltaLower).fill(meanY).map( val => new BigNumberJs(val).multipliedBy(10**8).toFixed(0) )
    const liqUpper = new Array(deltaUpper).fill(meanX).map(val => new BigNumberJs(val).multipliedBy(10**8).toFixed(0))

    const desiredL2 = [...liqLower, new BigNumberJs(meanY * 0.5 + meanX * 0.5).multipliedBy(10**8).toFixed(0), ...liqUpper].map( val => new BigNumberJs(val).times(0.9).toFixed(0))
    console.log(`desiredL 2 ${desiredL2}`)
    
    console.log("Liquidity offchain: ");
    const liq = amountXInY + amountXNumber;


    const maxPercentageToAddX = amountXInY / (amountXInY + amountYNumber)
    const maxPercentageToAddY = amountYNumber / (amountXInY + amountYNumber)

    console.log("maxPercentageToAddX", maxPercentageToAddX)
    console.log("maxPercentageToAddY", maxPercentageToAddY )


    console.log("do Rebalance")





    let args = [
        lowerId,
        upperId,
        activeId.toString(),
        10,
        [
            ...desiredL2
            // 68112620,6811262,6811262,6811262,6811262,6811262,6811262,6811262,6811262,6811262,6811262
        ],
        parseEther("1").toString(),
        parseEther("1").toString(),
    ]


    // // // args = [0,0,0,0,[],0,0]

    console.log(args)

    const tx = await strategy.rebalance(
        ...args
    )

    await tx.wait()

}



main().catch( err => console.error(err));