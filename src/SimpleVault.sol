// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {Uint256x256Math} from "joe-v2/libraries/math/Uint256x256Math.sol";

import {Math} from "./libraries/Math.sol";
import {BaseVault} from "./BaseVault.sol";
import {IStrategy} from "./interfaces/IStrategy.sol";
import {ISimpleVault} from "./interfaces/ISimpleVault.sol";
import {IVaultFactory} from "./interfaces/IVaultFactory.sol";

/**
 * @title Liquidity Book Simple Vault contract
 * @author Trader Joe
 * @notice This contract is used to interact with the Liquidity Book Pair contract.
 * This vault is meant to be used with pairs that doesn't have a price oracle.
 * The tokens need to be deposited following the vault's current ratio of token X and token Y.
 * The immutable data should be encoded as follow:
 * - 0x00: 20 bytes: The address of the LB pair.
 * - 0x14: 20 bytes: The address of the token X.
 * - 0x28: 20 bytes: The address of the token Y.
 * - 0x3C: 1 bytes: The decimals of the token X.
 * - 0x3D: 1 bytes: The decimals of the token Y.
 */
contract SimpleVault is BaseVault, ISimpleVault {
    using Uint256x256Math for uint256;
    using Math for uint256;

    /**
     * @dev Constructor of the contract.
     * @param factory Address of the factory.
     */
    constructor(IVaultFactory factory) BaseVault(factory) {}

    /**
     * @dev Returns the shares that will be minted when depositing `expectedAmountX` of token X and
     * `expectedAmountY` of token Y. The effective amounts will never be greater than the input amounts.
     * @param strategy The strategy to deposit to.
     * @param amountX The amount of token X to deposit.
     * @param amountY The amount of token Y to deposit.
     * @return shares The amount of shares that will be minted.
     * @return effectiveX The effective amount of token X that will be deposited.
     * @return effectiveY The effective amount of token Y that will be deposited.
     */
    function _previewShares(IStrategy strategy, uint256 amountX, uint256 amountY)
        internal
        view
        override
        returns (uint256 shares, uint256 effectiveX, uint256 effectiveY)
    {
        if (amountX == 0 && amountY == 0) return (0, 0, 0);
        if (amountX > type(uint128).max || amountY > type(uint128).max) revert SimpleVault__AmountsOverflow();

        uint256 totalShares = totalSupply();

        if (totalShares == 0) {
            effectiveX = amountX;
            effectiveY = amountY;
            shares = (amountX.max(amountY)) * _SHARES_PRECISION;
        } else {
            (uint256 totalX, uint256 totalY) = _getBalances(strategy);
            if (totalX > type(uint128).max || totalY > type(uint128).max) revert SimpleVault__AmountsOverflow();

            if (totalX == 0) {
                effectiveY = amountY;
                shares = amountY.mulDivRoundDown(totalShares, totalY);
            } else if (totalY == 0) {
                effectiveX = amountX;
                shares = amountX.mulDivRoundDown(totalShares, totalX);
            } else {
                unchecked {
                    uint256 cross = (amountX * totalY).min(amountY * totalX);
                    if (cross == 0) revert SimpleVault__ZeroCross();

                    effectiveX = (cross - 1) / totalY + 1;
                    effectiveY = (cross - 1) / totalX + 1;

                    shares = cross.mulDivRoundDown(totalShares, totalX * totalY);
                }
            }
        }
    }

    function _updatePool() internal override {
        // nothing
    }

    function _modifyUser(address user, int256 amount) internal virtual override {
        // nothing
    }

    function _beforeEmergencyMode() internal virtual override {
        // nothing
    }
}
