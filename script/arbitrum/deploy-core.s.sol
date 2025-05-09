// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";

import "src/VaultFactory.sol";
import "src/interfaces/IVaultFactory.sol";

import "src/Strategy.sol";
import "src/SimpleVault.sol";
import "src/OracleVault.sol";

import "src/libraries/Constants.sol";

contract CoreDeployer is Script {
    address ADMIN_PROXY = 0xb842766eaDe13b3C51CBaEd70aa128760859c0Bf;
    address ADMIN = 0xdeD212B8BAb662B98f49e757CbB409BB7808dc10;
    address WETH_ZKEVM_TESTNET = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    address wnative;

    function run() public {
        if (block.chainid == 42161) {
            wnative = WETH_ZKEVM_TESTNET;
        }

        vm.broadcast();
        VaultFactory factory = new VaultFactory(wnative);

        console.log("VaultFactory ---->", address(factory));

        vm.broadcast();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(address(factory), ADMIN_PROXY, "");

        console.log("VaultFactory Proxy ---->", address(proxy));

        VaultFactory factoryProxy = VaultFactory(address(proxy));

        vm.broadcast();
        factoryProxy.initialize(ADMIN);

        console.log("VaultFactory Proxy ---->", address(factoryProxy));

        vm.broadcast();
        Strategy strategy = new Strategy(IVaultFactory(address(proxy)), Constants.DEFAULT_MAX_RANGE);
        console.log("Strategy ---->", address(strategy));

        vm.broadcast();
        SimpleVault simpleVault = new SimpleVault(IVaultFactory(address(proxy)));
        console.log("SimpleVault ---->", address(simpleVault));

        vm.broadcast();
        OracleVault oracleVault = new OracleVault(IVaultFactory(address(proxy)));
        console.log("OracleVault ---->", address(oracleVault));

        console.log("Set implementation");

        vm.startBroadcast();
        factoryProxy.setVaultImplementation(IVaultFactory.VaultType.Simple, address(simpleVault));

        factoryProxy.setVaultImplementation(IVaultFactory.VaultType.Oracle, address(oracleVault));

        factoryProxy.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(strategy));

        vm.stopBroadcast();
    }
}
