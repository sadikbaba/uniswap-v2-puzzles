// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract ExactSwap {
    /**
     *  PERFORM AN SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performExactSwap(address pool, address weth, address usdc) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();

        // 1. We want exactly 1337 USDC (token0)
        uint256 amountOut = 1337 * 1e6;

        // 2. Calculate exact WETH (token1) needed using the formula:
        // amountIn = (reserveIn * amountOut * 1000) / ((reserveOut - amountOut) * 997) + 1
        // reserveIn = reserve1 (WETH), reserveOut = reserve0 (USDC)
        uint256 numerator = reserve1 * amountOut * 1000;
        uint256 denominator = (reserve0 - amountOut) * 997;
        uint256 amountIn = (numerator / denominator) + 1;

        // 3. Transfer ONLY the required amount, not the whole balance
        IERC20(weth).transfer(pool, amountIn);

        // 4. Execute swap
        pair.swap(amountOut, 0, address(this), "");
    }
}
