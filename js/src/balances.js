
const { ethers } = require('ethers')
const vaultABI = require('../abis/oracleVault.json')
const { formatEther } = require('ethers/lib/utils')

const rpcUrl = "https://rpc.blaze.soniclabs.com"

const provider = new ethers.providers.JsonRpcProvider(rpcUrl)

const vault = "0xae25fcfb3cd760e63a93c13cef68647af26746c1"

const vaultContract = new ethers.Contract(vault, vaultABI, provider)



const main = async () => {
    const block = 26286346

    const block2 = 26286506
    const historicBalances = await vaultContract.getBalances({blockTag: block2})
    const currentBalances = await vaultContract.getBalances()
    
    const historicAmountX = historicBalances[0].toString()
    const historicAmountY = historicBalances[1].toString()

    const currentAmountX = currentBalances[0].toString()
    const currentAmountY = currentBalances[1].toString()

    console.log(`Amount X (block): ${formatEther(historicAmountX)}`)
    console.log(`Amount Y (block): ${formatEther(historicAmountY)}`)

    console.log(`Amount X: ${formatEther(currentAmountX)}`)
    console.log(`Amount Y: ${formatEther(currentAmountY)}`)


}

main()