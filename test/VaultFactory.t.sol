// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "./TestHelper.sol";

contract VaultFactoryTest is TestHelper {
    function setUp() public override {
        vm.createSelectFork(vm.rpcUrl("avalanche"), 28_400_135);

        address implementation = address(new VaultFactory(wavax));
        factory = VaultFactory(address(new TransparentUpgradeableProxy(implementation, address(1), "")));

        factory.initialize(owner);

        address factoryOwner = lbFactory.owner();

        vm.startPrank(factoryOwner);
        wavax_usdc_20bp = address(lbFactory.createLBPair(IERC20(wavax), IERC20(usdc), 8_376_279, 20)); // 20 usdc per 1 wavax
        usdt_usdc_1bp = address(lbFactory.createLBPair(IERC20(usdt), IERC20(usdc), 1 << 23, 1)); // 1 usdc per 1 usdt
        joe_wavax_15bp = address(lbFactory.createLBPair(IERC20(joe), IERC20(wavax), 8_386_147, 15)); // 0.025 wavax per 1 joe
        vm.stopPrank();
    }

    function test_GetWNative() public {
        assertEq(factory.getWNative(), wavax, "test_GetWNative::1");
    }

    function test_Initialize() public {
        address implementation = address(new VaultFactory(wavax));

        factory = VaultFactory(address(new TransparentUpgradeableProxy(implementation, address(1), "")));
        factory.initialize(owner);

        assertEq(factory.owner(), owner, "test_Initialize::1");
        assertEq(factory.getDefaultOperator(), owner, "test_Initialize::2");
        assertEq(factory.getFeeRecipient(), owner, "test_Initialize::3");

        address alice = makeAddr("ALICE");

        factory = VaultFactory(address(new TransparentUpgradeableProxy(implementation, address(1), "")));
        factory.initialize(alice);

        assertEq(factory.owner(), alice, "test_Initialize::4");
        assertEq(factory.getDefaultOperator(), alice, "test_Initialize::5");
        assertEq(factory.getFeeRecipient(), alice, "test_Initialize::6");
    }

    function test_revert_InitializeTwice() public {
        vm.expectRevert("Initializable: contract is already initialized");
        factory.initialize(owner);
    }

    function test_revert_InitializeImplementation() public {
        address implementation = address(new VaultFactory(wavax));

        vm.expectRevert("Initializable: contract is already initialized");
        VaultFactory(implementation).initialize(owner);

        assertEq(VaultFactory(implementation).owner(), address(0), "test_revert_InitializeImplementation::1");
        assertEq(
            VaultFactory(implementation).getDefaultOperator(), address(0), "test_revert_InitializeImplementation::2"
        );
        assertEq(VaultFactory(implementation).getFeeRecipient(), address(0), "test_revert_InitializeImplementation::3");
    }

    function test_Initialized() public {
        assertEq(factory.owner(), owner, "test_Initialized::1");
        assertEq(factory.getDefaultOperator(), owner, "test_Initialized::2");
        assertEq(factory.getFeeRecipient(), owner, "test_Initialized::3");
    }

    function test_SetDefaultOperator() public {
        address newOperator = makeAddr("OPERATOR");

        vm.prank(owner);
        factory.setDefaultOperator(newOperator);

        assertEq(factory.getDefaultOperator(), newOperator, "test_SetDefaultOperator::1");
    }

    function test_revert_SetDefaultOperator() public {
        address newOperator = makeAddr("OPERATOR");

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setDefaultOperator(newOperator);
    }

    function test_SetFeeRecipient() public {
        address newRecipient = makeAddr("RECIPIENT");

        vm.prank(owner);
        factory.setFeeRecipient(newRecipient);

        assertEq(factory.getFeeRecipient(), newRecipient, "test_SetFeeRecipient::1");
    }

    function test_revert_SetFeeRecipient() public {
        address newRecipient = makeAddr("RECIPIENT");

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setFeeRecipient(newRecipient);
    }

    function test_SetSimpleVaultImplementation() public {
        address newImplementation = address(new SimpleVault(factory));

        vm.prank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, newImplementation);

        assertEq(
            factory.getVaultImplementation(IVaultFactory.VaultType.Simple),
            newImplementation,
            "test_SetSimpleVaultImplementation::1"
        );
    }

    function test_revert_SetSimpleVaultImplementation() public {
        address newImplementation = address(new SimpleVault(factory));

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, newImplementation);
    }

    function test_SetOracleVaultImplementation() public {
        address newImplementation = address(new OracleVault(factory));

        vm.prank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, newImplementation);

        assertEq(
            factory.getVaultImplementation(IVaultFactory.VaultType.Oracle),
            newImplementation,
            "test_SetOracleVaultImplementation::1"
        );
    }

    function test_revert_SetOracleVaultImplementation() public {
        address newImplementation = address(new OracleVault(factory));

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, newImplementation);
    }

    function test_SetStrategyImplementation() public {
        address newImplementation = address(new Strategy(factory, 51));

        vm.prank(owner);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, newImplementation);

        assertEq(
            factory.getStrategyImplementation(IVaultFactory.StrategyType.Default),
            newImplementation,
            "test_SetStrategyImplementation::1"
        );
    }

    function test_revert_SetStrategyImplementation() public {
        address newImplementation = address(new Strategy(factory, 51));

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, newImplementation);
    }

    function test_CreateSimpleVault() public {
        address implementation = address(new SimpleVault(factory));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, implementation);
        address vault = factory.createSimpleVault(ILBPair(wavax_usdc_20bp));
        vm.stopPrank();

        assertEq(address(ISimpleVault(vault).getPair()), wavax_usdc_20bp, "test_CreateSimpleVault::1");
        assertEq(address(ISimpleVault(vault).getTokenX()), wavax, "test_CreateSimpleVault::2");
        assertEq(address(ISimpleVault(vault).getTokenY()), usdc, "test_CreateSimpleVault::3");

        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Simple, 0), vault, "test_CreateSimpleVault::4");
        assertEq(factory.getNumberOfVaults(IVaultFactory.VaultType.Simple), 1, "test_CreateSimpleVault::5");
        assertEq(uint8(factory.getVaultType(vault)), uint8(IVaultFactory.VaultType.Simple), "test_CreateSimpleVault::6");
    }

    function test_revert_CreateSimpleVault() public {
        address implementation = address(new SimpleVault(factory));

        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultFactory.VaultFactory__VaultImplementationNotSet.selector, IVaultFactory.VaultType.Simple
            )
        );
        vm.prank(owner);
        factory.createSimpleVault(ILBPair(wavax_usdc_20bp));

        vm.prank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, implementation);

        vm.expectRevert("Ownable: caller is not the owner");
        factory.createSimpleVault(ILBPair(wavax_usdc_20bp));
    }

    function test_CreateOracleVault() public {
        address implementation = address(new OracleVault(factory));

        IAggregatorV3 dfX = new MockAggregator();
        IAggregatorV3 dfY = new MockAggregator();

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, implementation);
        address vault = factory.createOracleVault(ILBPair(usdt_usdc_1bp), dfX, dfY);
        vm.stopPrank();

        assertEq(address(IOracleVault(vault).getPair()), usdt_usdc_1bp, "test_CreateOracleVault::1");
        assertEq(address(IOracleVault(vault).getTokenX()), usdt, "test_CreateOracleVault::2");
        assertEq(address(IOracleVault(vault).getTokenY()), usdc, "test_CreateOracleVault::3");
        assertEq(address(IOracleVault(vault).getOracleX()), address(dfX), "test_CreateOracleVault::4");
        assertEq(address(IOracleVault(vault).getOracleY()), address(dfY), "test_CreateOracleVault::5");
        assertEq(
            IOracleVault(vault).getPrice(), ((uint256(1e18) * 1e6) << 128) / (1e18 * 1e6), "test_CreateOracleVault::6"
        );
    }

    function test_revert_CreateOracleVault() public {
        address implementation = address(new OracleVault(factory));

        IAggregatorV3 dfX = new MockAggregator();
        IAggregatorV3 dfY = new MockAggregator();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.createOracleVault(ILBPair(usdt_usdc_1bp), dfX, dfY);

        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultFactory.VaultFactory__VaultImplementationNotSet.selector, IVaultFactory.VaultType.Oracle
            )
        );
        factory.createOracleVault(ILBPair(usdt_usdc_1bp), dfX, dfY);

        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, implementation);

        vm.expectRevert();
        factory.createOracleVault(ILBPair(usdt_usdc_1bp), IAggregatorV3(address(0)), dfY);

        vm.expectRevert();
        factory.createOracleVault(ILBPair(usdt_usdc_1bp), dfX, IAggregatorV3(address(0)));

        factory.setVaultImplementation(
            IVaultFactory.VaultType.Oracle, address(new InvalidOracleVault(address(factory)))
        );

        vm.expectRevert(IVaultFactory.VaultFactory__InvalidOraclePrice.selector);
        factory.createOracleVault(ILBPair(usdt_usdc_1bp), dfX, dfY);
        vm.stopPrank();
    }

    function test_CreateDefaultStrategy() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        address vault = factory.createSimpleVault(ILBPair(wavax_usdc_20bp));

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);
        strategy = factory.createDefaultStrategy(IBaseVault(vault));
        vm.stopPrank();

        assertEq(address(IStrategy(strategy).getVault()), vault, "test_CreateDefaultStrategy::1");
        assertEq(address(IStrategy(strategy).getPair()), wavax_usdc_20bp, "test_CreateDefaultStrategy::2");
        assertEq(address(IStrategy(strategy).getTokenX()), wavax, "test_CreateDefaultStrategy::3");
        assertEq(address(IStrategy(strategy).getTokenY()), usdc, "test_CreateDefaultStrategy::4");

        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 0), strategy, "test_CreateDefaultStrategy::5"
        );
        assertEq(factory.getNumberOfStrategies(IVaultFactory.StrategyType.Default), 1, "test_CreateDefaultStrategy::6");
        assertEq(
            uint8(factory.getStrategyType(strategy)),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateDefaultStrategy::7"
        );
    }

    function test_revert_CreateDefaultStrategy() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        vm.expectRevert();
        factory.createDefaultStrategy(IBaseVault(address(0)));

        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        address vault = factory.createSimpleVault(ILBPair(wavax_usdc_20bp));

        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultFactory.VaultFactory__StrategyImplementationNotSet.selector,
                uint8(IVaultFactory.StrategyType.Default)
            )
        );
        factory.createDefaultStrategy(IBaseVault(vault));

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.createDefaultStrategy(IBaseVault(vault));
    }

    function test_LinkVaultToStrategy() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        address vault = factory.createSimpleVault(ILBPair(wavax_usdc_20bp));

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);
        strategy = factory.createDefaultStrategy(IBaseVault(vault));

        factory.linkVaultToStrategy(IBaseVault(vault), strategy);
        vm.stopPrank();

        assertEq(address(ISimpleVault(vault).getStrategy()), strategy, "test_LinkVaultToStrategy::1");
        assertEq(IStrategy(strategy).getVault(), vault, "test_LinkVaultToStrategy::2");
    }

    function test_revert_LinkVaultToStrategy() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        vm.expectRevert(IVaultFactory.VaultFactory__InvalidStrategy.selector);
        factory.linkVaultToStrategy(IBaseVault(address(0)), address(0));

        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        address vault = factory.createSimpleVault(ILBPair(wavax_usdc_20bp));

        vm.expectRevert(IVaultFactory.VaultFactory__InvalidStrategy.selector);
        factory.linkVaultToStrategy(IBaseVault(vault), address(0));

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);
        strategy = factory.createDefaultStrategy(IBaseVault(vault));

        vm.expectRevert();
        factory.linkVaultToStrategy(IBaseVault(address(0)), strategy);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.linkVaultToStrategy(IBaseVault(vault), strategy);
    }

    function test_CreateSimpleVaultAndDefaultStrategy() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
        vm.stopPrank();

        assertEq(address(ISimpleVault(vault).getPair()), wavax_usdc_20bp, "test_CreateSimpleVaultAndDefaultStrategy::1");
        assertEq(address(ISimpleVault(vault).getStrategy()), strategy, "test_CreateSimpleVaultAndDefaultStrategy::2");
        assertEq(address(IStrategy(strategy).getVault()), vault, "test_CreateSimpleVaultAndDefaultStrategy::3");
        assertEq(address(IStrategy(strategy).getPair()), wavax_usdc_20bp, "test_CreateSimpleVaultAndDefaultStrategy::4");
        assertEq(address(IStrategy(strategy).getTokenX()), wavax, "test_CreateSimpleVaultAndDefaultStrategy::5");
        assertEq(address(IStrategy(strategy).getTokenY()), usdc, "test_CreateSimpleVaultAndDefaultStrategy::6");

        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 0),
            strategy,
            "test_CreateSimpleVaultAndDefaultStrategy::7"
        );
        assertEq(
            factory.getNumberOfStrategies(IVaultFactory.StrategyType.Default),
            1,
            "test_CreateSimpleVaultAndDefaultStrategy::8"
        );
        assertEq(
            uint8(factory.getStrategyType(strategy)),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateSimpleVaultAndDefaultStrategy::9"
        );
    }

    function test_revert_CreateSimpleVaultAndDefaultStrategy() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        vm.expectRevert();
        factory.createSimpleVaultAndDefaultStrategy(ILBPair(address(0)));

        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultFactory.VaultFactory__StrategyImplementationNotSet.selector,
                uint8(IVaultFactory.StrategyType.Default)
            )
        );
        factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
    }

    function test_CreateOracleVaultAndDefaultStrategy() public {
        address vaultImplementation = address(new OracleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        IAggregatorV3 dfX = new MockAggregator();
        IAggregatorV3 dfY = new MockAggregator();

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, vaultImplementation);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        (vault, strategy) = factory.createOracleVaultAndDefaultStrategy(ILBPair(usdt_usdc_1bp), dfX, dfY);
        vm.stopPrank();

        assertEq(address(IOracleVault(vault).getPair()), usdt_usdc_1bp, "test_CreateOracleVaultAndDefaultStrategy::1");
        assertEq(address(IOracleVault(vault).getTokenX()), usdt, "test_CreateOracleVaultAndDefaultStrategy::2");
        assertEq(address(IOracleVault(vault).getTokenY()), usdc, "test_CreateOracleVaultAndDefaultStrategy::3");
        assertEq(address(IOracleVault(vault).getOracleX()), address(dfX), "test_CreateOracleVaultAndDefaultStrategy::4");
        assertEq(address(IOracleVault(vault).getOracleY()), address(dfY), "test_CreateOracleVaultAndDefaultStrategy::5");
        assertEq(
            IOracleVault(vault).getPrice(),
            ((uint256(1e18) * 1e6) << 128) / (1e18 * 1e6),
            "test_CreateOracleVaultAndDefaultStrategy::6"
        );

        assertEq(address(ISimpleVault(vault).getStrategy()), strategy, "test_CreateOracleVaultAndDefaultStrategy::7");
        assertEq(IStrategy(strategy).getVault(), vault, "test_CreateOracleVaultAndDefaultStrategy::8");
        assertEq(address(IStrategy(strategy).getPair()), usdt_usdc_1bp, "test_CreateOracleVaultAndDefaultStrategy::9");
        assertEq(address(IStrategy(strategy).getTokenX()), usdt, "test_CreateOracleVaultAndDefaultStrategy::10");
        assertEq(address(IStrategy(strategy).getTokenY()), usdc, "test_CreateOracleVaultAndDefaultStrategy::11");

        assertEq(
            factory.getVaultAt(IVaultFactory.VaultType.Oracle, 0), vault, "test_CreateOracleVaultAndDefaultStrategy::12"
        );
        assertEq(
            factory.getNumberOfVaults(IVaultFactory.VaultType.Oracle), 1, "test_CreateOracleVaultAndDefaultStrategy::13"
        );

        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 0),
            strategy,
            "test_CreateOracleVaultAndDefaultStrategy::14"
        );
        assertEq(
            factory.getNumberOfStrategies(IVaultFactory.StrategyType.Default),
            1,
            "test_CreateOracleVaultAndDefaultStrategy::15"
        );
        assertEq(
            uint8(factory.getStrategyType(strategy)),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateOracleVaultAndDefaultStrategy::16"
        );
    }

    function test_revert_CreateOracleVaultAndDefaultStrategy() public {
        address vaultImplementation = address(new OracleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        IAggregatorV3 dfX = new MockAggregator();
        IAggregatorV3 dfY = new MockAggregator();

        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultFactory.VaultFactory__VaultImplementationNotSet.selector, IVaultFactory.VaultType.Oracle
            )
        );
        factory.createOracleVaultAndDefaultStrategy(ILBPair(address(wavax_usdc_20bp)), dfX, dfY);

        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, vaultImplementation);

        vm.expectRevert(
            abi.encodeWithSelector(
                IVaultFactory.VaultFactory__StrategyImplementationNotSet.selector,
                uint8(IVaultFactory.StrategyType.Default)
            )
        );
        factory.createOracleVaultAndDefaultStrategy(ILBPair(address(wavax_usdc_20bp)), dfX, dfY);

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        vm.expectRevert();
        factory.createOracleVaultAndDefaultStrategy(ILBPair(address(0)), dfX, dfY);

        vm.expectRevert();
        factory.createOracleVaultAndDefaultStrategy(ILBPair(address(wavax_usdc_20bp)), IAggregatorV3(address(0)), dfY);

        vm.expectRevert();
        factory.createOracleVaultAndDefaultStrategy(ILBPair(address(wavax_usdc_20bp)), dfX, IAggregatorV3(address(0)));
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.createOracleVaultAndDefaultStrategy(ILBPair(address(wavax_usdc_20bp)), dfX, dfY);
    }

    function test_SetEmergencyMode() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        deal(wavax, address(strategy), 1e18);
        assertEq(IERC20Upgradeable(wavax).balanceOf(address(strategy)), 1e18, "test_SetEmergencyMode::1");

        factory.setEmergencyMode(IBaseVault(vault));
        vm.stopPrank();

        assertEq(address(ISimpleVault(vault).getStrategy()), address(0), "test_SetEmergencyMode::2");

        assertEq(IERC20Upgradeable(wavax).balanceOf(address(strategy)), 0, "test_SetEmergencyMode::3");
        assertEq(IERC20Upgradeable(wavax).balanceOf(vault), 1e18, "test_SetEmergencyMode::4");
    }

    function test_revert_SetEmergencyMode() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        deal(wavax, address(strategy), 1e18);
        assertEq(IERC20Upgradeable(wavax).balanceOf(address(strategy)), 1e18, "test_revert_SetEmergencyMode::1");
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setEmergencyMode(IBaseVault(vault));

        vm.startPrank(owner);
        factory.setEmergencyMode(IBaseVault(vault));

        vm.expectRevert();
        factory.setEmergencyMode(IBaseVault(vault));
        vm.stopPrank();
    }

    function test_RecoverERC20() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        (vault,) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        deal(usdt, address(vault), 1e18);
        assertEq(IERC20Upgradeable(usdt).balanceOf(address(vault)), 1e18, "test_RecoverERC20::1");

        factory.recoverERC20(IBaseVault(vault), IERC20Upgradeable(usdt), address(this), 1e18);
        vm.stopPrank();

        assertEq(IERC20Upgradeable(usdt).balanceOf(address(vault)), 0, "test_RecoverERC20::2");
        assertEq(IERC20Upgradeable(usdt).balanceOf(address(this)), 1e18, "test_RecoverERC20::3");
    }

    function test_revert_RecoverERC20() public {
        address vaultImplementation = address(new SimpleVault(factory));
        address strategyImplementation = address(new Strategy(factory, 51));

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, vaultImplementation);
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, strategyImplementation);

        (vault,) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        vm.expectRevert(IBaseVault.BaseVault__InvalidToken.selector);
        factory.recoverERC20(IBaseVault(vault), IERC20Upgradeable(wavax), address(this), 1e18);

        vm.expectRevert(IBaseVault.BaseVault__InvalidToken.selector);
        factory.recoverERC20(IBaseVault(vault), IERC20Upgradeable(usdc), address(this), 1e18);
        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.recoverERC20(IBaseVault(vault), IERC20Upgradeable(wavax), address(this), 1e18);
    }

    function test_GetNameAndSymbol() public {
        address simpleVaultImplementation = address(new SimpleVault(factory));
        address oracleVaultImplementation = address(new OracleVault(factory));

        IAggregatorV3 dfX = new MockAggregator();
        IAggregatorV3 dfY = new MockAggregator();

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, simpleVaultImplementation);
        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, oracleVaultImplementation);

        address simpleVault = factory.createSimpleVault(ILBPair(wavax_usdc_20bp));
        address oracleVault = factory.createOracleVault(ILBPair(wavax_usdc_20bp), dfX, dfY);
        vm.stopPrank();

        assertEq(
            IERC20MetadataUpgradeable(simpleVault).name(),
            "Maker Vault Token - Simple Vault #0",
            "test_GetNameAndSymbol::3"
        );
        assertEq(IERC20MetadataUpgradeable(simpleVault).symbol(), "MVT", "test_GetNameAndSymbol::4");

        assertEq(
            IERC20MetadataUpgradeable(oracleVault).name(),
            "Maker Vault Token - Oracle Vault #0",
            "test_GetNameAndSymbol::1"
        );
        assertEq(IERC20MetadataUpgradeable(oracleVault).symbol(), "MVT", "test_GetNameAndSymbol::2");
    }

    function test_CreateMultipleAPT() public {
        address[] memory oracleVaults = new address[](10);
        address[] memory simpleVaults = new address[](10);
        address[] memory strategies = new address[](10);

        IAggregatorV3 dfX = new MockAggregator();
        IAggregatorV3 dfY = new MockAggregator();

        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setVaultImplementation(IVaultFactory.VaultType.Oracle, address(new OracleVault(factory)));

        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));

        (oracleVaults[0], strategies[0]) =
            factory.createOracleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp), dfX, dfY);
        (oracleVaults[1], strategies[1]) =
            factory.createOracleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp), dfX, dfY);
        (oracleVaults[2], strategies[2]) =
            factory.createOracleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp), dfX, dfY);

        (simpleVaults[0], strategies[3]) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
        (simpleVaults[1], strategies[4]) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
        (simpleVaults[2], strategies[5]) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
        vm.stopPrank();

        assertEq(factory.getNumberOfVaults(IVaultFactory.VaultType.Oracle), 3, "test_CreateMultipleAPT::1");
        assertEq(factory.getNumberOfVaults(IVaultFactory.VaultType.Simple), 3, "test_CreateMultipleAPT::2");

        assertEq(factory.getNumberOfStrategies(IVaultFactory.StrategyType.Default), 6, "test_CreateMultipleAPT::3");

        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Oracle, 0), oracleVaults[0], "test_CreateMultipleAPT::4");
        assertEq(
            uint8(factory.getVaultType(oracleVaults[0])),
            uint8(IVaultFactory.VaultType.Oracle),
            "test_CreateMultipleAPT::5"
        );
        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Oracle, 1), oracleVaults[1], "test_CreateMultipleAPT::6");
        assertEq(
            uint8(factory.getVaultType(oracleVaults[1])),
            uint8(IVaultFactory.VaultType.Oracle),
            "test_CreateMultipleAPT::7"
        );
        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Oracle, 2), oracleVaults[2], "test_CreateMultipleAPT::8");
        assertEq(
            uint8(factory.getVaultType(oracleVaults[2])),
            uint8(IVaultFactory.VaultType.Oracle),
            "test_CreateMultipleAPT::9"
        );

        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Simple, 0), simpleVaults[0], "test_CreateMultipleAPT::10");
        assertEq(
            uint8(factory.getVaultType(simpleVaults[0])),
            uint8(IVaultFactory.VaultType.Simple),
            "test_CreateMultipleAPT::11"
        );
        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Simple, 1), simpleVaults[1], "test_CreateMultipleAPT::12");
        assertEq(
            uint8(factory.getVaultType(simpleVaults[1])),
            uint8(IVaultFactory.VaultType.Simple),
            "test_CreateMultipleAPT::13"
        );
        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Simple, 2), simpleVaults[2], "test_CreateMultipleAPT::14");
        assertEq(
            uint8(factory.getVaultType(simpleVaults[2])),
            uint8(IVaultFactory.VaultType.Simple),
            "test_CreateMultipleAPT::15"
        );

        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 0), strategies[0], "test_CreateMultipleAPT::16"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[0])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::17"
        );
        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 1), strategies[1], "test_CreateMultipleAPT::18"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[1])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::19"
        );
        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 2), strategies[2], "test_CreateMultipleAPT::20"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[2])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::21"
        );
        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 3), strategies[3], "test_CreateMultipleAPT::22"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[3])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::23"
        );
        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 4), strategies[4], "test_CreateMultipleAPT::24"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[4])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::25"
        );
        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 5), strategies[5], "test_CreateMultipleAPT::26"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[5])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::27"
        );

        vm.startPrank(owner);
        (oracleVaults[3], strategies[6]) =
            factory.createOracleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp), dfX, dfY);

        (simpleVaults[3], strategies[7]) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
        vm.stopPrank();

        assertEq(factory.getNumberOfVaults(IVaultFactory.VaultType.Oracle), 4, "test_CreateMultipleAPT::28");
        assertEq(factory.getNumberOfVaults(IVaultFactory.VaultType.Simple), 4, "test_CreateMultipleAPT::29");

        assertEq(factory.getNumberOfStrategies(IVaultFactory.StrategyType.Default), 8, "test_CreateMultipleAPT::30");

        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Oracle, 3), oracleVaults[3], "test_CreateMultipleAPT::31");
        assertEq(
            uint8(factory.getVaultType(oracleVaults[3])),
            uint8(IVaultFactory.VaultType.Oracle),
            "test_CreateMultipleAPT::32"
        );
        assertEq(factory.getVaultAt(IVaultFactory.VaultType.Simple, 3), simpleVaults[3], "test_CreateMultipleAPT::33");
        assertEq(
            uint8(factory.getVaultType(simpleVaults[3])),
            uint8(IVaultFactory.VaultType.Simple),
            "test_CreateMultipleAPT::34"
        );

        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 6), strategies[6], "test_CreateMultipleAPT::35"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[6])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::36"
        );
        assertEq(
            factory.getStrategyAt(IVaultFactory.StrategyType.Default, 7), strategies[7], "test_CreateMultipleAPT::37"
        );
        assertEq(
            uint8(factory.getStrategyType(strategies[7])),
            uint8(IVaultFactory.StrategyType.Default),
            "test_CreateMultipleAPT::38"
        );
    }

    function test_SetOperator() public {
        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));
        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));
        factory.setOperator(IStrategy(strategy), address(1));
        vm.stopPrank();

        assertEq(IStrategy(strategy).getOperator(), address(1), "test_SetOperator::1");
    }

    function test_SetPendingAumAnnualFee() public {
        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        (bool isSet, uint256 value) = IStrategy(strategy).getPendingAumAnnualFee();

        assertEq(isSet, false, "test_SetPendingAumAnnualFee::1");
        assertEq(value, 0, "test_SetPendingAumAnnualFee::2");

        factory.setPendingAumAnnualFee(IBaseVault(vault), 100);
        vm.stopPrank();

        (isSet, value) = IStrategy(strategy).getPendingAumAnnualFee();

        assertEq(isSet, true, "test_SetPendingAumAnnualFee::3");
        assertEq(value, 100, "test_SetPendingAumAnnualFee::4");

        assertEq(IStrategy(strategy).getAumAnnualFee(), 0, "test_SetPendingAumAnnualFee::5");
    }

    function test_ResetPendingAumAnnualFee() public {
        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        factory.setPendingAumAnnualFee(IBaseVault(vault), 100);
        factory.resetPendingAumAnnualFee(IBaseVault(vault));
        vm.stopPrank();

        (bool isSet, uint256 value) = IStrategy(strategy).getPendingAumAnnualFee();

        assertEq(isSet, false, "test_ResetPendingAumAnnualFee::1");
        assertEq(value, 0, "test_ResetPendingAumAnnualFee::2");

        assertEq(IStrategy(strategy).getAumAnnualFee(), 0, "test_ResetPendingAumAnnualFee::3");
    }

    function test_revert_SetAndResetPendingAumAnnualFee() public {
        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        vm.stopPrank();

        vm.expectRevert("Ownable: caller is not the owner");
        factory.setPendingAumAnnualFee(IBaseVault(vault), 100);

        vm.expectRevert("Ownable: caller is not the owner");
        factory.resetPendingAumAnnualFee(IBaseVault(vault));
    }

    function test_PauseDeposits() public {
        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        assertEq(IBaseVault(vault).isDepositsPaused(), false, "test_PauseDeposits::1");

        IBaseVault(vault).pauseDeposits();
        vm.stopPrank();

        assertEq(IBaseVault(vault).isDepositsPaused(), true, "test_Pausedeposits::2");
    }

    function test_ResumeDeposits() public {
        vm.startPrank(owner);
        factory.setVaultImplementation(IVaultFactory.VaultType.Simple, address(new SimpleVault(factory)));
        factory.setStrategyImplementation(IVaultFactory.StrategyType.Default, address(new Strategy(factory, 51)));

        (vault, strategy) = factory.createSimpleVaultAndDefaultStrategy(ILBPair(wavax_usdc_20bp));

        IBaseVault(vault).pauseDeposits();

        assertEq(IBaseVault(vault).isDepositsPaused(), true, "test_ResumeDeposits::1");

        IBaseVault(vault).resumeDeposits();
        vm.stopPrank();

        assertEq(IBaseVault(vault).isDepositsPaused(), false, "test_ResumeDeposits::2");
    }

    function test_SetTransferIgnoreList() public {
        // check if ignore list is empty
        assertEq(factory.getTransferIgnoreList().length, 0, "test_SetTransferIgnoreList::1");

        vm.startPrank(owner);

        // set a new array of addresses
        address[] memory addresses = new address[](2);
        addresses[0] = address(1);
        addresses[1] = address(2);

        factory.setTransferIgnoreList(addresses);
        vm.stopPrank();
    
        assertEq(factory.getTransferIgnoreList().length, 2, "test_SetTransferIgnoreList::2");

        vm.startPrank(owner);
        // set a new array of addresses
        address[] memory addresses2 = new address[](1);
        addresses2[0] = address(3);
        factory.setTransferIgnoreList(addresses2);
        vm.stopPrank();

        assertEq(factory.getTransferIgnoreList().length, 1, "test_SetTransferIgnoreList::3");
    }
}

contract InvalidOracleVault {
    address private immutable _factory;

    constructor(address factory) {
        _factory = factory;
    }

    function getFactory() external view returns (address) {
        return _factory;
    }

    function getPrice() external pure returns (uint256) {
        return 0;
    }

    fallback() external {}
}
