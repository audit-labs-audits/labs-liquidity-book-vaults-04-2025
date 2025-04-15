
const { ethers } = require('ethers')
const vaultABI = require('../abis/oracleVault.json')
const { formatEther, formatUnits } = require('ethers/lib/utils')

const rpcUrl = "https://rpc.soniclabs.com"

const provider = new ethers.providers.JsonRpcProvider(rpcUrl)

const vault = "0xf1e28e380ac635efac9f62d214828223154363f9"

const vaultContract = new ethers.Contract(vault, vaultABI, provider)

const subgraphData = {
    "data": {
      "vaultUserPositions": [
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x0c759509de69c23f4fd35bde9148a34743586ff8",
          "user": {
            "id": "0x0c759509de69c23f4fd35bde9148a34743586ff8"
          },
          "totalAmountDepositedX": "700",
          "totalAmountDepositedY": "150",
          "totalAmountDepositedUSD": "465.559851481079558877459995436519",
          "totalAmountWithdrawnX": "91.225541950811073982",
          "totalAmountWithdrawnY": "279.514462",
          "totalAmountWithdrawnUSD": "326.6041845508462210332461894714996"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x0f977101db0eb9256b82034e7e80d6e48e6f7a9d",
          "user": {
            "id": "0x0f977101db0eb9256b82034e7e80d6e48e6f7a9d"
          },
          "totalAmountDepositedX": "0",
          "totalAmountDepositedY": "100.634",
          "totalAmountDepositedUSD": "100.3093942242005800661693249742141",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x2850a72f6d4d1ef010fdb7f3ca4bd32bdde905a2",
          "user": {
            "id": "0x2850a72f6d4d1ef010fdb7f3ca4bd32bdde905a2"
          },
          "totalAmountDepositedX": "1500",
          "totalAmountDepositedY": "5000",
          "totalAmountDepositedUSD": "5765.01635102576549621201138184407",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x290e00950f744a914cd61ad51f58e37c0b8ac945",
          "user": {
            "id": "0x290e00950f744a914cd61ad51f58e37c0b8ac945"
          },
          "totalAmountDepositedX": "14830",
          "totalAmountDepositedY": "0.166177",
          "totalAmountDepositedUSD": "7549.16873427392271265275127619803",
          "totalAmountWithdrawnX": "8717.226839899163760641",
          "totalAmountWithdrawnY": "52079.880768",
          "totalAmountWithdrawnUSD": "56969.74643782385662382650478780784"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x3edb7d5b494ccb9bb84d11ca25f320af2bb15f40",
          "user": {
            "id": "0x3edb7d5b494ccb9bb84d11ca25f320af2bb15f40"
          },
          "totalAmountDepositedX": "425",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "217.068539293468135975",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x4533e03d983fae04741131c5f7cb35f1b32a1acd",
          "user": {
            "id": "0x4533e03d983fae04741131c5f7cb35f1b32a1acd"
          },
          "totalAmountDepositedX": "38.204740756142012541",
          "totalAmountDepositedY": "16.3678",
          "totalAmountDepositedUSD": "35.35581986443523862684463881378474",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x47630c744c4f9cc8be8da6af09d688cc43de2323",
          "user": {
            "id": "0x47630c744c4f9cc8be8da6af09d688cc43de2323"
          },
          "totalAmountDepositedX": "790.775928087786543",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "415.3642113991274449018678754500321",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x61125f52cee83ed5d7a6cd14598d34974b11865e",
          "user": {
            "id": "0x61125f52cee83ed5d7a6cd14598d34974b11865e"
          },
          "totalAmountDepositedX": "4400",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "2278.362618602939836",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x68aedee7dc9da33a1e7d32a6637361e409c40519",
          "user": {
            "id": "0x68aedee7dc9da33a1e7d32a6637361e409c40519"
          },
          "totalAmountDepositedX": "1000",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "517.39819104612269",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x7e45ac061ca96b3995cd6730a0211816fbd5f77e",
          "user": {
            "id": "0x7e45ac061ca96b3995cd6730a0211816fbd5f77e"
          },
          "totalAmountDepositedX": "510",
          "totalAmountDepositedY": "846.388",
          "totalAmountDepositedUSD": "1116.340271530530627003595253030865",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0.019688",
          "totalAmountWithdrawnUSD": "0.01970173918481904715715118318490136"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x86e4c00c5a7e7fb456d2a5f75fcb68998004bd87",
          "user": {
            "id": "0x86e4c00c5a7e7fb456d2a5f75fcb68998004bd87"
          },
          "totalAmountDepositedX": "5360",
          "totalAmountDepositedY": "1879.277674",
          "totalAmountDepositedUSD": "4296.029999236955223830942647317577",
          "totalAmountWithdrawnX": "2589.060633610437618057",
          "totalAmountWithdrawnY": "1597.554614",
          "totalAmountWithdrawnUSD": "2717.431033353286331294281242822185"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x87d7fe60456922915560f2dbbba4cd19e97649f0",
          "user": {
            "id": "0x87d7fe60456922915560f2dbbba4cd19e97649f0"
          },
          "totalAmountDepositedX": "900",
          "totalAmountDepositedY": "497.155",
          "totalAmountDepositedUSD": "966.2087937719424349686800593065839",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x888a555349c75353213c9610fee87587fd6f8a6a",
          "user": {
            "id": "0x888a555349c75353213c9610fee87587fd6f8a6a"
          },
          "totalAmountDepositedX": "10000",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "4840.3829160252401",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x91799239fbf7dc87e74dd657ed9d8b98ea34f989",
          "user": {
            "id": "0x91799239fbf7dc87e74dd657ed9d8b98ea34f989"
          },
          "totalAmountDepositedX": "4379.62188878660932",
          "totalAmountDepositedY": "352.097",
          "totalAmountDepositedUSD": "2529.418269878135183258890332542324",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x9b5683703ca24ec7d346a69353f3c51b55d8f8dc",
          "user": {
            "id": "0x9b5683703ca24ec7d346a69353f3c51b55d8f8dc"
          },
          "totalAmountDepositedX": "217",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "100.251476194889398232",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0x9ba52bc4e63965ff9d6eab7ec68fd4213823c99e",
          "user": {
            "id": "0x9ba52bc4e63965ff9d6eab7ec68fd4213823c99e"
          },
          "totalAmountDepositedX": "500",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "267.9195351135197135",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xa100fa6fada1be2041a20ba80c11e8f370c9306b",
          "user": {
            "id": "0xa100fa6fada1be2041a20ba80c11e8f370c9306b"
          },
          "totalAmountDepositedX": "9039",
          "totalAmountDepositedY": "3102.53",
          "totalAmountDepositedUSD": "7459.486132199401758703433288620081",
          "totalAmountWithdrawnX": "409.497353489816700366",
          "totalAmountWithdrawnY": "7342.253595",
          "totalAmountWithdrawnUSD": "7559.595622605539337088573007364411"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xa32a1e271691c0d1b3b73a260757802270a4e21e",
          "user": {
            "id": "0xa32a1e271691c0d1b3b73a260757802270a4e21e"
          },
          "totalAmountDepositedX": "0",
          "totalAmountDepositedY": "92.6084",
          "totalAmountDepositedUSD": "92.58930849673277684346077020336367",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xb4bd807c9cdde19ae1498c7b7006713268e25997",
          "user": {
            "id": "0xb4bd807c9cdde19ae1498c7b7006713268e25997"
          },
          "totalAmountDepositedX": "100",
          "totalAmountDepositedY": "4999.62",
          "totalAmountDepositedUSD": "5047.596344401041612591861862622425",
          "totalAmountWithdrawnX": "41.524890220827061053",
          "totalAmountWithdrawnY": "26.650873",
          "totalAmountWithdrawnUSD": "44.87250766780793138304523844487588"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xb5cda7504c4e5881ef6404fd6f45da7b1e79e821",
          "user": {
            "id": "0xb5cda7504c4e5881ef6404fd6f45da7b1e79e821"
          },
          "totalAmountDepositedX": "10000",
          "totalAmountDepositedY": "5000",
          "totalAmountDepositedUSD": "9842.032307077344929804105739649656",
          "totalAmountWithdrawnX": "1728.920651823068571931",
          "totalAmountWithdrawnY": "1526.186514",
          "totalAmountWithdrawnUSD": "2454.801073917974307781591655708551"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xc4c4c064fff824daeacd76bdc0d2656fad17ce44",
          "user": {
            "id": "0xc4c4c064fff824daeacd76bdc0d2656fad17ce44"
          },
          "totalAmountDepositedX": "2757",
          "totalAmountDepositedY": "201",
          "totalAmountDepositedUSD": "1663.582963690435969792759665686039",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xc5659b1ddcf5f5c0d9e006ffa6d57f58e9ba51cb",
          "user": {
            "id": "0xc5659b1ddcf5f5c0d9e006ffa6d57f58e9ba51cb"
          },
          "totalAmountDepositedX": "1",
          "totalAmountDepositedY": "300",
          "totalAmountDepositedUSD": "298.8539127921037247519601191487636",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xd881878265fcae4d4985cf023279d950451aa880",
          "user": {
            "id": "0xd881878265fcae4d4985cf023279d950451aa880"
          },
          "totalAmountDepositedX": "113",
          "totalAmountDepositedY": "3",
          "totalAmountDepositedUSD": "60.95676894449316293621939196260144",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xdd21be69badb67067b9cea9227cc701551a545c6",
          "user": {
            "id": "0xdd21be69badb67067b9cea9227cc701551a545c6"
          },
          "totalAmountDepositedX": "0",
          "totalAmountDepositedY": "163",
          "totalAmountDepositedUSD": "162.8311358823312698387179581021812",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xf0009f5f6731fbd11bf9bfff0d1ea6d790bec101",
          "user": {
            "id": "0xf0009f5f6731fbd11bf9bfff0d1ea6d790bec101"
          },
          "totalAmountDepositedX": "6110",
          "totalAmountDepositedY": "6316.016872",
          "totalAmountDepositedUSD": "9379.840949626424502688332004684318",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        },
        {
          "id": "0xf1e28e380ac635efac9f62d214828223154363f9-0xf2842c6fc18f3070d3186664f45e06e1ce873663",
          "user": {
            "id": "0xf2842c6fc18f3070d3186664f45e06e1ce873663"
          },
          "totalAmountDepositedX": "10000",
          "totalAmountDepositedY": "0",
          "totalAmountDepositedUSD": "5114.17723822979426",
          "totalAmountWithdrawnX": "0",
          "totalAmountWithdrawnY": "0",
          "totalAmountWithdrawnUSD": "0"
        }
      ]
    }
  }

