// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */
    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // your code start here
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        uint256 wethBalance = IERC20(weth).balanceOf(address(this));

        uint256 wethOptimal = (usdcBalance * wethReserve) / usdcReserve;
        // see available functions here: https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol

        uint256 usdcToSend;
        uint256 wethToSend;

        if (wethOptimal <= wethBalance) {
            usdcToSend = usdcBalance;
            wethToSend = wethOptimal;
        } else {
            usdcToSend = (wethBalance * usdcReserve) / wethReserve;
            wethToSend = wethBalance;
        }

        IERC20(usdc).transfer(pool, usdcToSend);
        IERC20(weth).transfer(pool, wethToSend);

        pair.getReserves();
        pair.mint(msg.sender);
    }
}
