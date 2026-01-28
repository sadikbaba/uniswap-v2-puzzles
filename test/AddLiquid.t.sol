// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {AddLiquid} from "../src/AddLiquid.sol";
import "../src/interfaces/IUniswapV2Pair.sol";
import "../src/interfaces/IERC20.sol";

contract AddLiquidTest is Test {
    AddLiquid public addLiquid;

    // Mainnet addresses
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant POOL = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc; // USDC/WETH

    function setUp() public {
        // ✅ Fork mainnet
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/r1VHZ886XuNYndhbw_FF6");

        addLiquid = new AddLiquid();

        // Give the contract tokens (this works ONLY on fork)
        deal(WETH, address(addLiquid), 1 ether);
        deal(USDC, address(addLiquid), 1000e6);
    }

    function test_AddLiquidity() public {
        // Read real reserves
        (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(POOL).getReserves();

        uint256 totalSupply = IUniswapV2Pair(POOL).totalSupply();

        // Call addLiquidity as Bob
        vm.prank(address(0xb0b));
        addLiquid.addLiquidity(USDC, WETH, POOL, reserve0, reserve1);

        // LP tokens Bob received
        uint256 lpBal = IUniswapV2Pair(POOL).balanceOf(address(0xb0b));

        assertGt(lpBal, 0, "No LP tokens minted");

        // --- Expected LP calculation (same as Uniswap) ---

        uint256 usdcUsed = 1000e6 - IERC20(USDC).balanceOf(address(addLiquid));

        uint256 wethUsed = (usdcUsed * reserve1) / reserve0;

        uint256 expectedLp = _min((usdcUsed * totalSupply) / reserve0, (wethUsed * totalSupply) / reserve1);
        console.log("lp bal:", lpBal);
        console.log("expected lp", expectedLp);

        assert(lpBal >= expectedLp);
    }

    function _min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }
}
