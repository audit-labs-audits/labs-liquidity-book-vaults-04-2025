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


async function main() {

    const constants = addresses[await signer.getChainId()];

    const vault = new Contract(constants.vault, vaultABI, signer);
    const strategy = new Contract(constants.strategy, strategyABI, signer);

    
    console.log("Is whitelisted mode", await vault.isWhitelistedOnly())

    const amountX = new BigNumberJs("2").times(1e18).toString();
    const amountY = new BigNumberJs("4").times(1e8).toString();

    const [shares, effectiveX, effectiveY] = await vault.previewShares(amountX, amountY);

    console.log(`Preview Shares ${shares.toString()}, effectiveX ${effectiveX.toString()} effectiveY ${effectiveY.toString()}`)


    console.log(await vault.getStrategy())
    console.log(await vault.getTokenX())
    console.log(await vault.getTokenY())
    // await approveErc20(constants.eth, constants.strategy, ethers.constants.MaxUint256.toString());
    // await approveErc20(constants.btc, constants.strategy, ethers.constants.MaxUint256.toString());

    console.log("Approve...")
    await approveErc20(constants.eth, constants.vault, amountX);
    await approveErc20(constants.btc, constants.vault, amountY);

    console.log("Deposit amounts")
    const tx = await vault.deposit(effectiveX, effectiveY)
    await tx.wait()
}

const approveErc20 = async (tokenAddress, spender, amount) => {  
    console.log(`Approve ${amount} to ${spender}`)
    const erc20 = new Contract(tokenAddress, erc20ABI, signer)

    const tx = await erc20.approve(spender, amount);
    return await tx.wait()
}

main().catch( err => console.error(err));