const main = async () => {
    
    // const positions = subgraphData.data.vaultUserPositions

    // console.log("user;totalAmountDepositedX;totalAmountDepositedY;totalAmountDepositedUSD;totalAmountWithdrawnX;totalAmountWithdrawnY;totalAmountWithdrawnUSD")
    // for (const position of positions) {
    //     const user = position.user.id
    //     const totalAmountDepositedX = position.totalAmountDepositedX
    //     const totalAmountDepositedY = position.totalAmountDepositedY
    //     const totalAmountDepositedUSD = position.totalAmountDepositedUSD

    //     const totalAmountWithdrawnX = position.totalAmountWithdrawnX
    //     const totalAmountWithdrawnY = position.totalAmountWithdrawnY
    //     const totalAmountWithdrawnUSD = position.totalAmountWithdrawnUSD

        
    //     console.log(`${user};${parseFloat(totalAmountDepositedX).toLocaleString("de-DE")};${parseFloat(totalAmountDepositedY).toLocaleString("de-DE")};${parseFloat(totalAmountDepositedUSD).toLocaleString("de-DE")};${parseFloat(totalAmountWithdrawnX).toLocaleString("de-DE")};${parseFloat(totalAmountWithdrawnY).toLocaleString("de-DE")};${parseFloat(totalAmountWithdrawnUSD).toLocaleString("de-DE")}`)
        
    // }


    const [amountX, amountY] = await vaultContract.previewAmounts("18073592736877336", { blockTag:  14715800 })
    
    console.log(formatEther(amountX?.toString()), formatUnits(amountY?.toString(), 6))

}







main()