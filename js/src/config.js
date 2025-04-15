const addresses = {
    4002: {
        vault: "0x74617709F2bD6Fc88b36D3a78e105Cd08902E5B2",
        strategy: "0xC7C4EBDe23f4b1DE6476B384DcD29f723FFb895D",
        vaultFactory: "0xc4e9E5aE18bf3078706B38b26a3fC5b31833BA10",
        eth: "0xbc83aea91bE690Cdc9a5eB60a23AD9ea7FeDf71e",
        btc: "0x8Cce20D17aB9C6F60574e678ca96711D907fD08c",
        liquidityAmounts: "0x24b972796274D255b84c2B36e8a29bdAAdb65206"
    }
}

/* 

Factory:

Fantom Testnet:

  VaultFactory ----> 0x989a75A2581eC242b01263B24e4c9cB6914B54AB
  VaultFactory Proxy ----> 0xc4e9E5aE18bf3078706B38b26a3fC5b31833BA10
  VaultFactory Proxy ----> 0xc4e9E5aE18bf3078706B38b26a3fC5b31833BA10
  Strategy ----> 0xD8A21CBEBf0Dcf25D05d69a40fb1E532dD9d660b
  SimpleVault ----> 0x55380dF950D2Cd8A617863EbF0627f949FBa169D
  OracleVault ----> 0xCf62D18Eba246c6233CF31aCde91ae669e212a5D

  ETH-BTC

  OracleX ----> 0xb1b8fa960a39c9d298B8896a47ac13b1Be03f443
  OracleY ----> 0xf3F22725a752DE6d1BD17e55d44487111067D71F
  Vault created ----> 0x74617709F2bD6Fc88b36D3a78e105Cd08902E5B2
  Strategy created ----> 0xC7C4EBDe23f4b1DE6476B384DcD29f723FFb895D

*/

module.exports = addresses;