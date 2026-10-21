// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/src/types/BeforeSwapDelta.sol";
import {Currency, CurrencyLibrary} from "v4-core/src/types/Currency.sol";
import {IERC20} from "forge-std/interfaces/IERC20.sol";

contract SkyLaunchpadHook is BaseHook {
    using PoolIdLibrary for PoolKey;
    using CurrencyLibrary for Currency;

    address public constant DEV = 0xF028E100A37e9B05dABf25828C46a3c13a03B46f;
    IERC20 public immutable sky;
    uint256 public immutable launchTime;

    uint256 public constant TAX_BPS = 300;             // 3%
    uint256 public constant MAX_WALLET_BPS = 200;      // 2%
    uint256 public constant PROTECTION_SECONDS = 120;  // 2 menit

    constructor(IPoolManager _pm, address _sky) BaseHook(_pm) {
        sky = IERC20(_sky);
        launchTime = block.timestamp;
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: true,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function _beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata
    ) internal override returns (bytes4, BeforeSwapDelta, uint24) {
        // Max wallet hanya 2 menit pertama
        if (block.timestamp < launchTime + PROTECTION_SECONDS) {
            // TODO: hitung amountOut yang akan diterima
            // Jika buy SKY dan amountOut > 2% supply → revert
            // uint256 maxAllowed = (sky.totalSupply() * MAX_WALLET_BPS) / 10000;
            // if (estimatedOut > maxAllowed) revert MaxWalletExceeded();
        }
        return (BaseHook.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function _afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata
    ) internal override returns (bytes4, int128) {
        // TODO: ambil 3% dari output SKY dan take ke DEV
        // poolManager.take(skyCurrency, DEV, taxAmount);
        return (BaseHook.afterSwap.selector, 0);
    }
}